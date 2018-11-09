@echo off
setlocal

rem +------------------------------------------------------------------------+
rem | Licensed Materials - Property of IBM                                   |
rem | (C) Copyright IBM Corp. 2010, 2015.  All Rights Reserved.              |
rem |                                                                        |
rem | US Government Users Restricted Rights - Use, duplication or disclosure |
rem | restricted by GSA ADP Schedule Contract with IBM Corp.                 |
rem +------------------------------------------------------------------------+


rem +------------------------------------------------------------------------+
rem | NOTE: This script is intended to be used when doing a console mode     |
rem | install from a multi-CD/DVD disk set, where IM prompts the user to     |
rem | insert the next CD/DVD during the install.  For all other use-cases,   |
rem | it is not necessary to run this script.  Instead use the               |
rem | "installc.exe" or "userinstc.exe" launcher with the "-c" option to     |
rem | install in console mode.                                               |
rem +------------------------------------------------------------------------+


set guid=0DE8AB40-25D6-4822-B8B2-37D4B0FA2B17
set tempScript=%TEMP%\con-disk-set-inst-%guid%.bat
for %%I in ("%~dp0.") do set scriptLoc=%%~fI

if not "%~0" == "%tempScript%" goto runFromTemp

set restartScript=%TEMP%\restartScript-%guid%.bat
set restartScript2base=restartScript2-%guid%.bat
set restartScript2=%TEMP%\%restartScript2base%

set accessRights=
:argloop
if "%1" == "-accessRights" goto ar
if "%1" == "-aR" goto ar
goto nextarg
:ar
if "%2" == "" goto badarg
set accessRights=%2
goto argend
:nextarg
shift
if not "%1" == "" goto argloop
:argend

set launcher=
if "%accessRights%" == "" set launcher=installc.exe
if "%accessRights%" == "admin" set launcher=installc.exe
if "%accessRights%" == "nonAdmin" set launcher=userinstc.exe

if not "%launcher%" == "" goto dolaunch

:badarg
echo The only allowed -accessRights values are admin and nonAdmin
goto end

:dolaunch

rem echo %restartScript%
rem echo %restartScript2%
rem echo %scriptLoc%
rem echo %origScriptLoc%
rem echo %launcher%

if exist "%restartScript%" del /q /f "%restartScript%"

"%origScriptLoc%\%launcher%" -c -restartScriptLocation "%restartScript%" %*
if %errorlevel% neq 0 goto end

:loop
if not exist "%restartScript%" goto end
if exist "%restartScript2%" del /q /f "%restartScript2%"
rename "%restartScript%" "%restartScript2base%"
rem echo Restarting Installation Manager
call "%restartScript2%"
if %errorlevel% neq 0 goto end
goto loop

:runFromTemp
copy /y "%~dpnx0" "%tempScript%" | find "xyzzy"
cd /d "%TEMP%"
set origScriptLoc=%scriptLoc%
"%tempScript%" %*

:end

if exist "%restartScript%" del /q /f "%restartScript%"
if exist "%restartScript2%" del /q /f "%restartScript2%"
rem Cannot delete the temp script.  Otherwise cmd.exe complains
rem if exist "%tempScript%" del /q /f "%tempScript%"

endlocal
