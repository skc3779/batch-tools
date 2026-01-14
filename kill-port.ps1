param (
    [Parameter(Mandatory=$true, HelpMessage="종료할 프로세스가 사용 중인 포트 번호를 입력하세요 (예: 8080, 3000)")]
    [int]$Port,

    [Parameter(Mandatory=$false)]
    [switch]$Force
)

# 출력 인코딩을 UTF-8로 설정 (한글 깨짐 방지)
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "`n--- 포트 $Port 를 사용하는 프로세스 종료 ---" -ForegroundColor Cyan
Write-Host "실행 시간: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n" -ForegroundColor Gray

try {
    # 관리자 권한 확인
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if (-not $isAdmin) {
        Write-Host "⚠️  경고: 관리자 권한으로 실행하지 않았습니다." -ForegroundColor Yellow
        Write-Host "   일부 시스템 프로세스는 종료하지 못할 수 있습니다.`n" -ForegroundColor Yellow
    }

    # 포트를 사용 중인 연결 찾기
    Write-Host "📡 포트 $Port 를 사용하는 프로세스를 검색 중..." -ForegroundColor Yellow
    
    $connections = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    
    if (-not $connections) {
        Write-Host "✅ 포트 $Port 를 사용하는 프로세스가 없습니다." -ForegroundColor Green
        Write-Host "`n--- 완료 ---`n" -ForegroundColor Cyan
        exit 0
    }

    # 프로세스 ID 수집 (중복 제거)
    $processIds = $connections | Select-Object -ExpandProperty OwningProcess -Unique

    Write-Host "🔍 발견된 프로세스: $($processIds.Count)개`n" -ForegroundColor Cyan

    # 각 프로세스 정보 표시 및 종료
    $killedCount = 0
    $failedCount = 0

    foreach ($processId in $processIds) {
        try {
            $process = Get-Process -Id $processId -ErrorAction Stop
            
            Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
            Write-Host "프로세스 이름  : $($process.ProcessName)" -ForegroundColor White
            Write-Host "프로세스 ID    : $processId" -ForegroundColor White
            Write-Host "프로세스 경로  : $($process.Path)" -ForegroundColor Gray
            Write-Host "메모리 사용량  : $([math]::Round($process.WorkingSet64 / 1MB, 2)) MB" -ForegroundColor Gray
            
            # 해당 프로세스의 포트 사용 정보 표시
            $processConnections = $connections | Where-Object { $_.OwningProcess -eq $processId }
            Write-Host "연결 상태      :" -ForegroundColor Gray
            foreach ($conn in $processConnections) {
                $localAddr = if ($conn.LocalAddress -eq "::") { "[::]:$($conn.LocalPort)" } 
                            elseif ($conn.LocalAddress -eq "0.0.0.0") { "0.0.0.0:$($conn.LocalPort)" }
                            else { "$($conn.LocalAddress):$($conn.LocalPort)" }
                
                $remoteAddr = if ($conn.RemoteAddress -and $conn.RemotePort) { 
                    "$($conn.RemoteAddress):$($conn.RemotePort)" 
                } else { 
                    "*:*" 
                }
                
                Write-Host "  - $localAddr -> $remoteAddr [$($conn.State)]" -ForegroundColor Gray
            }
            
            # 프로세스 종료 시도
            if ($Force) {
                Write-Host "`n⚡ 강제 종료 시도 중..." -ForegroundColor Yellow
                Stop-Process -Id $processId -Force -ErrorAction Stop
            }
            else {
                Write-Host "`n⏹️  정상 종료 시도 중..." -ForegroundColor Yellow
                Stop-Process -Id $processId -ErrorAction Stop
            }
            
            # 종료 확인
            Start-Sleep -Milliseconds 500
            $stillRunning = Get-Process -Id $processId -ErrorAction SilentlyContinue
            
            if ($stillRunning) {
                Write-Host "⚠️  프로세스가 완전히 종료되지 않았을 수 있습니다." -ForegroundColor Yellow
            }
            else {
                Write-Host "✅ 프로세스 종료 성공!" -ForegroundColor Green
                $killedCount++
            }
        }
        catch [Microsoft.PowerShell.Commands.ProcessCommandException] {
            Write-Host "❌ 프로세스 종료 실패 (PID: $processId)" -ForegroundColor Red
            Write-Host "   사유: 프로세스에 접근할 수 없습니다. 관리자 권한이 필요할 수 있습니다." -ForegroundColor Red
            $failedCount++
        }
        catch {
            Write-Host "❌ 프로세스 종료 실패 (PID: $processId)" -ForegroundColor Red
            Write-Host "   사유: $($_.Exception.Message)" -ForegroundColor Red
            $failedCount++
        }
        
        Write-Host ""
    }

    # 최종 결과 확인
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
    Write-Host "📊 요약" -ForegroundColor Cyan
    Write-Host "  총 프로세스  : $($processIds.Count)개" -ForegroundColor White
    Write-Host "  종료 성공    : $killedCount 개" -ForegroundColor Green
    if ($failedCount -gt 0) {
        Write-Host "  종료 실패    : $failedCount 개" -ForegroundColor Red
    }
    
    # 포트 해제 확인
    Start-Sleep -Seconds 1
    $remainingConnections = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    
    Write-Host ""
    if (-not $remainingConnections) {
        Write-Host "✅ 포트 $Port 가 해제되었습니다!" -ForegroundColor Green
    }
    else {
        Write-Host "⚠️  포트 $Port 가 여전히 사용 중입니다." -ForegroundColor Yellow
        Write-Host "   일부 프로세스가 종료되지 않았거나 새로운 프로세스가 포트를 사용 중일 수 있습니다." -ForegroundColor Yellow
    }

}
catch {
    Write-Host "❌ 오류 발생: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 도움말:" -ForegroundColor Yellow
    Write-Host "  - 관리자 권한으로 PowerShell을 실행해보세요." -ForegroundColor Gray
    Write-Host "  - 포트 번호가 올바른지 확인해보세요." -ForegroundColor Gray
    exit 1
}

Write-Host "`n--- 완료 ---`n" -ForegroundColor Cyan
