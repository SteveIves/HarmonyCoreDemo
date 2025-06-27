@echo off
setlocal EnableDelayedExpansion

echo.
echo Generating Harmony Core OData code
echo.

echo.> regen_odata_last.bat
echo rem   ****************************************>> regen_odata_last.bat
echo rem   *** DO NOT VERSION CONTROL THIS FILE ***>> regen_odata_last.bat
echo rem   ****************************************>> regen_odata_last.bat
echo.>> regen_odata_last.bat
echo rem CodeGen commands used for last OData regen:>> regen_odata_last.bat

pushd %~dp0

rem Configure the code generation environment
call regen_config.bat

rem ================================================================================================================================

if DEFINED ENABLE_ODATA_ENVIRONMENT (

  echo.
  echo ************************************************************************
  echo Generating Web API/OData CRUD environment
  echo rem Generating Web API/OData CRUD environment >> regen_odata_last.bat

  if NOT DEFINED EF_PROVIDER_MYSQL (

    echo.
    echo Generating model and metadata classes [.NET]

    set command=codegen ^
-s  %DATA_STRUCTURES% ^
-t  ODataModel ODataMetaData ^
-i  Templates ^
-o  %ModelsProject% ^
-n  %ModelsProject% ^
%STDOPTS%
    echo !command! >> regen_odata_last.bat
    !command!
    if ERRORLEVEL 1 goto error
  )

  echo.
  echo Generating controller classes [.NET]

  set command=codegen ^
-s  %DATA_STRUCTURES% ^
-t  ODataController ^
-i  Templates%TEMPLATESUBDIR% ^
-o  %ControllersProject% ^
-n  %ControllersProject% ^
%STDOPTS% -tweaks SQLNAMENO$
  echo !command! >> regen_odata_last.bat
  !command!
  if ERRORLEVEL 1 goto error

if DEFINED ENABLE_PROPERTY_ENDPOINTS (

  echo.
  echo Generating individual property endpoints [.NET]

  set command=codegen ^
-s  %DATA_STRUCTURES% ^
-t  ODataControllerPropertyEndpoints ^
-i  Templates ^
-o  %ControllersProject% ^
-n  %ControllersProject% ^
%STDOPTS%
  echo !command! >> regen_odata_last.bat
  !command!
  if ERRORLEVEL 1 goto error
)
if NOT DEFINED EF_PROVIDER_MYSQL (

  echo.
  echo Generating EF DbContext class [.NET]

  set command=codegen ^
-s  %DATA_STRUCTURES% -ms ^
-t  ODataDbContext ^
-i  Templates ^
-o  %ModelsProject% ^
-n  %ModelsProject% ^
%STDOPTS%
  echo !command! >> regen_odata_last.bat
  !command!
  if ERRORLEVEL 1 goto error
)
  echo.
  echo Generating OData EDM Builder class [.NET]

  set command=codegen ^
-s  %DATA_STRUCTURES% -ms ^
-t  ODataEdmBuilder ^
-i  Templates%TEMPLATESUBDIR% ^
-o  %ServicesProject% ^
-n  %ServicesProject% ^
-ut CONTROLLERS_NAMESPACE=%ControllersProject% MODELS_NAMESPACE=%ModelsProject% ^
%STDOPTS% -tweaks SQLNAMENO$
  echo !command! >> regen_odata_last.bat
  !command!
  if ERRORLEVEL 1 goto error

  echo.
  echo Generating startup class [.NET]

  set command=codegen ^
-s  %DATA_STRUCTURES% -ms ^
-t  ODataStartup ^
-i  Templates%TEMPLATESUBDIR% ^
-o  %ServicesProject% ^
-n  %ServicesProject% ^
-ut CONTROLLERS_NAMESPACE=%ControllersProject% MODELS_NAMESPACE=%ModelsProject% ^
%STDOPTS%
  echo !command! >> regen_odata_last.bat
  !command!
  if ERRORLEVEL 1 goto error
)

rem ================================================================================
rem Postman tests

if DEFINED ENABLE_POSTMAN_TESTS (

  echo.
  echo Generating Postman tests for OData environment

  set command=codegen ^
-s  %DATA_STRUCTURES% -ms ^
-t  ODataPostManTests PostManDevelopmentEnvironment ^
-i  Templates%TEMPLATESUBDIR% ^
-o  . ^
%STDOPTS%
  echo !command! >> regen_odata_last.bat
  !command!
  if ERRORLEVEL 1 goto error
)

rem ================================================================================
rem Visual Studio REST client tests

if defined ENABLE_RESTCLIENT_TESTS (

  echo.
  echo Generating Visual Studio REST Client tests for OData environment

  set command=codegen ^
-s  %DATA_STRUCTURES% ^
-t  ODataVsRestClientTests ^
-i  Templates%TEMPLATESUBDIR% ^
-o  %VsTestClientTestsDir% ^
%STDOPTS%
  echo !command! >> regen_odata_last.bat
  !command!
  if ERRORLEVEL 1 goto error
)

rem ================================================================================
rem Self hosting

if DEFINED ENABLE_SELF_HOST_GENERATION (

  echo.
  echo ************************************************************************
  echo Generating self-hosting code
  echo rem Generating self-hosting code >> regen_odata_last.bat
  echo.
  echo Generating self-hosting environment class [.NET]

  set command=codegen ^
-s  %FILE_STRUCTURES% -ms ^
-t  ODataSelfHostEnvironment ^
-i  Templates%TEMPLATESUBDIR% ^
-o  %HostProject% ^
-n  %HostProject% ^
-ut SERVICES_NAMESPACE=%ServicesProject% MODELS_NAMESPACE=%ModelsProject% ^
%STDOPTS%
  echo !command! >> regen_odata_last.bat
  !command!
  if ERRORLEVEL 1 goto error

  echo.
  echo Generating self-hosting program [.NET]

  set command=codegen ^
-t  ODataSelfHost ^
-i  Templates ^
-o  %HostProject% ^
-n  %HostProject% ^
-ut SERVICES_NAMESPACE=%ServicesProject% ^
%STDOPTS%
  echo !command! >> regen_odata_last.bat
  !command!
  if ERRORLEVEL 1 goto error
)

rem ================================================================================
rem Custom Authentication Example

if DEFINED ENABLE_CUSTOM_AUTHENTICATION (

  echo ************************************************************************
  echo Generating custom authentication code
  echo rem Generating custom authentication code >> regen_odata_last.bat
  echo.

  if not exist "%ModelsProject%\AuthenticationModels.dbl" (
    echo Generating custom authentication data model class [.NET]
    echo.

    set command=codegen ^
-t  ODataCustomAuthModels ^
-i  Templates ^
-o  %ModelsProject% ^
-n  %ModelsProject% ^
%NOREPLACEOPTS%
    echo !command! >> regen_odata_last.bat
    !command!
    if ERRORLEVEL 1 goto error
    echo.
  )

  if not exist "%ControllersProject%\AuthenticationController.dbl" (
    echo Generating custom authentication controller class [.NET]
    echo.

    set command=codegen ^
-t  ODataCustomAuthController ^
-i  Templates ^
-o  %ControllersProject% ^
-n  %ControllersProject% ^
%NOREPLACEOPTS%
    echo !command! >> regen_odata_last.bat
    !command!
    if ERRORLEVEL 1 goto error
    echo.
  )

  if not exist "%ControllersProject%\AuthenticationTools.dbl" (
    echo Generating custom authentication tools class [.NET]
    echo.

    set command=codegen ^
-t  ODataCustomAuthTools ^
-i  Templates ^
-o  %ControllersProject% ^
-n  %ControllersProject% ^
%NOREPLACEOPTS%
    echo !command! >> regen_odata_last.bat
    !command!
    if ERRORLEVEL 1 goto error
    echo.
  )
)

rem ================================================================================
rem Unit testing project

if DEFINED EF_PROVIDER_MYSQL (
  set UNITTESTTEMPLATES=ODataUnitTests
) else (
  set UNITTESTTEMPLATES=ODataClientModel ODataTestDataLoader ODataUnitTests
)

if DEFINED ENABLE_UNIT_TEST_GENERATION (

  echo ************************************************************************
  echo Generating unit test code
  echo rem Generating unit test code >> regen_odata_last.bat

  echo.
  echo Generating client model, data loader and unit test classes [.NET]

  set command=codegen ^
-s  %DATA_STRUCTURES% ^
-t  %UNITTESTTEMPLATES% ^
-i  Templates ^
-o  %TestProject% -tf ^
-n  %TestProject% ^
-ut UNIT_TEST_NAMESPACE=%TestProject% ^
%STDOPTS%
  echo !command! >> regen_odata_last.bat
  !command!
  if ERRORLEVEL 1 goto error

  echo.
  echo Generating unit test environment class and hosting program [.NET]

  set command=codegen ^
-s  %FILE_STRUCTURES% -ms ^
-t  ODataUnitTestEnvironment ODataUnitTestHost ^
-i  Templates ^
-o  %TestProject% ^
-n  %TestProject% ^
-ut UNIT_TESTS_NAMESPACE=%TestProject% ^
%STDOPTS%
  echo !command! >> regen_odata_last.bat
  !command!
  if ERRORLEVEL 1 goto error

  echo.
  echo Generating unit test constants properties class [.NET]

  set command=codegen ^
-s  %DATA_STRUCTURES% -ms ^
-t  ODataTestConstantsProperties ^
-i  Templates ^
-o  %TestProject% ^
-n  %TestProject% ^
%STDOPTS%
  echo !command! >> regen_odata_last.bat
  !command!
  if ERRORLEVEL 1 goto error

  echo.
  echo Generating unit test key value generation program [.NET]

  set command=codegen ^
-s  %DATA_STRUCTURES% -ms ^
-t  GenerateTestValues ^
-i  Templates ^
-o  %TestValuesProject% ^
-n  %TestValuesProject% ^
-ut UNIT_TESTS_NAMESPACE=%TestProject% ^
%STDOPTS%
  echo !command! >> regen_odata_last.bat
  !command!
  if ERRORLEVEL 1 goto error
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
