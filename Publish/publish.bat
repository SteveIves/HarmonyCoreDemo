@echo off

:: Publishes the Harmony Core service for deployment to either Windows or Linux

:: If we have no parameters, show usage info
if /i "%1" == "" (
    echo.
    echo Usage: publish WINDOWS [DEBUG]
    echo        publish LINUX   [DEBUG]
    echo.
    goto :eof
)

setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

set SolutionDir=%~dp0..\
pushd "%SolutionDir%"

set SYNCMPOPT=-WD=316

if not defined RPSMFIL set RPSMFIL="%SolutionDir%Repository\rpsmain.ism"
if not defined RPSTFIL set RPSTFIL="%SolutionDir%Repository\rpstext.ism"

:: Are we targeting Windows or Linux?
set TARGET=
if /i "%1" == "WINDOWS" set TARGET=WINDOWS
if /i "%1" == "LINUX"   set TARGET=LINUX
if not defined TARGET (
    echo.
    echo ERROR: You must specify a target platform: WINDOWS or LINUX
    echo.
    goto fail
)

:: Check for dos2unix tool
set DOS2UNIXEXE=%SolutionDir%Tools\dos2unix.exe
if not exist "%DOS2UNIXEXE%" (
    echo.
    echo ERROR: The dos2unix tool is not present!
    echo.
    goto fail
)

:: Check for 7-zip
set SEVENZIPEXE=%ProgramW6432%\7-zip\7z.exe
if not exist "%SEVENZIPEXE%" (
    echo.
    echo ERROR: 7-zip is not installed!
    echo.
    goto fail
)

:: Set up the deployment directory
set DeployDir=%SolutionDir%PUBLISH\%TARGET%

:: Release or Debug?
set CONFIGURATION=Release
if /i "%2" == "DEBUG" set CONFIGURATION=Debug

set HC_PLATFORM=AnyCPU

:: Set the hat=rmony core runtime based on the target
if "%TARGET%" == "WINDOWS" set HC_RUNTIME=win-x64
if "%TARGET%" == "LINUX"   set HC_RUNTIME=linux-x64

:: Set the traditional bridge platform based on the target
if "%TARGET%" == "WINDOWS" set BRIDGE_PLATFORM=x64
if "%TARGET%" == "LINUX"   set BRIDGE_PLATFORM=linux64

:: If there is an old PUBLISH folder, delete it\
if exist "%DeployDir%\." rmdir /S /Q "%DeployDir%" > nul 2>&1
if exist "%DeployDir%\." (
    echo.
    echo ERROR: Failed to delete deployment directory %DeployDir%
    echo.
    goto fail
)

:: Set release date/time stamp

for /f %%i in ('powershell -command "[DateTime]::UtcNow.ToString('yyyyMMdd-HHmmss')"') do set DateTimeStamp=%%i

:: Determine ZIP file name

set ZIP_FILE=%SolutionDir%Publish\ZipFiles\HarmonyCore-%TARGET%-%DateTimeStamp%.zip

:: ---------------------------------------------------------------------------
:: Build Traditional Bridge code

echo.
echo Building Traditional Bridge code in %CONFIGURATION% mode

pushd TraditionalBridge

msbuild ^
    -target:Rebuild ^
    -p:Platform=%BRIDGE_PLATFORM% ^
    -p:Configuration=%CONFIGURATION% ^
    -verbosity:minimal ^
    -nodeReuse:false ^
    -nologo ^
    TraditionalBridge.synproj

if errorlevel 0 (
    echo.
    echo Traditional Bridge build complete
    echo.
) else (
    echo.
    echo ERROR: Traditional Bridge build failed!
    echo.
    popd
    goto fail
)

popd

:: ---------------------------------------------------------------------------
:: Build and publish the Harmony Core service

echo.
echo Publishing Harmony Core service in %CONFIGURATION% mode
echo.

pushd Services.Host

dotnet publish ^
    -p:platform=%HC_PLATFORM% ^
    -p:PublishTrimmed=false ^
    --configuration %CONFIGURATION% ^
    --runtime %HC_RUNTIME% ^
    --self-contained true ^
    --output "%DeployDir%" ^
    --no-restore ^
    --verbosity minimal ^
    -nologo

if errorlevel 0 (
    echo.
    echo Harmony Core publish complete
    echo.
) else (
    echo.
    echo ERROR: Harmony Core publish failed!
    echo.
    popd
    goto fail
)

popd

:: Include the Traditional Bridge host program

if exist TraditionalBridge\EXE\host.dbr (
    echo Providing traditional bridge host application
    copy /y TraditionalBridge\EXE\host.dbr "%DeployDir%" > nul 2>&1
) else (
    echo ERROR: Traditional Bridge file host.dbr not found!
    goto fail
)

if exist TraditionalBridge\EXE\host.dbp (
    copy /y TraditionalBridge\EXE\host.dbp "%DeployDir%" > nul 2>&1
) else (
    echo ERROR: Traditional bridge file host.dbp not found!
    goto fail
)

:: Provide launch script and other files (Windows)

if "%TARGET%"=="WINDOWS" (

    if exist TraditionalBridge\launch.bat (
        echo Providing traditional bridge launch script
        copy /y TraditionalBridge\launch.bat "%DeployDir%" > nul 2>&1
    ) else (
        echo ERROR: Traditional bridge launch script not found!
        goto fail
    )
)

:: Provide launch script and other files (Linux)

if "%TARGET%"=="LINUX" (

    if exist TraditionalBridge\launch (
        echo Providing traditional bridge launch script
        copy /y TraditionalBridge\launch "%DeployDir%" > nul 2>&1
        "%DOS2UNIXEXE%" -q "%DeployDir%\launch"
    ) else (
        echo ERROR: Traditional bridge launch script not found!
        goto fail
    )

    :: Provide service control scripts

    echo Providing service configuration and control scripts

    copy /y "%SolutionDir%Publish\LinuxFiles\startserver" "%DeployDir%\startserver" > nul 2>&1
    "%DOS2UNIXEXE%" -q "%DeployDir%\startserver"

    copy /y "%SolutionDir%Publish\LinuxFiles\stopserver" "%DeployDir%\stopserver" > nul 2>&1
    "%DOS2UNIXEXE%" -q "%DeployDir%\stopserver"

    copy /y "%SolutionDir%Publish\LinuxFiles\startserver.*.config" "%DeployDir%" > nul 2>&1
    "%DOS2UNIXEXE%" -q "%DeployDir%\startserver.*.config"

    :: Provide check and dump scripts

    echo Providing useful utility scripts

    copy /y "%SolutionDir%Publish\LinuxFiles\check" "%DeployDir%\check" > nul 2>&1
    "%DOS2UNIXEXE%" -q "%DeployDir%\check"

    copy /y "%SolutionDir%Publish\LinuxFiles\dump" "%DeployDir%\dump" > nul 2>&1
    "%DOS2UNIXEXE%" -q "%DeployDir%\dump"
)

:: Provide a SSL certificate

echo Providing a self-signed SSL certificate

dotnet dev-certs https --export-path "%DeployDir%\Services.Host.pfx" --password p@ssw0rd --quiet

if not exist "%DeployDir%\Services.Host.pfx" (
    echo ERROR: Failed to export https developer certificate Services.Host.pfx
    goto fail
)

:: Provide XML documentation files

echo Providing XML documentation files

if not exist "%DeployDir%\XmlDoc" mkdir "%DeployDir%\XmlDoc"

if exist "XmlDoc\Services.xml" ( 
    copy /y "XmlDoc\Services.xml" "%DeployDir%\XmlDoc" > nul 2>&1
    "%DOS2UNIXEXE%" -q "%DeployDir%\XmlDoc\Services.xml"
)

if exist "XmlDoc\Services.Controllers.xml" (
    copy /y "XmlDoc\Services.Controllers.xml" "%DeployDir%\XmlDoc" > nul 2>&1
    "%DOS2UNIXEXE%" -q "%DeployDir%\XmlDoc\Services.Controllers.xml"
)

if exist "XmlDoc\Services.Models.xml" (
  copy /y "XmlDoc\Services.Models.xml" "%DeployDir%\XmlDoc" > nul 2>&1
  "%DOS2UNIXEXE%" -q "%DeployDir%\XmlDoc\Services.Models.xml"
)

:: Create the ZIP file

if exist "%DeployDir%\." (
    echo.
    echo Creating distribution %ZIP_FILE%
    pushd "%DeployDir%"
    "%SEVENZIPEXE%" a -r -bso0 -bsp0 "%ZIP_FILE%" *

    if ERRORLEVEL 0 (
        echo.
        echo Harmony Core publish complete
    ) else (
        echo ERROR: Failed to create zip file! The published application is in %DeployDir%
        echo.
        echo Harmony Core publish complete
        popd
        goto fail
    )
    popd
)

:done
popd
endlocal
exit /b 0

:fail
popd
endlocal
exit /b 1
