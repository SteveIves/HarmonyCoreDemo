@echo off
pushd %~dp0
call regen_odata.bat
call regen_bridge.bat
popd
