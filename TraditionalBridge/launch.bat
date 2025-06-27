@echo off
rem
rem Launch the traditional bridge host program on Windows (local or remote)
rem
rem Parameters:
rem
rem %1	Synergy bit size (32 or 64)
rem %2	Traditional bridge logging level (-1 to 6, default 2)
rem %3	Remote debugger mode (not passed=NONE, TELNET or VS)
rem %4	Remote debugger port (required if %3 is passed)
rem %5	Remote debugger delay (required if %3 is passed)
rem %6  Enable stuck process detection (YES or NO) - not currently supported on Windows

setlocal

rem Put us in the TraditionalBridge directory
pushd %~dp0

rem Configure the Synergy environment based on the passed bit size
set SYNERGYDE=
set WND=
set SFWINIPATH=
if "%~1"=="32" (
  call "%SYNERGYDE32%dbl\dblvars32.bat"
) else (
  call "%SYNERGYDE64%dbl\dblvars64.bat"
)

rem If we have a log level, use it, else default to 2
if "%~2"=="" (
  set HARMONY_LOG_LEVEL=2
) else (
  set HARMONY_LOG_LEVEL=%2
)

rem No remote debugger support
if "%~3"=="" (
  set START_COMMAND=dbs host.dbr
)  else if "%~3"=="NONE" (
  set START_COMMAND=dbs host.dbr
)

rem Telnet emote debugger support
if "%~3"=="TELNET" (
  set START_COMMAND=dbr -rd %4:%5 host.dbr
)

rem Visual Studio remote debugger support
if "%~3"=="VS" (
  set START_COMMAND=dbr -dv -rd %4:%5 host.dbr
)

rem Enable open file checking
rem set CHECK_OPEN_CHANNELS=YES

rem Currently no support on Windows for stuck process checking

rem Start the host application
%START_COMMAND%

popd

endlocal