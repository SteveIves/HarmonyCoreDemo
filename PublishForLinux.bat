@echo off

rem This batch file publishes a Harmony Core service for deployment to a Linux hosting system.

rem Display help?
if /i "%1" == "HELP" (
    echo.
    echo Usage: "publish [DEBUG|RELEASE] [PublishFolder] [ZipFileSpec] [ReleaseTag]"
    echo.
    goto :eof
)

setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

set SolutionDir=%~dp0
pushd "%SolutionDir%"

set SYNCMPOPT=-WD=316

if not defined RPSMFIL set RPSMFIL=..\files\rpt\tmaxmain.ism
if not defined RPSTFIL set RPSTFIL=..\files\rpt\tmaxtext.ism

set DeployDir=%SolutionDir%PUBLISH
set PLATFORM=linux
set RUNTIME=linux-x64

set BUILD_CONGIGURATION=Release
if /i "%1" == "DEBUG" set BUILD_CONGIGURATION=Debug

rem If we were passed a deployment directory, use it
if not "%2" == "" set DeployDir=%2

rem If we were passed a release tag, use it
if not "%4" == "" set RELEASE_TAG=%4

rem If there is an old PUBLISH folder, delete it\
if exist "%DeployDir%\." rmdir /S /Q "%DeployDir%" > nul 2>&1
if exist "%DeployDir%\." (
    echo ERROR: Failed to delete deployment directory %DeployDir%
    goto :fail
)

rem The dotnet publish command will not build the TraditionalBridge project
rem so first we'll build that to make we have the latest code built.

echo.
echo Building Traditional Bridge code in %BUILD_CONGIGURATION% mode

pushd TraditionalBridge

msbuild -target:Rebuild -p:Platform=linux64 -p:Configuration=%BUILD_CONGIGURATION% -verbosity:minimal -nodeReuse:false -nologo TraditionalBridge.synproj
if errorlevel 0 (
    echo.
    echo Traditional Bridge build complete
    popd
) else (
    echo.
    echo ERROR: Traditional Bridge build failed!
    popd
    goto fail
)

rem Build and publish the application

echo.
echo Building Harmony Core code in %BUILD_CONGIGURATION% mode
echo.

pushd Services.Host

dotnet publish -nologo -p:platform=AnyCPU --configuration %BUILD_CONGIGURATION% ^
  --runtime %RUNTIME% --self-contained true --output "%DeployDir%" ^
  --no-restore -p:PublishTrimmed=false --verbosity minimal

if errorlevel 0 (
    echo.
    echo Harmony Core build complete
    echo.
) else (
    echo ERROR: Harmony Core build failed!
    popd
    goto fail
)

popd

rem Include the Traditional Bridge host program and launch script

if exist TraditionalBridge\EXE\host.dbr (
    echo Providing traditional bridge host application
    copy /y TraditionalBridge\EXE\host.dbr "%DeployDir%" > nul 2>&1
) else (
    echo ERROR: Traditional Bridge file host.dbr not found!
    popd
    goto fail
)

if exist TraditionalBridge\EXE\host.dbp (
    copy /y TraditionalBridge\EXE\host.dbp "%DeployDir%" > nul 2>&1
) else (
    echo ERROR: Traditional bridge file host.dbp not found!
    popd
    goto fail
)

if exist TraditionalBridge\launch (
    echo Providing traditional bridge launch script
    copy /y TraditionalBridge\launch "%DeployDir%" > nul 2>&1
    "%SolutionDir%dos2unix" "%DeployDir%\launch" > nul 2>&1
) else (
    echo ERROR: Traditional bridge file launch not found!
    popd
    goto fail
)

rem Provide service control scripts

echo Providing service configuration and control scripts

copy /Y "%SolutionDir%\startserver" "%DeployDir%\startserver" > nul 2>&1
"%SolutionDir%dos2unix" "%DeployDir%\startserver" > nul 2>&1

copy /Y "%SolutionDir%\stopserver" "%DeployDir%\stopserver" > nul 2>&1
"%SolutionDir%dos2unix" "%DeployDir%\stopserver" > nul 2>&1

copy /Y "%SolutionDir%\startserver.*.config" "%DeployDir%" > nul 2>&1
"%SolutionDir%dos2unix" "%DeployDir%\startserver.*.config" > nul 2>&1

rem Provide check and dump scripts

echo Providing useful utility scripts

copy /Y "%SolutionDir%\check" "%DeployDir%\check" > nul 2>&1
"%SolutionDir%dos2unix" "%DeployDir%\check" > nul 2>&1

copy /Y "%SolutionDir%\dump" "%DeployDir%\dump" > nul 2>&1
"%SolutionDir%dos2unix" "%DeployDir%\dump" > nul 2>&1

rem Provide a SSL certificate

echo Providing a self-signed SSL certificate

dotnet dev-certs https --export-path "%DeployDir%\Services.Host.pfx" --password p@ssw0rd --quiet

if not exist "%DeployDir%\Services.Host.pfx" (
    echo ERROR: Failed to export https developer certificate Services.Host.pfx
    goto fail
)

rem Provide XML documentation files

echo Providing XML documentation files

if not exist "%DeployDir%\XmlDoc" mkdir "%DeployDir%\XmlDoc"

if exist "XmlDoc\Services.xml" ( 
    copy /y "XmlDoc\Services.xml" "%DeployDir%\XmlDoc" > nul 2>&1
    "%SolutionDir%dos2unix" "%DeployDir%\XmlDoc\Services.xml" > nul 2>&1
)

if exist "XmlDoc\Services.Controllers.xml" (
    copy /y "XmlDoc\Services.Controllers.xml" "%DeployDir%\XmlDoc" > nul 2>&1
    "%SolutionDir%dos2unix" "%DeployDir%\XmlDoc\Services.Controllers.xml" > nul 2>&1
)

if exist "XmlDoc\Services.Models.xml" (
  copy /y "XmlDoc\Services.Models.xml" "%DeployDir%\XmlDoc" > nul 2>&1
  "%SolutionDir%dos2unix" "%DeployDir%\XmlDoc\Services.Models.xml" > nul 2>&1
)

rem Determine ZIP file name

set HC_PUBLISH_ZIP_FILE=%SolutionDir%..\..\HarmonyCore-%DISTRIBUTION_TIMESTAMP%.zip

if not "%3"=="" set HC_PUBLISH_ZIP_FILE=%3

rem If the zip file exists, delete it

if exist "%HC_PUBLISH_ZIP_FILE%" del /q "%HC_PUBLISH_ZIP_FILE%"

rem Do we have 7-zip?

if exist "%DeployDir%\." (
    if exist "%ProgramW6432%\7-Zip\7z.exe" (
        echo.
        echo Zipping HarmonyCore binaries to %HC_PUBLISH_ZIP_FILE%
        pushd "%DeployDir%"
        "%ProgramW6432%\7-Zip\7z.exe" a -r -bso0 -bsp0 "%HC_PUBLISH_ZIP_FILE%" *

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
    ) else (
        echo WARNING: Unable to zip the deployment directory because 7-zip is not installed! The published application is in %DeployDir%
        echo.
        echo Harmony Core publish complete
    )
)

rem If the ZIP was successful, delete the publish folder
rem Don't do it if we were passed a zip file from the TireMax publish, as it will do the cleanup.
if "%3" == "" (
    if exist "%HC_PUBLISH_ZIP_FILE%" rmdir /S /Q "%DeployDir%" > nul 2>&1
)

:done
popd
endlocal
exit /b 0

:fail
popd
endlocal
exit /b 1
