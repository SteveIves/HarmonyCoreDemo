@echo off
pushd %~dp0

if exist .vs\. rd /s /q .vs
if exist bin\. rd /s /q bin
if exist obj\. rd /s /q obj

if exist CustomConverters\.intellisense\. rd /s /q CustomConverters\.intellisense
if exist CustomConverters\bin\. rd /s /q CustomConverters\bin
if exist CustomConverters\obj\. rd /s /q CustomConverters\obj

if exist PUBLISH\. rd /s /q PUBLISH

if exist Services\.intellisense\. rd /s /q Services\.intellisense
if exist Services\bin\. rd /s /q Services\bin
if exist Services\obj\. rd /s /q Services\obj

if exist Services.Controllers\.intellisense\. rd /s /q Services.Controllers\.intellisense
if exist Services.Controllers\bin\. rd /s /q Services.Controllers\bin
if exist Services.Controllers\obj\. rd /s /q Services.Controllers\obj

if exist Services.Host\.intellisense\. rd /s /q Services.Host\.intellisense
if exist Services.Host\bin\. rd /s /q Services.Host\bin
if exist Services.Host\obj\. rd /s /q Services.Host\obj

if exist Services.Isolated\.intellisense\. rd /s /q Services.Isolated\.intellisense
if exist Services.Isolated\bin\. rd /s /q Services.Isolated\bin
if exist Services.Isolated\obj\. rd /s /q Services.Isolated\obj

if exist Services.Models\.intellisense\. rd /s /q Services.Models\.intellisense
if exist Services.Models\bin\. rd /s /q Services.Models\bin
if exist Services.Models\obj\. rd /s /q Services.Models\obj

if exist TraditionalBridge\.intellisense\. rd /s /q TraditionalBridge\.intellisense
if exist TraditionalBridge\bin\. rd /s /q TraditionalBridge\bin
if exist TraditionalBridge\obj\. rd /s /q TraditionalBridge\obj

popd