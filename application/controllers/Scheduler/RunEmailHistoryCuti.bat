@echo off
setlocal

rem URL harus berupa teks URL biasa, bukan format Markdown [URL](URL).
set "ENDPOINT_URL=http://127.0.0.1:8010/ESBA/Scheduler/EmailHistoryCuti/send"

rem %~dp0 memastikan log tersimpan di folder yang sama dengan file BAT.
set "LOG_FILE=%~dp0EmailHistoryCutiScheduler.log"

echo.>> "%LOG_FILE%"
echo [%date% %time%] Memanggil %ENDPOINT_URL%>> "%LOG_FILE%"

rem Gunakan Windows PowerShell karena curl.exe mungkin tidak tersedia di server lama.
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "try { $response = Invoke-WebRequest -UseBasicParsing -Uri '%ENDPOINT_URL%' -TimeoutSec 1800; Write-Output $response.Content; exit 0 } catch { Write-Error $_.Exception.Message; exit 1 }" >> "%LOG_FILE%" 2>&1
set "EXIT_CODE=%ERRORLEVEL%"

echo.>> "%LOG_FILE%"
if "%EXIT_CODE%"=="0" (
    echo [%date% %time%] Selesai dengan status berhasil.>> "%LOG_FILE%"
) else (
    echo [%date% %time%] Gagal dengan exit code %EXIT_CODE%.>> "%LOG_FILE%"
)

endlocal & exit /b %EXIT_CODE%
