@echo off
set "exe=iexpress.exe"

echo Compressing fonts with 7zip...
cd /d "%~dp0\W10Fonts"
if exist Fonts.7z del Fonts.7z
7za.exe a -t7z Fonts.7z .\Fonts\* -mx=9 >nul
cd /d "%~dp0"

echo Calling IExpress...
iexpress /N /Q .\W10Fonts.SED

:loopstart
for /f %%x in ('tasklist /NH /FI "IMAGENAME eq %exe%"') do if %%x == %exe% goto found
goto fin

:found
timeout /t 3 /nobreak >nul
goto loopstart

:fin
echo Build complete.
pause
