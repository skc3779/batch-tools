param (
    [Parameter(Mandatory=$true, HelpMessage="확인할 도메인을 입력하세요 (예: google.com)")]
    [string]$Domain,

    [Parameter(Mandatory=$false)]
    [int]$Port = 443
)

# 1. 출력 인코딩을 UTF-8로 설정 (한글 깨짐 방지)
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


# 확인하고자 하는 프로토콜 목록
$protocols = @("Ssl2", "Ssl3", "Tls", "Tls11", "Tls12", "Tls13")

Write-Host "`n--- [$Domain] 서버의 TLS 지원 버전 확인 시작 ---" -ForegroundColor Cyan

foreach ($protocol in $protocols) {
    $tcpClient = $null
    $sslStream = $null
    try {
        # TCP 연결 생성
        $tcpClient = New-Object System.Net.Sockets.TcpClient($Domain, $Port)
        $tcpClient.ReceiveTimeout = 3000 # 3초 타임아웃 설정
        
        # SSL 스트림 생성 (인증서 검증은 통과하도록 설정)
        $sslStream = New-Object System.Net.Security.SslStream(
            $tcpClient.GetStream(),
            $false,
            ({ $true } -as [System.Net.Security.RemoteCertificateValidationCallback])
        )
        
        # 특정 프로토콜로 인증 시도
        $sslStream.AuthenticateAsClient($Domain, $null, $protocol, $false)
        
        Write-Host "✅ [지원함] : $protocol" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ [미지원] : $protocol" -ForegroundColor Red
    }
    finally {
        # 자원 해제
        if ($sslStream) { $sslStream.Close() }
        if ($tcpClient) { $tcpClient.Close() }
    }
}

Write-Host "--- 확인 완료 ---`n" -ForegroundColor Cyan