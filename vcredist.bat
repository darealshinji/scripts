@echo off
rem download and install all important VC runtime files

if not exist wget.exe (
  echo Downloading wget ...
  PowerShell -Command "& {Invoke-WebRequest -OutFile wget.exe -Uri https://eternallybored.org/misc/wget/1.20.3/64/wget.exe}" || goto :error
)

wget.exe --no-hsts -c -O vc_redist_2015-2019.x64.exe https://aka.ms/vs/16/release/vc_redist.x64.exe || goto :error
wget.exe --no-hsts -c -O vc_redist_2015-2019.x86.exe https://aka.ms/vs/16/release/vc_redist.x86.exe || goto :error

wget.exe --no-hsts -c -O vc_redist_2013.x64.exe https://aka.ms/highdpimfc2013x64enu || goto :error
wget.exe --no-hsts -c -O vc_redist_2013.x86.exe https://aka.ms/highdpimfc2013x86enu || goto :error

wget.exe --no-hsts -c -O vc_redist_2012.x64.exe https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x64.exe || goto :error
wget.exe --no-hsts -c -O vc_redist_2012.x86.exe https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x86.exe || goto :error

wget.exe --no-hsts -c -O vc_redist_2010.x64.exe https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x64.exe || goto :error
wget.exe --no-hsts -c -O vc_redist_2010.x86.exe https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x86.exe || goto :error

wget.exe --no-hsts -c -O vc_redist_2008.x64.exe https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x64.exe || goto :error
wget.exe --no-hsts -c -O vc_redist_2008.x86.exe https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x86.exe || goto :error

vc_redist_2015-2019.x64.exe /install /passive /norestart || goto :error
vc_redist_2015-2019.x86.exe /install /passive /norestart || goto :error
vc_redist_2013.x64.exe /install /passive /norestart || goto :error
vc_redist_2013.x86.exe /install /passive /norestart || goto :error
vc_redist_2012.x64.exe /install /passive /norestart || goto :error
vc_redist_2012.x86.exe /install /passive /norestart || goto :error
vc_redist_2010.x64.exe /install /passive /norestart || goto :error
vc_redist_2010.x86.exe /install /passive /norestart || goto :error
vc_redist_2008.x64.exe || goto :error
vc_redist_2008.x86.exe || goto :error

pause
exit

:error
echo Failed with error #%errorlevel%.
pause
exit /b %errorlevel%
