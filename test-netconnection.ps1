param (
    [Parameter(Mandatory=$true, HelpMessage="확인할 호스트 또는 IP를 입력하세요 (예: google.com 또는 8.8.8.8)")]
    [string]$ComputerName,

    [Parameter(Mandatory=$true, HelpMessage="확인할 포트 번호 (예: 80, 443, 3389)")]
    [int]$Port,

    [Parameter(Mandatory=$false, HelpMessage="TraceRoute 실행 여부를 지정합니다. (예: -TraceRoute)")]
    [switch]$TraceRoute,

    [Parameter(Mandatory=$false, HelpMessage="상세 출력을 표시합니다. (예: -DetailedOutput)")]
    [switch]$DetailedOutput
)

# 출력 인코딩을 UTF-8로 설정 (한글 깨짐 방지)
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "`n--- [$ComputerName] 네트워크 연결 테스트 시작 ---" -ForegroundColor Cyan
Write-Host "테스트 시작 시간: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n" -ForegroundColor Gray

# 기본 파라미터 설정
$testParams = @{
    ComputerName = $ComputerName
    InformationLevel = 'Detailed'
}

if ($Port) {
    $testParams.Add('Port', $Port)
    Write-Host "📌 포트 테스트: $Port" -ForegroundColor Yellow
}

if ($TraceRoute) {
    $testParams.Add('TraceRoute', $true)
    Write-Host "📌 TraceRoute 추가 실행" -ForegroundColor Yellow
}

Write-Host ""

try {
    # Test-NetConnection 실행
    $result = Test-NetConnection @testParams

    # 결과 출력
    if ($DetailedOutput) {
        Write-Host "=== 상세 연결 정보 ===" -ForegroundColor Cyan
        Write-Host "컴퓨터 이름      : $($result.ComputerName)" -ForegroundColor White
        Write-Host "원격 주소        : $($result.RemoteAddress)" -ForegroundColor White
        Write-Host "인터페이스 별칭  : $($result.InterfaceAlias)" -ForegroundColor White
        Write-Host "원본 주소        : $($result.SourceAddress.IPAddress)" -ForegroundColor White
        
        if ($Port) {
            Write-Host "포트 ($Port)      : $(if($result.TcpTestSucceeded){'✅ 열림 (Open)'} else {'❌ 닫힘 (Closed)'})" -ForegroundColor $(if($result.TcpTestSucceeded){'Green'} else {'Red'})
        }
        
        Write-Host "Ping 응답        : $(if($result.PingSucceeded){'✅ 성공'} else {'❌ 실패'})" -ForegroundColor $(if($result.PingSucceeded){'Green'} else {'Red'})
        
        if ($result.PingSucceeded) {
            Write-Host "응답 시간        : $($result.PingReplyDetails.RoundtripTime) ms" -ForegroundColor White
        }

        if ($TraceRoute -and $result.TraceRoute) {
            Write-Host "`n=== TraceRoute 결과 ===" -ForegroundColor Cyan
            $hopCount = 1
            foreach ($hop in $result.TraceRoute) {
                Write-Host "  Hop $hopCount : $hop" -ForegroundColor Gray
                $hopCount++
            }
        }
    }
    else {
        # 간단한 출력
        if ($Port) {
            if ($result.TcpTestSucceeded) {
                Write-Host "✅ 연결 성공: $ComputerName`:$Port 포트가 열려있습니다." -ForegroundColor Green
            }
            else {
                Write-Host "❌ 연결 실패: $ComputerName`:$Port 포트에 연결할 수 없습니다." -ForegroundColor Red
            }
        }
        else {
            if ($result.PingSucceeded) {
                Write-Host "✅ Ping 성공: $ComputerName 에 연결되었습니다." -ForegroundColor Green
                Write-Host "   IP 주소: $($result.RemoteAddress)" -ForegroundColor Gray
            }
            else {
                Write-Host "❌ Ping 실패: $ComputerName 에 연결할 수 없습니다." -ForegroundColor Red
            }
        }
    }

    # 반환 값
    Write-Host ""
    if ($Port) {
        if ($result.TcpTestSucceeded) {
            Write-Host "결과: 포트 연결 성공 ✅" -ForegroundColor Green
        }
        else {
            Write-Host "결과: 포트 연결 실패 ❌" -ForegroundColor Red
        }
    }
    else {
        if ($result.PingSucceeded) {
            Write-Host "결과: Ping 성공 ✅" -ForegroundColor Green
        }
        else {
            Write-Host "결과: Ping 실패 ❌" -ForegroundColor Red
        }
    }
}
catch {
    Write-Host "❌ 오류 발생: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n--- 테스트 완료 ---" -ForegroundColor Cyan
Write-Host "테스트 종료 시간: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n" -ForegroundColor Gray
