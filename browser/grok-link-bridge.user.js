// ==UserScript==
// @name         Grok Link Browser Bridge
// @namespace    com.ranzh.grok-link
// @version      0.3.0
// @description  Auto-sync SuperGrok replies back to Grok Build via local Grok Link bridge
// @match        https://grok.com/*
// @match        https://www.grok.com/*
// @match        https://grok.x.ai/*
// @grant        none
// @run-at       document-idle
// ==/UserScript==

(function () {
  "use strict";

  const BRIDGE = "http://127.0.0.1:3877";
  const STABLE_MS = 2000;
  const POLL_MS = 800;
  const STORAGE_KEY = "grok-link-handoff-id";

  function parseHandoffId() {
    const hashMatch = location.hash.match(/grok-link-id=([a-f0-9]+)/i);
    if (hashMatch) {
      sessionStorage.setItem(STORAGE_KEY, hashMatch[1]);
      return hashMatch[1];
    }
    return sessionStorage.getItem(STORAGE_KEY);
  }

  function showBadge(text, ok) {
    let el = document.getElementById("grok-link-bridge-badge");
    if (!el) {
      el = document.createElement("div");
      el.id = "grok-link-bridge-badge";
      Object.assign(el.style, {
        position: "fixed",
        bottom: "16px",
        right: "16px",
        zIndex: "2147483647",
        padding: "8px 12px",
        borderRadius: "8px",
        fontSize: "13px",
        fontFamily: "system-ui, sans-serif",
        color: "#fff",
        background: "#1e3a5f",
        boxShadow: "0 4px 12px rgba(0,0,0,.45)",
        pointerEvents: "none",
      });
      document.body.appendChild(el);
    }
    el.textContent = text;
    el.style.background = ok ? "#166534" : "#1e3a5f";
  }

  function collectTextBlocks(root) {
    const out = [];
    const nodes = root.querySelectorAll(
      "article, [data-testid], [class*='message'], [class*='markdown'], [class*='response'], p, div"
    );
    nodes.forEach((el) => {
      if (el.closest("#grok-link-bridge-badge")) return;
      if (el.querySelector("article, [class*='message'], [class*='markdown']")) return;
      const text = (el.innerText || "").trim();
      if (text.length < 80 || text.length > 80000) return;
      out.push(text);
    });
    return out;
  }

  function extractLatestAssistantText() {
    const blocks = collectTextBlocks(document.querySelector("main") || document.body);
    if (!blocks.length) return "";
    const unique = [...new Set(blocks)];
    return unique.sort((a, b) => b.length - a.length)[0] || "";
  }

  async function submitResponse(id, text) {
    const res = await fetch(`${BRIDGE}/api/handoffs/${id}/response`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ response: text }),
    });
    return res.ok;
  }

  async function checkAlreadyAnswered(id) {
    try {
      const res = await fetch(`${BRIDGE}/api/handoffs/${id}`);
      if (!res.ok) return false;
      const data = await res.json();
      return data.status === "answered" && (data.response || "").length > 0;
    } catch {
      return false;
    }
  }

  const handoffId = parseHandoffId();
  if (!handoffId) return;

  showBadge(`Grok Link: watching ${handoffId.slice(0, 8)}…`);

  let lastSeen = "";
  let stableSince = 0;
  let submitted = false;
  const baseline = extractLatestAssistantText();

  (async function run() {
    if (await checkAlreadyAnswered(handoffId)) {
      showBadge("Grok Link: already synced ✓", true);
      return;
    }

    window.setInterval(async () => {
      if (submitted) return;
      const text = extractLatestAssistantText();
      if (!text || text === baseline) return;
      if (text !== lastSeen) {
        lastSeen = text;
        stableSince = Date.now();
        return;
      }
      if (Date.now() - stableSince < STABLE_MS) return;

      submitted = true;
      showBadge("Grok Link: syncing to Grok Build…");
      const ok = await submitResponse(handoffId, text);
      showBadge(ok ? "Grok Link: synced to Grok Build ✓" : "Grok Link: sync failed", ok);
      if (ok) sessionStorage.removeItem(STORAGE_KEY);
    }, POLL_MS);
  })();
})();