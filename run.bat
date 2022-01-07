@echo off
rem powerShell実行bat

rem 実行対象ps1ファイル名をセット
SET runPs1=WebRequest.ps1

rem powerShellから正確に戻り値を受け取れるようにコール
powershell -NoProfile -ExecutionPolicy Unrestricted ".\%runPs1%;exit $LASTEXITCODE"

echo.
echo 戻り値は「%ERRORLEVEL%」

pause