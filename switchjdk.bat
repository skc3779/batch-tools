@echo off
setlocal enabledelayedexpansion

:menu
cls
echo ================================
echo     Java Version Switcher
echo ================================
echo.
echo Available Java Versions:
echo.
echo   1) Java 6
echo   2) Java 7
echo   3) Java 8
echo   4) Java 11
echo   5) Java 17
echo   6) Java 21
echo   7) Java 25
echo.
echo ================================
echo.

set /p CHOICE="Select a version (1-7): "

if "%CHOICE%"=="1" (
    set JAVA_HOME_ENV=!JAVA_HOME_6!
    set JAVA_VERSION=Java 6
) else if "%CHOICE%"=="2" (
    set JAVA_HOME_ENV=!JAVA_HOME_7!
    set JAVA_VERSION=Java 7
) else if "%CHOICE%"=="3" (
    set JAVA_HOME_ENV=!JAVA_HOME_8!
    set JAVA_VERSION=Java 8
) else if "%CHOICE%"=="4" (
    set JAVA_HOME_ENV=!JAVA_HOME_11!
    set JAVA_VERSION=Java 11
) else if "%CHOICE%"=="5" (
    set JAVA_HOME_ENV=!JAVA_HOME_17!
    set JAVA_VERSION=Java 17
) else if "%CHOICE%"=="6" (
    set JAVA_HOME_ENV=!JAVA_HOME_21!
    set JAVA_VERSION=Java 21
) else if "%CHOICE%"=="7" (
    set JAVA_HOME_ENV=!JAVA_HOME_25!
    set JAVA_VERSION=Java 25
) else (
    echo.
    echo Invalid selection. Please try again.
    timeout /t 2 /nobreak
    goto menu
)

if "!JAVA_HOME_ENV!"=="" (
    echo.
    echo Error: Environment variable for selected version is not set
    timeout /t 3 /nobreak
    goto menu
)

set JAVA_HOME=!JAVA_HOME_ENV!
set Path=!JAVA_HOME!\bin;!Path!

echo.
echo !JAVA_VERSION! activated.
echo.
java -version
echo.
pause