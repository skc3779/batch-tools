param (
    [Parameter(Mandatory=$true, HelpMessage="OAuth2 토큰 엔드포인트 URL을 입력하세요 (예: https://auth.example.com/oauth/token)")]
    [string]$TokenEndpoint,

    [Parameter(Mandatory=$true, HelpMessage="사용자 이름을 입력하세요")]
    [string]$Username,

    [Parameter(Mandatory=$true, HelpMessage="사용자 비밀번호를 입력하세요")]
    [string]$Password,

    [Parameter(Mandatory=$true, HelpMessage="클라이언트 ID를 입력하세요")]
    [string]$ClientId,

    [Parameter(Mandatory=$true, HelpMessage="클라이언트 시크릿을 입력하세요 (선택사항)")]
    [string]$ClientSecret,

    [Parameter(Mandatory=$true, HelpMessage="요청할 스코프를 입력하세요 (선택사항, 예: read write)")]
    [string]$Scope,

    [Parameter(Mandatory=$false)]
    [switch]$ShowFullResponse
)

# 출력 인코딩을 UTF-8로 설정 (한글 깨짐 방지)
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "`n--- OAuth2 Password Grant Type 토큰 발행 시작 ---" -ForegroundColor Cyan
Write-Host "요청 시간: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host "엔드포인트: $TokenEndpoint" -ForegroundColor Gray
Write-Host "사용자: $Username" -ForegroundColor Gray
Write-Host ""

try {
    # 요청 본문 생성
    $body = @{
        grant_type = "password"
        username = $Username
        password = $Password
        client_id = $ClientId
    }

    # 선택적 파라미터 추가
    if ($ClientSecret) {
        $body.Add("client_secret", $ClientSecret)
    }

    if ($Scope) {
        $body.Add("scope", $Scope)
    }

    Write-Host "📤 토큰 요청 중..." -ForegroundColor Yellow

    # HTTP POST 요청
    $response = Invoke-RestMethod -Uri $TokenEndpoint `
                                  -Method Post `
                                  -Body $body `
                                  -ContentType "application/x-www-form-urlencoded" `
                                  -ErrorAction Stop

    Write-Host "✅ 토큰 발행 성공!" -ForegroundColor Green
    Write-Host ""

    # 결과 출력
    if ($ShowFullResponse) {
        Write-Host "=== 전체 응답 내용 ===" -ForegroundColor Cyan
        $response | ConvertTo-Json -Depth 10 | Write-Host -ForegroundColor White
        Write-Host ""
    }

    # 주요 정보 출력
    Write-Host "=== 토큰 정보 ===" -ForegroundColor Cyan
    
    if ($response.access_token) {
        Write-Host "Access Token    : $($response.access_token)" -ForegroundColor Green
    }
    
    if ($response.refresh_token) {
        Write-Host "Refresh Token   : $($response.refresh_token)" -ForegroundColor Green
    }
    
    if ($response.token_type) {
        Write-Host "Token Type      : $($response.token_type)" -ForegroundColor White
    }
    
    if ($response.expires_in) {
        Write-Host "만료 시간       : $($response.expires_in)초 ($([math]::Round($response.expires_in / 60, 2))분)" -ForegroundColor White
        $expiryTime = (Get-Date).AddSeconds($response.expires_in)
        Write-Host "만료 예정 시각  : $($expiryTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor White
    }
    
    if ($response.scope) {
        Write-Host "Scope           : $($response.scope)" -ForegroundColor White
    }

    Write-Host ""
    Write-Host "💡 사용 예시 (HTTP Header):" -ForegroundColor Yellow
    if ($response.token_type -and $response.access_token) {
        Write-Host "   Authorization: $($response.token_type) $($response.access_token)" -ForegroundColor Gray
    }
    elseif ($response.access_token) {
        Write-Host "   Authorization: Bearer $($response.access_token)" -ForegroundColor Gray
    }

    # 클립보드에 access_token 복사 (선택사항)
    if ($response.access_token) {
        try {
            Set-Clipboard -Value $response.access_token
            Write-Host ""
            Write-Host "📋 Access Token이 클립보드에 복사되었습니다." -ForegroundColor Cyan
        }
        catch {
            # 클립보드 복사 실패 시 무시
        }
    }

}
catch {
    Write-Host "❌ 토큰 발행 실패!" -ForegroundColor Red
    Write-Host ""
    
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode.value__
        $statusDescription = $_.Exception.Response.StatusDescription
        Write-Host "HTTP 상태 코드: $statusCode $statusDescription" -ForegroundColor Red
        
        try {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            $reader.Close()
            
            Write-Host "응답 내용:" -ForegroundColor Yellow
            
            # JSON 응답인 경우 포맷팅
            try {
                $errorJson = $responseBody | ConvertFrom-Json
                $errorJson | ConvertTo-Json -Depth 10 | Write-Host -ForegroundColor White
                
                if ($errorJson.error) {
                    Write-Host ""
                    Write-Host "에러: $($errorJson.error)" -ForegroundColor Red
                }
                if ($errorJson.error_description) {
                    Write-Host "설명: $($errorJson.error_description)" -ForegroundColor Red
                }
            }
            catch {
                Write-Host $responseBody -ForegroundColor White
            }
        }
        catch {
            Write-Host "응답 본문을 읽을 수 없습니다." -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "오류 메시지: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
    exit 1
}

Write-Host "--- 완료 ---`n" -ForegroundColor Cyan
