param(
    [Parameter(Mandatory = $true)]
    [string]$PromptFile
)

$ErrorActionPreference = 'Stop'
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

if (!(Test-Path -LiteralPath $PromptFile)) {
    throw "Prompt file not found: $PromptFile"
}

$prompt = Get-Content -LiteralPath $PromptFile -Raw -Encoding UTF8
if ([string]::IsNullOrWhiteSpace($prompt)) {
    throw "Prompt is empty"
}

if ($prompt.Length -gt 4000) {
    $prompt = $prompt.Substring(0, 4000)
}

$env:USERPROFILE = 'C:\Users\admin'
$env:HOMEDRIVE = 'C:'
$env:HOMEPATH = '\Users\admin'
$env:APPDATA = 'C:\Users\admin\AppData\Roaming'
$env:LOCALAPPDATA = 'C:\Users\admin\AppData\Local'

$claude = 'C:\nvm4w\nodejs\claude.ps1'
if (!(Test-Path -LiteralPath $claude)) {
    $cmd = Get-Command claude -ErrorAction Stop
    $claude = $cmd.Source
}

$system = @'
You are a local voice assistant on this Windows computer.
Answer the user in concise Simplified Chinese.
If the user asks you to operate the computer, change files, or run commands, explain what you understand and what confirmation is needed. Do not claim that you already executed it.
'@

$fullPrompt = $system + "`nUser: " + $prompt

& $claude -p --output-format text --permission-mode dontAsk --model sonnet $fullPrompt
if ($LASTEXITCODE -ne 0) {
    throw "Claude exited with code $LASTEXITCODE"
}
