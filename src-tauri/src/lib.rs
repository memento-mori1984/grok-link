mod bridge;

use bridge::{managed_state, BridgeState, Handoff, BRIDGE_PORT};
use std::fs;
use std::path::PathBuf;
use std::process::Command;
use std::sync::Arc;
use tauri::{AppHandle, Emitter, Manager};
use tauri_plugin_opener::OpenerExt;

const BROWSER_BRIDGE_SCRIPT: &str = include_str!("../../browser/grok-link-bridge.user.js");

fn browser_bridge_path() -> PathBuf {
    bridge::bridge_data_dir()
        .join("browser")
        .join("grok-link-bridge.user.js")
}

fn ensure_browser_bridge_script() -> Result<PathBuf, String> {
    let path = browser_bridge_path();
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent).map_err(|e| e.to_string())?;
    }
    if !path.exists() {
        fs::write(&path, BROWSER_BRIDGE_SCRIPT).map_err(|e| e.to_string())?;
    }
    Ok(path)
}

#[tauri::command]
fn open_in_browser(app: tauri::AppHandle, url: String) -> Result<(), String> {
    if url.is_empty() {
        return Err("URL is empty".into());
    }
    app.opener()
        .open_url(&url, None::<&str>)
        .map_err(|e| e.to_string())
}

#[tauri::command]
fn read_clipboard_text() -> Result<String, String> {
    arboard::Clipboard::new()
        .map_err(|e| e.to_string())?
        .get_text()
        .map_err(|e| e.to_string())
}

#[tauri::command]
fn write_clipboard_text(text: String) -> Result<(), String> {
    arboard::Clipboard::new()
        .map_err(|e| e.to_string())?
        .set_text(text)
        .map_err(|e| e.to_string())
}

#[tauri::command]
fn bridge_port() -> u16 {
    BRIDGE_PORT
}

#[tauri::command]
fn list_handoffs(app: AppHandle) -> Result<Vec<Handoff>, String> {
    let state = managed_state(&app).ok_or("bridge not ready")?;
    Ok(state.list())
}

#[tauri::command]
fn mark_handoff_sent(app: AppHandle, id: String) -> Result<bool, String> {
    let state = managed_state(&app).ok_or("bridge not ready")?;
    Ok(state.mark_sent(&id))
}

#[tauri::command]
fn submit_handoff_response(app: AppHandle, id: String, response: String) -> Result<bool, String> {
    let state = managed_state(&app).ok_or("bridge not ready")?;
    let ok = state.submit_response(&id, response);
    if ok {
        let _ = app.emit("handoff-answered", id);
    }
    Ok(ok)
}

#[tauri::command]
fn refresh_inbox(app: AppHandle) -> Result<Vec<Handoff>, String> {
    let state = managed_state(&app).ok_or("bridge not ready")?;
    state.import_inbox_files();
    Ok(state.list())
}

#[tauri::command]
fn install_browser_bridge(app: AppHandle) -> Result<String, String> {
    let path = ensure_browser_bridge_script()?;
    app.opener()
        .open_url("https://www.tampermonkey.net/", None::<&str>)
        .map_err(|e| e.to_string())?;
    Command::new("notepad.exe")
        .arg(&path)
        .spawn()
        .map_err(|e| e.to_string())?;
    Ok(path.to_string_lossy().into_owned())
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .setup(|app| {
            let data_dir = bridge::bridge_data_dir();
            let _ = ensure_browser_bridge_script();
            let bridge = Arc::new(BridgeState::new(data_dir));
            app.manage(bridge.clone());
            start_bridge_server(app.handle().clone(), bridge);
            Ok(())
        })
        .invoke_handler(tauri::generate_handler![
            open_in_browser,
            read_clipboard_text,
            write_clipboard_text,
            bridge_port,
            list_handoffs,
            mark_handoff_sent,
            submit_handoff_response,
            refresh_inbox,
            install_browser_bridge
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}

fn start_bridge_server(app: AppHandle, state: Arc<BridgeState>) {
    bridge::start_bridge_server(app, state);
}