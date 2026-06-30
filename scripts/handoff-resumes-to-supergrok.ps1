# Send both tailored resume drafts to SuperGrok for review and polish.
$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent

$cbp = Get-Content "C:\Users\Ranzh\OneDrive\WORK\CBPRobertsresume_CBP_Revised.docx" -ErrorAction SilentlyContinue
# Extract via python for reliability
$extract = python -c @"
from docx import Document
paths = [
    r'C:\Users\Ranzh\OneDrive\WORK\CBPRobertsresume_CBP_Revised.docx',
    r'C:\Users\Ranzh\OneDrive\WORK\CBPRobertsresume_Developer.docx',
]
for path in paths:
    print('FILE:', path)
    doc = Document(path)
    for p in doc.paragraphs:
        t = p.text.strip()
        if t:
            print(t)
    print('---END FILE---')
"@

$context = @"
CANDIDATE: Zachary H. Roberts | RanZhiSen@gmail.com | GitHub: memento-mori1984
Original resume: C:\Users\Ranzh\OneDrive\WORK\CBPRobertsresume.pdf
New drafts saved as:
- CBPRobertsresume_CBP_Revised.docx (law enforcement / CBP track)
- CBPRobertsresume_Developer.docx (software developer track)

TASK: Review BOTH resume drafts below. Polish wording, fix formatting issues (date/title spacing), strengthen bullets, ensure ATS compatibility. Do NOT invent employers, dates, or credentials.

RETURN:
1) Revised CBP resume (full text, ready to paste into Word)
2) Revised Developer resume (full text, ready to paste into Word)
3) Top 5 edits you made and why
4) Any red flags or gaps to address

--- RESUME DRAFTS ---

$extract
"@

$message = @'
Review and polish BOTH resume drafts in the context (CBP track and Developer track). Return the full revised text for each, a changelog of improvements, and any red flags. Keep all facts accurate — no fabricated experience.
'@

& (Join-Path $PSScriptRoot "handoff-and-wait.ps1") `
    -Message $message `
    -Task "resume-review-both" `
    -Context $context `
    -TimeoutSec 900 `
    -IntervalSec 5