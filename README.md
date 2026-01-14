# Batch Tools

Windows 환경에서 사용하는 유틸리티 스크립트 모음입니다.

## 📋 목록

### 1. check-tls.ps1
TLS/SSL 프로토콜 버전 지원 여부를 확인하는 PowerShell 스크립트입니다.

**기능:**
- 특정 도메인의 TLS 프로토콜 지원 버전 확인 (SSL2, SSL3, TLS 1.0, 1.1, 1.2, 1.3)
- 포트 지정 가능 (기본값: 443)

**사용 예시:**
```powershell
# 기본 사용 (포트 443)
.\check-tls.ps1 -Domain google.com

# 포트 지정
.\check-tls.ps1 -Domain example.com -Port 8443
```

---

### 2. test-netconnection.ps1
네트워크 연결 테스트를 수행하는 PowerShell 스크립트입니다.

**기능:**
- 호스트/IP 연결 테스트 (Ping)
- 특정 포트 연결 테스트
- TraceRoute 기능
- 상세 출력 옵션

**사용 예시:**
```powershell
# 기본 Ping 테스트
.\test-netconnection.ps1 -ComputerName google.com

# 포트 테스트
.\test-netconnection.ps1 -ComputerName www.naver.com -Port 443

# TraceRoute 포함
.\test-netconnection.ps1 -ComputerName google.com -Port 443 -TraceRoute

# 상세 출력
.\test-netconnection.ps1 -ComputerName google.com -DetailedOutput
```

---

### 3. kill-port.ps1
특정 포트를 사용하는 프로세스를 찾아 즉시 종료하는 스크립트입니다.

**기능:**
- 특정 포트를 점유한 프로세스 자동 검색
- 프로세스 상세 정보 표시 (이름, ID, 경로, 메모리, 연결 상태)
- 정상 종료 또는 강제 종료 옵션
- 관리자 권한 확인 및 경고
- 포트 해제 여부 최종 확인

**사용 예시:**
```powershell
# 기본 사용 (정상 종료)
.\kill-port.ps1 -Port 8080

# 강제 종료
.\kill-port.ps1 -Port 3000 -Force

# 일반적인 개발 포트
.\kill-port.ps1 -Port 3000  # Node.js
.\kill-port.ps1 -Port 8080  # Spring Boot, Tomcat
.\kill-port.ps1 -Port 5000  # Flask, ASP.NET
```

**사용 팁:**
- "Port already in use" 에러 발생 시 작업 관리자를 열 필요 없이 즉시 해결
- 관리자 권한으로 실행하면 모든 프로세스 종료 가능
- `-Force` 옵션은 프로세스가 정상 종료되지 않을 때 사용

---

### 4. test-api.ps1
REST API 호출을 테스트하는 CLI 기반 Postman 대체 스크립트입니다.

**기능:**
- 모든 HTTP 메서드 지원 (GET, POST, PUT, DELETE, PATCH, HEAD, OPTIONS)
- Authorization 헤더 지원 (Bearer 토큰 등)
- 커스텀 헤더 추가 가능
- Request Body 지원 (문자열 또는 파일)
- JSON/XML 자동 포맷팅 (요청/응답)
- 응답 시간 측정
- 상태 코드별 색상 표시 (2xx: Green, 3xx: Yellow, 4xx/5xx: Red)
- 응답 헤더 표시 옵션

**사용 예시:**
```powershell
# 1. 간단한 GET 요청
.\test-api.ps1 -Url "https://api.github.com/users/octocat"

# 2. Authorization 헤더 포함
.\test-api.ps1 `
    -Url "https://api.example.com/users" `
    -Authorization "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

# 3. POST 요청 (JSON Body)
.\test-api.ps1 `
    -Url "https://api.example.com/users" `
    -Method POST `
    -Body '{"name":"John","email":"john@example.com"}' `
    -Authorization "Bearer token123"

# 4. JSON 파일에서 Body 로드
.\test-api.ps1 `
    -Url "https://api.example.com/users" `
    -Method POST `
    -BodyFile ".\request.json" `
    -Authorization "Bearer token123"

# 5. 커스텀 헤더 추가
.\test-api.ps1 `
    -Url "https://api.example.com/data" `
    -Headers '{"X-API-Key":"12345","X-Request-ID":"abc-123"}' `
    -ShowHeaders

# 6. PUT 요청으로 데이터 업데이트
.\test-api.ps1 `
    -Url "https://api.example.com/users/1" `
    -Method PUT `
    -Body '{"name":"Updated Name"}' `
    -Authorization "Bearer token123"

# 7. DELETE 요청
.\test-api.ps1 `
    -Url "https://api.example.com/users/1" `
    -Method DELETE `
    -Authorization "Bearer token123"

# 8. 응답 헤더 포함하여 표시
.\test-api.ps1 `
    -Url "https://api.example.com/health" `
    -ShowHeaders

# 9. 전체 응답 객체 표시 (디버깅)
.\test-api.ps1 `
    -Url "https://api.example.com/data" `
    -ShowFullResponse

# 10. 타임아웃 설정
.\test-api.ps1 `
    -Url "https://slow-api.example.com/data" `
    -TimeoutSec 60
```

**사용 팁:**
- 터미널에서 Postman처럼 API 테스트를 빠르게 수행
- JSON 자동 Pretty Print로 가독성 높은 출력
- 응답 시간 자동 측정으로 성능 모니터링
- 인증 토큰 포함한 API 테스트를 즉시 실행

---

### 5. oauth2-token.ps1
OAuth2 Password Grant Type 방식으로 액세스 토큰을 발행하는 스크립트입니다.

**기능:**
- OAuth2 Password Grant Type 인증
- Access Token 및 Refresh Token 발행
- 토큰 만료 시간 표시 및 만료 예정 시각 계산
- Access Token 자동 클립보드 복사
- 상세 에러 메시지 및 HTTP 응답 표시
- 전체 응답 내용 확인 옵션

**사용 예시:**
```powershell
# 기본 사용
.\oauth2-token.ps1 `
    -TokenEndpoint "https://auth.example.com/oauth/token" `
    -Username "user@example.com" `
    -Password "yourpassword" `
    -ClientId "your-client-id" `
    -ClientSecret "your-client-secret" `
    -Scope "read write"

# Scope만 다르게 지정
.\oauth2-token.ps1 `
    -TokenEndpoint "https://auth.example.com/oauth/token" `
    -Username "user@example.com" `
    -Password "yourpassword" `
    -ClientId "your-client-id" `
    -ClientSecret "your-client-secret" `
    -Scope "openid profile email"

# 전체 응답 내용 표시
.\oauth2-token.ps1 `
    -TokenEndpoint "https://auth.example.com/oauth/token" `
    -Username "user@example.com" `
    -Password "yourpassword" `
    -ClientId "your-client-id" `
    -ClientSecret "your-client-secret" `
    -Scope "read write" `
    -ShowFullResponse
```

**사용 팁:**
- Access Token이 자동으로 클립보드에 복사되어 바로 사용 가능
- API 테스트 시 Authorization 헤더 형식 예시 제공
- 에러 발생 시 OAuth2 표준 에러 응답 파싱하여 표시

---

### 6. switchjdk.ps1 / switchjdk.bat
Java 버전을 쉽게 전환하는 스크립트입니다.

**기능:**
- 대화형 메뉴를 통한 Java 버전 선택
- 지원 버전: Java 6, 7, 8, 11, 17, 21, 25
- JAVA_HOME 환경 변수 자동 설정
- 변경 사항 현재 세션에 즉시 적용

**사전 요구사항:**
환경 변수에 각 Java 버전별 경로가 설정되어 있어야 합니다:
- `JAVA_HOME_6`
- `JAVA_HOME_7`
- `JAVA_HOME_8`
- `JAVA_HOME_11`
- `JAVA_HOME_17`
- `JAVA_HOME_21`
- `JAVA_HOME_25`

**사용 예시:**
```powershell
# PowerShell 버전
.\switchjdk.ps1

# Batch 버전
.\switchjdk.bat
```

실행 후 메뉴에서 원하는 Java 버전을 선택하면 됩니다.

---

## 🔧 요구사항

- Windows 10 이상
- PowerShell 5.1 이상
- 관리자 권한 (일부 스크립트: kill-port.ps1)

## 📝 라이선스

MIT License
