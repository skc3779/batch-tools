param (
    [Parameter(Mandatory=$true, HelpMessage="API 엔드포인트 URL을 입력하세요 (예: https://api.example.com/users)")]
    [string]$Url,

    [Parameter(Mandatory=$false, HelpMessage="HTTP 메서드를 지정하세요")]
    [ValidateSet("GET", "POST", "PUT", "DELETE", "PATCH", "HEAD", "OPTIONS")]
    [string]$Method = "GET",

    [Parameter(Mandatory=$false, HelpMessage="요청 본문 (JSON 형식)")]
    [string]$Body,

    [Parameter(Mandatory=$false, HelpMessage="요청 본문 파일 경로 (JSON 파일)")]
    [string]$BodyFile,

    [Parameter(Mandatory=$false, HelpMessage="Authorization 헤더 값 (예: Bearer token123)")]
    [string]$Authorization,

    [Parameter(Mandatory=$false, HelpMessage="Content-Type 헤더 값")]
    [string]$ContentType = "application/json",

    [Parameter(Mandatory=$false, HelpMessage="추가 헤더 (JSON 형식, 예: '{\"X-Custom\":\"value\"}')")]
    [string]$Headers,

    [Parameter(Mandatory=$false)]
    [switch]$ShowHeaders,

    [Parameter(Mandatory=$false)]
    [switch]$ShowFullResponse,

    [Parameter(Mandatory=$false, HelpMessage="타임아웃 (초)")]
    [int]$TimeoutSec = 30
)

# 출력 인코딩을 UTF-8로 설정 (한글 깨짐 방지)
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "         API 호출 테스트" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "🌐 URL     : $Url" -ForegroundColor White
Write-Host "📋 Method  : $Method" -ForegroundColor White
Write-Host "⏱️  Timeout : $TimeoutSec 초" -ForegroundColor Gray
Write-Host ""

try {
    # 헤더 구성
    $requestHeaders = @{}
    
    if ($Authorization) {
        $requestHeaders["Authorization"] = $Authorization
        Write-Host "🔑 Authorization 헤더 추가됨" -ForegroundColor Yellow
    }
    
    # 추가 헤더 파싱
    if ($Headers) {
        try {
            $customHeaders = $Headers | ConvertFrom-Json
            foreach ($key in $customHeaders.PSObject.Properties.Name) {
                $requestHeaders[$key] = $customHeaders.$key
                Write-Host "📌 커스텀 헤더 추가: $key = $($customHeaders.$key)" -ForegroundColor Yellow
            }
        }
        catch {
            Write-Host "⚠️  경고: 헤더 JSON 파싱 실패 - $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
    
    # 요청 본문 처리
    $requestBody = $null
    if ($BodyFile) {
        if (Test-Path $BodyFile) {
            $requestBody = Get-Content -Path $BodyFile -Raw -Encoding UTF8
            Write-Host "📄 요청 본문을 파일에서 로드: $BodyFile" -ForegroundColor Yellow
        }
        else {
            Write-Host "❌ 파일을 찾을 수 없습니다: $BodyFile" -ForegroundColor Red
            exit 1
        }
    }
    elseif ($Body) {
        $requestBody = $Body
        Write-Host "📝 요청 본문이 제공되었습니다" -ForegroundColor Yellow
    }
    
    # 요청 본문 미리보기
    if ($requestBody -and ($Method -in @("POST", "PUT", "PATCH"))) {
        Write-Host ""
        Write-Host "📤 Request Body:" -ForegroundColor Cyan
        try {
            # JSON 포맷팅 시도
            $jsonBody = $requestBody | ConvertFrom-Json
            $jsonBody | ConvertTo-Json -Depth 10 | Write-Host -ForegroundColor Gray
        }
        catch {
            Write-Host $requestBody -ForegroundColor Gray
        }
    }
    
    Write-Host ""
    Write-Host "⏳ 요청 전송 중..." -ForegroundColor Yellow
    
    # 시작 시간 기록
    $startTime = Get-Date
    
    # API 호출 파라미터 구성
    $invokeParams = @{
        Uri = $Url
        Method = $Method
        TimeoutSec = $TimeoutSec
        ErrorAction = 'Stop'
    }
    
    if ($requestHeaders.Count -gt 0) {
        $invokeParams['Headers'] = $requestHeaders
    }
    
    if ($requestBody -and ($Method -in @("POST", "PUT", "PATCH", "DELETE"))) {
        $invokeParams['Body'] = $requestBody
        $invokeParams['ContentType'] = $ContentType
    }
    
    # Invoke-WebRequest 사용 (응답 헤더 포함)
    $response = Invoke-WebRequest @invokeParams
    
    # 종료 시간 기록
    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalMilliseconds
    
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "         응답 결과" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""
    
    # 상태 코드 표시
    $statusCode = $response.StatusCode
    $statusColor = if ($statusCode -ge 200 -and $statusCode -lt 300) { "Green" } 
                   elseif ($statusCode -ge 300 -and $statusCode -lt 400) { "Yellow" }
                   else { "Red" }
    
    Write-Host "✅ Status Code  : $statusCode $($response.StatusDescription)" -ForegroundColor $statusColor
    Write-Host "⚡ 응답 시간    : $([math]::Round($duration, 2)) ms" -ForegroundColor White
    Write-Host "📊 Content Type : $($response.Headers['Content-Type'])" -ForegroundColor White
    Write-Host "📏 Content Size : $($response.RawContentLength) bytes" -ForegroundColor White
    
    # 응답 헤더 표시
    if ($ShowHeaders -or $ShowFullResponse) {
        Write-Host ""
        Write-Host "📋 Response Headers:" -ForegroundColor Cyan
        foreach ($header in $response.Headers.GetEnumerator() | Sort-Object Key) {
            Write-Host "  $($header.Key): $($header.Value)" -ForegroundColor Gray
        }
    }
    
    # 응답 본문 표시
    Write-Host ""
    Write-Host "📦 Response Body:" -ForegroundColor Cyan
    
    $contentType = $response.Headers['Content-Type']
    
    if ($contentType -match 'application/json') {
        try {
            $jsonResponse = $response.Content | ConvertFrom-Json
            $jsonResponse | ConvertTo-Json -Depth 10 | Write-Host -ForegroundColor White
        }
        catch {
            Write-Host $response.Content -ForegroundColor White
        }
    }
    elseif ($contentType -match 'text/') {
        Write-Host $response.Content -ForegroundColor White
    }
    elseif ($contentType -match 'application/xml' -or $contentType -match 'text/xml') {
        try {
            [xml]$xmlResponse = $response.Content
            $xmlResponse.OuterXml | Write-Host -ForegroundColor White
        }
        catch {
            Write-Host $response.Content -ForegroundColor White
        }
    }
    else {
        Write-Host "  (바이너리 데이터 또는 지원하지 않는 Content-Type)" -ForegroundColor Yellow
        Write-Host "  첫 200자: $($response.Content.Substring(0, [Math]::Min(200, $response.Content.Length)))" -ForegroundColor Gray
    }
    
    # 전체 응답 객체 표시 (디버깅용)
    if ($ShowFullResponse) {
        Write-Host ""
        Write-Host "🔍 Full Response Object:" -ForegroundColor Cyan
        $response | Format-List * | Out-String | Write-Host -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "✅ 요청 완료" -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""
    
}
catch [System.Net.WebException] {
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Red
    Write-Host "         오류 발생" -ForegroundColor Red
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Red
    Write-Host ""
    
    $errorResponse = $_.Exception.Response
    
    if ($errorResponse) {
        $statusCode = [int]$errorResponse.StatusCode
        $statusDescription = $errorResponse.StatusDescription
        
        Write-Host "❌ HTTP Status  : $statusCode $statusDescription" -ForegroundColor Red
        
        try {
            $reader = New-Object System.IO.StreamReader($errorResponse.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            $reader.Close()
            
            Write-Host ""
            Write-Host "📦 Error Response Body:" -ForegroundColor Yellow
            
            # JSON 파싱 시도
            try {
                $errorJson = $responseBody | ConvertFrom-Json
                $errorJson | ConvertTo-Json -Depth 10 | Write-Host -ForegroundColor White
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
        Write-Host "❌ 오류: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
    exit 1
}
catch {
    Write-Host ""
    Write-Host "❌ 예상치 못한 오류 발생!" -ForegroundColor Red
    Write-Host "오류 메시지: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 도움말:" -ForegroundColor Yellow
    Write-Host "  - URL이 올바른지 확인하세요" -ForegroundColor Gray
    Write-Host "  - 네트워크 연결을 확인하세요" -ForegroundColor Gray
    Write-Host "  - JSON 형식이 올바른지 확인하세요" -ForegroundColor Gray
    Write-Host ""
    exit 1
}
