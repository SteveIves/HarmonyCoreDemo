rem ================================================================================================================================
rem Specify the names of the projects to generate code into:

set SolutionDir=%~dp0
set ServicesProject=Services
set ModelsProject=Services.Models
set ControllersProject=Services.Controllers
set HostProject=Services.Host
set TestProject=Services.Test
set TestValuesProject=Services.Test.GenerateTestValues
set TraditionalBridgeProject=TraditionalBridge
set VsTestClientTestsDir=HttpTests

rem ================================================================================================================================
rem Repository

if not defined RPSMFIL set RPSMFIL=%SolutionDir%\Repository\rpsmain.ism
if not defined RPSTFIL set RPSTFIL=%SolutionDir%\Repository\rpstext.ism

rem If the repository schema is newer than RPSMAIN.ISM then the repository may be out of date

set RPSSCH=%SolutionDir%Repository\repository.scm
for %%a in ("%RPSSCH%") do set file1datetime=%%~ta
for %%a in ("%RPSMFIL%") do set file2datetime=%%~ta
if "%file1datetime%" gtr "%file2datetime%" (
    echo.
    echo ========================================================================================================
    echo WARNING: Your repository schema is newer than your repository ISAM files. Do you need to run LoadSchema?
    echo ========================================================================================================
    timeout /t 5
)

rem ================================================================================================================================
rem Global options

set CODEGEN_MIN_VERSION=5.8.1

rem set ENABLE_ALTERNATE_FIELD_NAMES=-af
rem set ENABLE_AUTHENTICATION=-define ENABLE_AUTHENTICATION
rem set ENABLE_CASE_SENSITIVE_URL=-define ENABLE_CASE_SENSITIVE_URL
set ENABLE_CORS=-define ENABLE_CORS
rem set ENABLE_CUSTOM_AUTHENTICATION=-define ENABLE_CUSTOM_AUTHENTICATION
rem set ENABLE_FIELD_SECURITY=-define ENABLE_FIELD_SECURITY
set ENABLE_IIS_SUPPORT=-define ENABLE_IIS_SUPPORT
set DISABLE_USEURLS=-define DISABLE_USEURLS
set ENABLE_NEWTONSOFT=-define ENABLE_NEWTONSOFT
set ENABLE_OVERLAYS=-f o
set ENABLE_POSTMAN_TESTS=YES
set ENABLE_RESTCLIENT_TESTS=YES
rem set ENABLE_READ_ONLY_PROPERTIES=-define ENABLE_READ_ONLY_PROPERTIES
rem set ENABLE_UNIT_TEST_GENERATION=YES
set GLOBAL_MODELSTATE_FILTER=-define GLOBAL_MODELSTATE_FILTER
rem set SHOW_CODEGEN_COMMANDS=-e
set NO_CUSTOM_PLURALIZATION=-ncp
rem set ENABLE_EXCLUDE_KEYS=-rpsoverride ExcludeKeys.json
rem set ENABLE_BLOCK_HTTP=-define ENABLE_BLOCK_HTTP
set ENABLE_XMLDOC=-define ENABLE_XMLDOC

rem ================================================================================================================================
rem OData Options

set ENABLE_ODATA_ENVIRONMENT=YES

rem Specify the names of the repository structures to generate OData code from:
rem
rem   DATA_STRUCTURES should include ALL structures being processed
rem
rem   If you have multiple STRUCTURES assigned to a single FILE then FILE_STRUCTURES should
rem   only include ONE of those structures

set DATA_STRUCTURES=regen.data_structures.json
set FILE_STRUCTURES=regen.file_structures.json

rem set EF_PROVIDER_MYSQL=-define EF_PROVIDER_MYSQL
set ENABLE_SELF_HOST_GENERATION=YES
set ENABLE_CREATE_TEST_FILES=-define ENABLE_CREATE_TEST_FILES
rem set DO_NOT_SET_FILE_LOGICALS=-define DO_NOT_SET_FILE_LOGICALS
set ENABLE_GET_ALL=-define ENABLE_GET_ALL
set ENABLE_GET_ONE=-define ENABLE_GET_ONE
set ENABLE_ALTERNATE_KEYS=-define ENABLE_ALTERNATE_KEYS
set ENABLE_PARTIAL_KEYS=-define ENABLE_PARTIAL_KEYS
rem set ENABLE_COUNT=-define ENABLE_COUNT
rem set ENABLE_PROPERTY_ENDPOINTS=-define ENABLE_PROPERTY_ENDPOINTS
set ENABLE_SELECT=-define ENABLE_SELECT
set ENABLE_FILTER=-define ENABLE_FILTER
set ENABLE_ORDERBY=-define ENABLE_ORDERBY
set ENABLE_TOP=-define ENABLE_TOP
set ENABLE_SKIP=-define ENABLE_SKIP
set ENABLE_RELATIONS=-define ENABLE_RELATIONS
rem set ENABLE_RELATIONS_VALIDATION=-define ENABLE_RELATIONS_VALIDATION
rem set ENABLE_PUT=-define ENABLE_PUT
rem set ENABLE_POST=-define ENABLE_POST
rem set ENABLE_PATCH=-define ENABLE_PATCH
rem set ENABLE_DELETE=-define ENABLE_DELETE

rem ================================================================================================================================
rem Bridge Options

set ENABLE_XFSERVERPLUS_MIGRATION=YES

rem Specify the path to a SMC export file and the method catalog location
set SMC_XML_FILE=TraditionalBridge\smc\MethodDefinitions.xml
set XFPL_SMCPATH=TraditionalBridge\smc

rem Specify the name of one or more interfaces defined in the SMC export file, space separated
set SMC_INTERFACES_REST=BridgeAPI
rem set SMC_INTERFACES_SIGNALR=TmaxToolsStateful
rem set SMC_INTERFACES_INTERNAL=TmaxToolsInternal

rem set ENABLE_BRIDGE_OPTIONAL_PARAMETERS=YES
rem set ENABLE_SIGNALR=-define ENABLE_SIGNALR
rem set ENABLE_TYPESCRIPT_GENERATION=YES
set ENABLE_XFSERVERPLUS_METHOD_STUBS=YES
set ENABLE_XFSERVERPLUS_MODEL_GENERATION=YES

rem ================================================================================================================================
rem Configure the CodeGen command-line options

if not "NONE%ENABLE_SELECT%%ENABLE_FILTER%%ENABLE_ORDERBY%%ENABLE_TOP%%ENABLE_SKIP%%ENABLE_RELATIONS%"=="NONE" (
  set PARAM_OPTIONS_PRESENT=-define PARAM_OPTIONS_PRESENT
)

if DEFINED EF_PROVIDER_MYSQL (
  set TEMPLATESUBDIR=\MySQL
)

rem Configure standard command line options
set NOREPLACEOPTS=%SHOW_CODEGEN_COMMANDS% -lf -u UserDefinedTokens.tkn %ENABLE_GET_ALL% %ENABLE_GET_ONE% %ENABLE_OVERLAYS% %DO_NOT_SET_FILE_LOGICALS% %ENABLE_ALTERNATE_FIELD_NAMES% %ENABLE_AUTHENTICATION% %ENABLE_CUSTOM_AUTHENTICATION% %ENABLE_FIELD_SECURITY% %ENABLE_PROPERTY_ENDPOINTS% %ENABLE_CASE_SENSITIVE_URL% %ENABLE_CREATE_TEST_FILES% %ENABLE_CORS% %ENABLE_IIS_SUPPORT% %ENABLE_DELETE% %ENABLE_PUT% %ENABLE_POST% %ENABLE_PATCH% %ENABLE_ALTERNATE_KEYS% %ENABLE_RELATIONS% %ENABLE_RELATIONS_VALIDATION% %ENABLE_SELECT% %ENABLE_FILTER% %ENABLE_ORDERBY% %ENABLE_COUNT% %ENABLE_TOP% %ENABLE_SKIP% %ENABLE_SPROC% %ENABLE_ADAPTER_ROUTING% %ENABLE_READ_ONLY_PROPERTIES% %GLOBAL_MODELSTATE_FILTER% %ENABLE_NEWTONSOFT% %ENABLE_SIGNALR% %ENABLE_PARTIAL_KEYS% %ENABLE_EXCLUDE_KEYS% %ENABLE_BLOCK_HTTP% %ENABLE_XMLDOC% %DISABLE_USEURLS% %NO_CUSTOM_PLURALIZATION% %PARAM_OPTIONS_PRESENT% -rps %RPSMFIL% %RPSTFIL%
set STDOPTS=%NOREPLACEOPTS% -r

rem Optional parameters support is for use with xfServerPlue environments that were
rem used in conjunction with xfNetLink COM, which supported optional parameters.
if DEFINED ENABLE_BRIDGE_OPTIONAL_PARAMETERS (
  set BRIDGE_DISPATCHER_TEMPLATE=OptionalParameterMethodDispatchers
) else (
  set BRIDGE_DISPATCHER_TEMPLATE=InterfaceMethodDispatchers
)

rem ================================================================================================================================
