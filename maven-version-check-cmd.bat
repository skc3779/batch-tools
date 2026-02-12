@echo off
setlocal EnableDelayedExpansion

:: 콘솔 인코딩을 UTF-8로 설정
chcp 65001 >nul

:: Maven 실행 가능 여부 확인
where mvn >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Maven을 찾을 수 없습니다. PATH 설정을 확인하거나 Maven을 설치해주세요.
    echo Required: Maven 3.8.x or 3.9.x
    exit /b 1
)

:: Maven 버전 확인
:: mvn -v 출력의 첫 줄에서 버전 정보를 추출 (예: Apache Maven 3.9.6 ...)
set "MVN_VERSION="
for /f "tokens=3" %%v in ('mvn -v ^| findstr /r /c:"^Apache Maven"') do (
    set "MVN_VERSION=%%v"
)

:: 버전을 찾지 못한 경우
if not defined MVN_VERSION (
    echo [ERROR] Maven 버전을 확인할 수 없습니다.
    exit /b 1
)

:: 버전 검사 (3.8.x 또는 3.9.x)
:: 버전 문자열이 3.8. 또는 3.9. 로 시작하는지 확인
echo %MVN_VERSION% | findstr /b "3.8." >nul
if %errorlevel% equ 0 goto :VERSION_OK

echo %MVN_VERSION% | findstr /b "3.9." >nul
if %errorlevel% equ 0 goto :VERSION_OK

:VERSION_FAIL
echo [ERROR] 호환되지 않는 Maven 버전입니다.
echo 현재 버전: %MVN_VERSION%
echo 권장 버전: Maven 3.8.x 또는 3.9.x
echo 다운로드: https://maven.apache.org/download.cgi
exit /b 1

:VERSION_OK
echo [OK] Maven 버전 확인 완료: %MVN_VERSION%
endlocal
exit /b 0
