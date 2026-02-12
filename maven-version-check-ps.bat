@echo off
setlocal
:: 콘솔 인코딩을 UTF-8로 설정
chcp 65001 >nul

:: Maven 실행 가능 여부 확인
where mvn >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Maven을 찾을 수 없습니다. PATH 설정을 확인하거나 Maven을 설치해주세요.
    echo Required: Maven 3.8.x or 3.9.x
    exit /b 1
)

:: PowerShell을 사용하여 Maven 버전 정밀 검사
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "[Console]::OutputEncoding = [System.Text.Encoding]::UTF8;" ^
    "$mvnLink = 'https://maven.apache.org/download.cgi';" ^
    "$mvnOutput = mvn -v | Select-Object -First 1;" ^
    "if (-not $mvnOutput) { Write-Host '[ERROR] Maven 버전을 확인할 수 없습니다.' -ForegroundColor Red; exit 1 }" ^
    "$match = [regex]::Match($mvnOutput, 'Apache Maven (3\.[89]\.[0-9]+)');" ^
    "if ($match.Success) {" ^
    "    Write-Host ('[OK] Maven 버전 확인 완료: ' + $match.Groups[1].Value) -ForegroundColor Green;" ^
    "    exit 0;" ^
    "} else {" ^
    "    Write-Host '[ERROR] 호환되지 않는 Maven 버전입니다.' -ForegroundColor Red;" ^
    "    Write-Host ('현재 버전: ' + $mvnOutput) -ForegroundColor Yellow;" ^
    "    Write-Host '권장 버전: Maven 3.8.x 또는 3.9.x' -ForegroundColor Cyan;" ^
    "    Write-Host ('다운로드: ' + $mvnLink) -ForegroundColor Cyan;" ^
    "    exit 1;" ^
    "}"

:: PowerShell 스크립트의 종료 코드를 배치 파일 종료 코드로 전달
if %errorlevel% neq 0 (
    exit /b 1
)

endlocal
exit /b 0
