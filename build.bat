@echo off
setlocal EnableDelayedExpansion

set PROGFILES=%ProgramFiles%
if not "%ProgramFiles(x86)%" == "" set PROGFILES=%ProgramFiles(x86)%

REM Check if Visual Studio 2019 BuildTools are installed
set MSVCDIR="%PROGFILES%\Microsoft Visual Studio\2019"
set VCVARSALLPATH="%PROGFILES%\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvarsall.bat"
if exist %MSVCDIR% (
  if exist %VCVARSALLPATH% (
       echo Using Visual Studio 2019 BuildTools
    goto setup_env
  )
)

REM Check if Visual Studio 2019 is installed
set VCVARSALLPATH="%PROGFILES%\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat"
if exist %MSVCDIR% (
  if exist %VCVARSALLPATH% (
       echo Using Visual Studio 2019
    goto setup_env
  )
)

echo No compiler : Microsoft Visual Studio (2019 or BuildTools 2019) is installed.
goto end

:setup_env

echo Setting up environment

:begin

REM Setup path to helper bin
set ROOT_DIR="%CD%"
set RM="%CD%\bin\unxutils\rm.exe"
set CP="%CD%\bin\unxutils\cp.exe"
set MKDIR="%CD%\bin\unxutils\mkdir.exe"
set SEVEN_ZIP="%CD%\bin\7-zip\7za.exe"
set XIDEL="%CD%\bin\xidel\xidel.exe"

REM Housekeeping
%RM% -rf tmp_*
%RM% -rf deps_*
%RM% -rf third-party
%RM% -rf curl.zip
%RM% -rf build_*.txt

REM Get download url .Look under <blockquote><a type='application/zip' href='xxx'>
echo Get download url...
%XIDEL% https://curl.haxx.se/download.html -e "//a[@type='application/zip' and ends-with(@href, '.zip')]/@href" > tmp_url
set /p url=<tmp_url

REM exit on errors, else continue
if %errorlevel% neq 0 exit /b %errorlevel%

REM Download latest curl and rename to curl.zip
echo Downloading latest curl...
curl "https://curl.haxx.se%url%" -o curl.zip

REM Extract downloaded zip file to tmp_libcurl
%SEVEN_ZIP% x curl.zip -y -otmp_libcurl | FIND /V "ing  " | FIND /V "Igor Pavlov"

REM Get deps
curl "https://windows.php.net/downloads/php-sdk/deps/vs16/x64/zlib-1.2.11-vs16-x64.zip" -o tmp_zlib_x64.zip
curl "https://windows.php.net/downloads/php-sdk/deps/vs16/x86/zlib-1.2.11-vs16-x86.zip" -o tmp_zlib_x86.zip
curl -L "https://github.com/nghttp2/nghttp2/releases/download/v1.41.0/nghttp2-1.41.0.tar.xz" -o tmp_h2.txz

REM Extract deps
%SEVEN_ZIP% x tmp_zlib_x64.zip -y -odeps_x64 | FIND /V "ing  " | FIND /V "Igor Pavlov"
%SEVEN_ZIP% x tmp_zlib_x86.zip -y -odeps_x86 | FIND /V "ing  " | FIND /V "Igor Pavlov"
%SEVEN_ZIP% x tmp_h2.txz -y | FIND /V "ing  " | FIND /V "Igor Pavlov"
%SEVEN_ZIP% x tmp_h2.tar -y -otmp_h2 | FIND /V "ing  " | FIND /V "Igor Pavlov"

REM Fix names
%CP% deps_x64\lib\zlib_a.lib deps_x64\lib\zlib.lib
%CP% deps_x86\lib\zlib_a.lib deps_x86\lib\zlib.lib

REM build nghttp2
cd /d tmp_h2\nghttp2-*
%MKDIR% build_x64
%MKDIR% build_x86

cd build_x64
call %VCVARSALLPATH% x64
cmake -DCMAKE_BUILD_TYPE=Release DENABLE_LIB_ONLY=1 -DENABLE_STATIC_LIB=1 -DENABLE_SHARED_LIB=0 -DCMAKE_INSTALL_MESSAGE=NEVER ..
cmake --build . --config Release
%CP% lib\Release\nghttp2.lib "%ROOT_DIR%\deps_x64\lib\nghttp2_static.lib"
%CP% -r ..\lib\includes\nghttp2 "%ROOT_DIR%\deps_x64\include\."

cd ..\build_x86
call %VCVARSALLPATH% x86
cmake -G "Visual Studio 16 2019" -A Win32 -DCMAKE_BUILD_TYPE=Release DENABLE_LIB_ONLY=1 -DENABLE_STATIC_LIB=1 -DENABLE_SHARED_LIB=0 -DCMAKE_INSTALL_MESSAGE=NEVER ..
cmake --build . --config Release
%CP% lib\Release\nghttp2.lib "%ROOT_DIR%\deps_x86\lib\nghttp2_static.lib"
%CP% -r ..\lib\includes\nghttp2 "%ROOT_DIR%\deps_x86\include\."

REM Disable unneeded stuff
cd /d "%ROOT_DIR%\tmp_libcurl\curl-*\lib"
TYPE "%ROOT_DIR%\curl_disable.txt" >> setup-win32.h

:buildnow

REM Build!
set VCVERSION = 9
cd tmp_libcurl\curl-*\winbuild

call %VCVARSALLPATH% x86
cd /d "%ROOT_DIR%\tmp_libcurl\curl-*\winbuild"

echo Compiling dll-release-x86 version...
nmake /f Makefile.vc mode=dll VC=%VCVERSION% DEBUG=no GEN_PDB=no MACHINE=x86 WITH_DEVEL="%ROOT_DIR%/deps_x86" WITH_ZLIB=static WITH_NGHTTP2=static

call %VCVARSALLPATH% x64
cd /d "%ROOT_DIR%\tmp_libcurl\curl-*\winbuild"

echo Compiling dll-release-x64 version...
nmake /f Makefile.vc mode=dll VC=%VCVERSION% DEBUG=no GEN_PDB=no MACHINE=x64 WITH_DEVEL="%ROOT_DIR%/deps_x64" WITH_ZLIB=static WITH_NGHTTP2=static

REM Copy compiled *.dll files to third-party\lib\dll-release folder
cd %ROOT_DIR%\tmp_libcurl\curl-*\builds\libcurl-vc-x86-release-dll-zlib-static-ipv6-sspi-winssl-nghttp2-static
%MKDIR% -p %ROOT_DIR%\third-party\libcurl\lib\dll-release-x86
%CP% bin\*.dll %ROOT_DIR%\third-party\libcurl\lib\dll-release-x86

REM Copy compiled *.dll files to third-party\lib\dll-release folder
cd %ROOT_DIR%\tmp_libcurl\curl-*\builds\libcurl-vc-x64-release-dll-zlib-static-ipv6-sspi-winssl-nghttp2-static
%MKDIR% -p %ROOT_DIR%\third-party\libcurl\lib\dll-release-x64
%CP% bin\*.dll %ROOT_DIR%\third-party\libcurl\lib\dll-release-x64

REM Copy include folder to third-party folder
%CP% -rf include %ROOT_DIR%\third-party\libcurl

REM Cleanup temporary file/folders
cd %ROOT_DIR%
%RM% -rf tmp_*

:end
exit /b
