@echo off

if [%1] == [] goto help

REM This allows us to expand variables at execution
setlocal ENABLEDELAYEDEXPANSION

REM This will set PYFILES as a list of tracked .py files
set PYFILES=
for /F "tokens=* USEBACKQ" %%A in (`git ls-files "*.py"`) do (
    set PYFILES=!PYFILES! %%A
)

goto %1

:reformat
black -l 99 -N !PYFILES!
exit /B %ERRORLEVEL%

:stylecheck
black -l 99 -N --check !PYFILES!
exit /B %ERRORLEVEL%

:update_vendor
if [%REF%] == [] (
    set REF2="rewrite"
) else (
    set REF2=%REF%
)
pip install --upgrade --no-deps -t . https://github.com/Rapptz/discord.py/archive/!REF2!.tar.gz#egg=discord.py
del /S /Q "discord.py*-info"
for /F %%i in ('dir /S /B discord.py*.egg-info') do rmdir /S /Q %%i
goto reformat

:help
echo Usage:
echo   make ^<command^>
echo.
echo Commands:
echo   reformat                   Reformat all .py files being tracked by git.
echo   stylecheck                 Check which tracked .py files need reformatting.
echo   update_vendor              Update vendored discord.py library to %%REF%%, which defaults to
echo                              "rewrite"
