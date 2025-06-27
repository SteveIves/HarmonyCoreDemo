@echo off
setlocal EnableDelayedExpansion

echo.
echo Generating Harmony Core Traditional Bridge code
echo.

pushd %~dp0

echo.> regen_bridge_last.bat
echo rem   ****************************************>> regen_bridge_last.bat
echo rem   *** DO NOT VERSION CONTROL THIS FILE ***>> regen_bridge_last.bat
echo rem   ****************************************>> regen_bridge_last.bat
echo.>> regen_bridge_last.bat
echo rem CodeGen commands used for last Bridge regen:>> regen_bridge_last.bat

rem Configure the code generation environment
call regen_config.bat

rem ================================================================================
rem Generate TraditionalBridge / xfServerPlus Migration Code

if DEFINED ENABLE_XFSERVERPLUS_MIGRATION (

  rem Generate code for REST services
  set MAKE_ODATA_CONTROLLER=YES
  set MAKE_SIGNALR_HUB=NO
  for %%x in (%SMC_INTERFACES_REST%) do (
    rem if "%%x" == "asp" (set METHODS_TO_EXCLUDE=-mexclude ASP_LOGIN)
    rem set CUSTOM_IMPLEMENTATION=
    rem set CUSTOM_NET_MODELS=
    call :GenerateInterfaceCode %%x
  )

rem  rem Generate code for SIGNALR services
rem  if DEFINED ENABLE_SIGNALR (
rem    set MAKE_ODATA_CONTROLLER=NO
rem    set MAKE_SIGNALR_HUB=YES
rem    for %%x in (%SMC_INTERFACES_SIGNALR%) do (
rem      rem if "%%x" == "asp" (set METHODS_TO_EXCLUDE=-mexclude ASP_LOGIN)
rem      call :GenerateInterfaceCode %%x
rem    )
rem  )

rem  rem Generate code for INTERNAL services
rem  set MAKE_ODATA_CONTROLLER=NO
rem  set MAKE_SIGNALR_HUB=NO
rem  for %%x in (%SMC_INTERFACES_INTERNAL%) do (
rem    rem if "%%x" == "asp" (set METHODS_TO_EXCLUDE=-mexclude ASP_LOGIN)
rem    call :GenerateInterfaceCode %%x
rem  )
rem
rem  rem Generate the main (multi-interface capable) dispatcher
rem  call :GenerateMainDispatcher %SMC_INTERFACES_REST% %SMC_INTERFACES_SIGNALR% %SMC_INTERFACES_INTERNAL%
)

echo.
echo DONE!
echo.
popd
endlocal
exit /b 0

:error
echo *** CODE GENERATION INCOMPLETE ***
popd
endlocal
exit /b 1

rem ================================================================================
:GenerateInterfaceCode

  echo.
  echo ************************************************************************
  echo Generating Traditional Bridge code for interface %1
  echo rem Generating Traditional Bridge code for interface %1 >> regen_bridge_last.bat
  echo.
  echo Generating interface method stubs [Traditional]

  if defined ENABLE_XFSERVERPLUS_METHOD_STUBS (
    set command=codegen ^
-smc %SMC_XML_FILE% ^
-interface %1 ^
-t  InterfaceMethodStubs ^
-i  Templates\TraditionalBridge ^
-o  %TraditionalBridgeProject%\source\stubs ^
-ut MODELS_NAMESPACE=%TraditionalBridgeProject%.Models ^
%STDOPTS% -tweaks PARAMDEFSTR
    echo !command! >> regen_bridge_last.bat
    !command!
  )

  echo.
  echo Generating interface method dispatcher classes [Traditional]

  set command=codegen ^
-smc %SMC_XML_FILE% ^
-interface %1 ^
-t %BRIDGE_DISPATCHER_TEMPLATE% ^
-i Templates\TraditionalBridge ^
-o %TraditionalBridgeProject%\source\dispatchers ^
-n %TraditionalBridgeProject%.Dispatchers ^
-ut MODELS_NAMESPACE=%TraditionalBridgeProject%.Models ^
%STDOPTS% -tweaks PARAMDEFSTR
  echo !command! >> regen_bridge_last.bat
  !command!
  if ERRORLEVEL 1 goto error

  echo.
  echo Generating interface dispatcher classes [Traditional]

  set command=codegen ^
-smc %SMC_XML_FILE% ^
-interface %1 ^
-t InterfaceDispatcher ^
-i Templates\TraditionalBridge ^
-o %TraditionalBridgeProject%\source\dispatchers ^
-n %TraditionalBridgeProject%.Dispatchers ^
-ut MODELS_NAMESPACE=%TraditionalBridgeProject%.Models ^
%STDOPTS%
  echo !command! >> regen_bridge_last.bat
  !command!
  if ERRORLEVEL 1 goto error

  echo.
  echo Generating interface data model classes [Traditional]

  set command=codegen ^
-smcstrs %SMC_XML_FILE% ^
-interface %1 ^
-t TraditionalModel TraditionalMetadata ^
-i Templates\TraditionalBridge ^
-o %TraditionalBridgeProject%\source\models ^
-n %TraditionalBridgeProject%.Models ^
%STDOPTS%
  echo !command! >> regen_bridge_last.bat
  !command!
  if ERRORLEVEL 1 goto error

  echo.
  echo Generating code to initialize metadata [Traditional]

  set command=codegen ^
-smcstrs %SMC_XML_FILE% -ms ^
-interface %1 ^
-t InterfaceDispatcherCustom ^
-i Templates\TraditionalBridge ^
-o %TraditionalBridgeProject%\source\dispatchers ^
-n %TraditionalBridgeProject%.Dispatchers ^
-ut MODELS_NAMESPACE=%TraditionalBridgeProject%.Models ^
-ut SMC_INTERFACE=%1 ^
%STDOPTS%
  echo !command! >> regen_bridge_last.bat
  !command!
  if ERRORLEVEL 1 goto error

  echo.
  echo Generating interface data model classes [.NET]

  if defined ENABLE_XFSERVERPLUS_MODEL_GENERATION (
    rem Ideally the same data classes are shared between OData and Traditional Bridge
    rem environments. But if OData is not being used, enable this to generate Models
    rem in the web service based on SMC content.
    set command=codegen ^
-smcstrs %SMC_XML_FILE% ^
-interface %1 ^
-t ODataModel ODataMetaData ^
-i Templates ^
-o %ModelsProject% ^
-n %ModelsProject% ^
%STDOPTS%
    echo !command! >> regen_bridge_last.bat
    !command!
    if ERRORLEVEL 1 goto error
  )

  rem --------------------------
  rem *** CUSTOM ***

  echo.
  echo Generating CUSTOM interface data model classes [.NET]

  if defined ENABLE_XFSERVERPLUS_MODEL_GENERATION (
    if defined CUSTOM_NET_MODELS (
      rem This section of the script is custom because of the specific requirements of
      rem the CreateWorkOrder and UpdateWorkOrder endpoints, where the heirarchical
      rem nature of the data must be dealt with on the .NET side.
      set command=codegen ^
-s %CUSTOM_NET_MODELS% ^
-t ODataModel ODataMetaData ^
-i Templates ^
-o %ModelsProject% ^
-n %ModelsProject% ^
%STDOPTS%
      echo !command! >> regen_bridge_last.bat
      !command!
      if ERRORLEVEL 1 goto error
    )
  )

  rem END OF CUSTOM
  rem --------------

  echo.
  echo Generating interface request/response DTO classes [.NET]

  set command=codegen ^
-smc %SMC_XML_FILE% ^
-interface %1 %CUSTOM_IMPLEMENTATION% ^
-t InterfaceServiceModels ^
-i Templates\TraditionalBridge ^
-o %ModelsProject% ^
-n %1 ^
-ut MODELS_NAMESPACE=%ModelsProject% ^
%STDOPTS%
  echo !command! >> regen_bridge_last.bat
  !command!
  if ERRORLEVEL 1 goto error

  echo.
  echo Generating interface service classes [.NET]

  set command=codegen ^
-smc %SMC_XML_FILE% ^
-interface %1  %CUSTOM_IMPLEMENTATION% ^
-t InterfaceService ^
-i Templates\TraditionalBridge ^
-o %ControllersProject% ^
-n %ControllersProject% ^
-ut MODELS_NAMESPACE=%ModelsProject% DTOS_NAMESPACE=%1 ^
%STDOPTS%
  echo !command! >> regen_bridge_last.bat
  !command!
  if ERRORLEVEL 1 goto error

  if "%MAKE_ODATA_CONTROLLER%" EQU "YES" (

    echo.
    echo Generating interface controller classes [.NET]

    set command=codegen ^
-smc %SMC_XML_FILE% ^
-interface %1 %METHODS_TO_EXCLUDE% ^
-t InterfaceController ^
-i Templates\TraditionalBridge ^
-o %ControllersProject% ^
-n %ControllersProject% ^
-ut MODELS_NAMESPACE=%ModelsProject% DTOS_NAMESPACE=%1 ^
%STDOPTS%
    echo !command! >> regen_bridge_last.bat
    !command!
    if ERRORLEVEL 1 goto error
  )

  if DEFINED ENABLE_POSTMAN_TESTS (

    echo.
    echo Generating interface Postman tests

    set command=codegen ^
-smc %SMC_XML_FILE% ^
-interface %1 %METHODS_TO_EXCLUDE% ^
-t InterfacePostmanTests ^
-i Templates\TraditionalBridge ^
-o . ^
%STDOPTS%
    echo !command! >> regen_bridge_last.bat
    !command!
    if ERRORLEVEL 1 goto error
  )

  if DEFINED ENABLE_RESTCLIENT_TESTS (

    echo.
    echo Generating interface Visual Studio Rest Client tests

    set command=codegen ^
-smc %SMC_XML_FILE% ^
-interface %1 %METHODS_TO_EXCLUDE% ^
-t InterfaceVsRestClientTests ^
-i Templates\TraditionalBridge ^
-o %VsTestClientTestsDir% ^
%STDOPTS%
    echo !command! >> regen_bridge_last.bat
    !command!
    if ERRORLEVEL 1 goto error
  )

  if DEFINED ENABLE_UNIT_TEST_GENERATION (

    echo.
    echo Generating interface unit tests and response type validation code [.NET]

    set command=codegen ^
-smc %SMC_XML_FILE% ^
-interface %1 %METHODS_TO_EXCLUDE% %CUSTOM_IMPLEMENTATION% ^
-t  InterfaceUnitTests ^
-i  Templates\TraditionalBridge ^
-o  %TestProject% -tf ^
-n  %TestProject% ^
-ut CLIENT_MODELS_NAMESPACE=%TestProject%.Models DTOS_NAMESPACE=%1 ^
%STDOPTS%
    echo !command! >> regen_bridge_last.bat
    !command!
    if ERRORLEVEL 1 goto error

    set command=codegen ^
-smc %SMC_XML_FILE% ^
-interface %1 %CUSTOM_IMPLEMENTATION% ^
-t  InterfaceTestRequests ^
-i  Templates\TraditionalBridge ^
-o  %TestValuesProject% ^
-n  %TestValuesProject% ^
-ut MODELS_NAMESPACE=%ModelsProject% ^
%STDOPTS%
    echo !command! >> regen_bridge_last.bat
    !command!
    if ERRORLEVEL 1 goto error
  )

  if DEFINED ENABLE_TYPESCRIPT_GENERATION (

    if not exist "%SolutionDir%TypeScript" mkdir "%SolutionDir%TypeScript"

    echo.
    echo Generating TypeScript interface methods for interface %1
    echo rem Generating TypeScript interface methods for interface %1 >> regen_bridge_last.bat

    set command=codegen ^
-smc %SMC_XML_FILE% ^
-interface %1  %METHODS_TO_EXCLUDE% ^
-t  TypeScriptInterfaceMethods ^
-i  Templates\TypeScript ^
-o  TypeScript ^
%STDOPTS%
    echo !command! >> regen_bridge_last.bat
    !command!
    if ERRORLEVEL 1 goto error

    echo.
    echo Generating TypeScript interface structures

    set command=codegen ^
-smcstrs %SMC_XML_FILE% -ms ^
-interface  %1  ^
-t  TypeScriptInterfaceStructures ^
-i  Templates\TypeScript ^
-o  TypeScript ^
%STDOPTS%
    echo !command! >> regen_bridge_last.bat
    !command!
    if ERRORLEVEL 1 goto error
  )

  if "%MAKE_SIGNALR_HUB%" EQU "YES" (

    echo.
    echo Generating SignalR code for interface %1
    echo rem Generating SignalR code for interface %1 >> regen_bridge_last.bat

    set command=codegen ^
-smc %SMC_XML_FILE% ^
-interface %1 %METHODS_TO_EXCLUDE% ^
-t SignalRHub ^
-i Templates\SignalR ^
-o %ControllersProject% ^
-n %ControllersProject% ^
-ut MODELS_NAMESPACE=%ModelsProject% DTOS_NAMESPACE=%1 ^
%STDOPTS%
    echo !command! >> regen_bridge_last.bat
    !command!
    if ERRORLEVEL 1 goto error

    if DEFINED ENABLE_UNIT_TEST_GENERATION (

      echo.
      echo Generating SignalR tests for interface %1

      set command=codegen ^
-smc %SMC_XML_FILE% ^
-interface %1 %METHODS_TO_EXCLUDE% ^
-t SignalRTests ^
-i Templates\SignalR ^
-o %TestProject%\UnitTests ^
-n %TestProject%.UnitTests ^
-ut SERVICES_NAMESPACE=%ServicesProject% MODELS_NAMESPACE=%ModelsProject% ^
%STDOPTS%
      echo !command! >> regen_bridge_last.bat
      !command!
      if ERRORLEVEL 1 goto error
    )
  )
)

GOTO:eof

rem ================================================================================
:GenerateMainDispatcher

  echo.
  echo Generating multi-interface dispatcher class [Traditional]
  echo rem Generating multi-interface dispatcher class [Traditional] >> regen_bridge_last.bat

  set command=codegen ^
-smc %SMC_XML_FILE% ^
-iloop %* ^
-t InterfaceSuperDispatcher  ^
-i Templates\TraditionalBridge ^
-o %TraditionalBridgeProject%\source\dispatchers ^
-n %TraditionalBridgeProject%.Dispatchers ^
-ut MODELS_NAMESPACE=%TraditionalBridgeProject%.Models ^
%STDOPTS%
  echo !command! >> regen_bridge_last.bat
  !command!
  if ERRORLEVEL 1 goto error

GOTO:eof
