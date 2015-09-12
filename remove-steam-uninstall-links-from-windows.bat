REM http://furgelnod.com/2014/removing-steam-games-from-programs-and-features-windows/

@title Remove Steam Uninstall Links From Windows
@net session >nul 2>&1
@if %errorlevel% == 0 (
    @for /F "delims=" %%a in ('reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall ^| findstr /C:"Steam App"') do @reg delete "%%a" /f
    @for /F "delims=" %%a in ('reg query HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall ^| findstr /C:"Steam App"') do @reg delete "%%a" /f
    @echo Success!
    @pause>nul
) else (
    @echo You do not have Administrator Priveleges. Try right clicking and choosing 'run as administrator '
    @pause>nul
)
