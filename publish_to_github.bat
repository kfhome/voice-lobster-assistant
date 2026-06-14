@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ============================================================
rem Publish the voice assistant folder to GitHub.
rem You only need to enter:
rem   1. GitHub username
rem   2. GitHub Personal Access Token
rem
rem GitHub does NOT allow account password for git push.
rem The password field here means a Personal Access Token.
rem Token permissions needed:
rem   - Classic token: repo
rem   - Fine-grained token: Contents Read and write
rem ============================================================

set "REPO_NAME=hr-voice-lobster-assistant"
set "REPO_DESC=Local IIS Classic ASP voice assistant"
set "WORK_DIR=%~dp0"
set "TOKEN_FILE=%TEMP%\github_token_voice_publish.txt"

cd /d "%WORK_DIR%" || goto :fail_cd

echo.
echo === Publish voice assistant to GitHub ===
echo Local folder: %CD%
echo Repository : %REPO_NAME%
echo Visibility : private
echo.

set /p "GITHUB_USER=GitHub username: "
if "%GITHUB_USER%"=="" goto :empty_user

powershell -NoProfile -ExecutionPolicy Bypass -Command "$p=Read-Host 'GitHub token' -AsSecureString; $b=[Runtime.InteropServices.Marshal]::SecureStringToBSTR($p); try{[Runtime.InteropServices.Marshal]::PtrToStringBSTR($b)} finally{[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($b)}" > "%TOKEN_FILE%"
set /p GITHUB_TOKEN=<"%TOKEN_FILE%"
del /q "%TOKEN_FILE%" >nul 2>nul
if "%GITHUB_TOKEN%"=="" goto :empty_token

where git >nul 2>nul || goto :missing_git
where node >nul 2>nul || goto :missing_node
where powershell >nul 2>nul || goto :missing_powershell

if not exist ".git" (
  echo Initializing git repository...
  git init || goto :failed
)

echo.
echo === Basic checks ===
node --check voice_server.js || goto :failed
powershell -NoProfile -ExecutionPolicy Bypass -Command "$s=Get-Content -LiteralPath 'xiaozhi.asp' -Raw -Encoding UTF8; if($s -notmatch '<script>'){throw 'xiaozhi.asp script tag not found'}; Write-Host 'xiaozhi.asp script tag found'" || goto :failed

echo.
echo === Commit local changes if needed ===
git status --short
set "HAS_CHANGES="
for /f %%c in ('git status --short') do set "HAS_CHANGES=1"
if defined HAS_CHANGES (
  git add . || goto :failed
  git commit -m "Prepare voice assistant release"
)

echo.
echo === Create GitHub repository if needed ===
set "GITHUB_USER=%GITHUB_USER%"
set "GITHUB_TOKEN=%GITHUB_TOKEN%"
set "REPO_NAME=%REPO_NAME%"
set "REPO_DESC=%REPO_DESC%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $headers=@{Authorization='Bearer '+$env:GITHUB_TOKEN; Accept='application/vnd.github+json'; 'User-Agent'='voice-publish-script'}; $body=@{name=$env:REPO_NAME; description=$env:REPO_DESC; private=$true} | ConvertTo-Json; try { Invoke-RestMethod -Method Post -Uri 'https://api.github.com/user/repos' -Headers $headers -Body $body -ContentType 'application/json' | Out-Null; Write-Host 'Repository created.' } catch { if ($_.Exception.Response -and [int]$_.Exception.Response.StatusCode -eq 422) { Write-Host 'Repository already exists, continuing.' } else { throw } }" || goto :failed

echo.
echo === Configure remote ===
git remote remove origin >nul 2>nul
git remote add origin "https://github.com/%GITHUB_USER%/%REPO_NAME%.git" || goto :failed
git branch -M main || goto :failed

echo.
echo === Push to GitHub ===
git -c credential.helper= push "https://%GITHUB_USER%:%GITHUB_TOKEN%@github.com/%GITHUB_USER%/%REPO_NAME%.git" main:main || goto :push_failed
git branch --set-upstream-to=origin/main main >nul 2>nul

echo.
echo Done.
echo https://github.com/%GITHUB_USER%/%REPO_NAME%
echo.
pause
exit /b 0

:fail_cd
echo Cannot enter script folder: %WORK_DIR%
exit /b 1

:empty_user
echo GitHub username cannot be empty.
exit /b 1

:empty_token
echo GitHub token cannot be empty.
exit /b 1

:missing_git
echo git was not found. Install Git for Windows first.
exit /b 1

:missing_node
echo node was not found. Install Node.js 18 or newer first.
exit /b 1

:missing_powershell
echo PowerShell was not found.
exit /b 1

:push_failed
echo.
echo Push failed. Check that the token has repository Contents read/write permission.
echo Repository URL should be:
echo https://github.com/%GITHUB_USER%/%REPO_NAME%
exit /b 1

:failed
echo.
echo Publish failed.
exit /b 1
