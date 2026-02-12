#!/bin/bash

# Define colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Check if Maven is installed
if ! command -v mvn &> /dev/null; then
    echo -e "${RED}[ERROR] Maven을 찾을 수 없습니다. PATH 설정을 확인하거나 Maven을 설치해주세요.${NC}"
    echo -e "${CYAN}Required: Maven 3.8.x or 3.9.x${NC}"
    exit 1
fi

# Get Maven version string (first line)
MVN_OUTPUT=$(mvn -v | head -n 1)
# Extract version number (e.g. "Apache Maven 3.8.6 ..." -> "3.8.6")
# This assumes the standard output format "Apache Maven <version> ..."
MVN_VERSION=$(echo "$MVN_OUTPUT" | sed -n 's/Apache Maven \([0-9.]*\).*/\1/p')

# Check if version starts with 3.8. or 3.9.
if [[ "$MVN_VERSION" =~ ^3\.[89]\. ]]; then
    echo -e "${GREEN}[OK] Maven 버전 확인 완료: $MVN_VERSION${NC}"
    exit 0
else
    echo -e "${RED}[ERROR] 호환되지 않는 Maven 버전입니다.${NC}"
    echo -e "${YELLOW}현재 버전: $MVN_VERSION ($MVN_OUTPUT)${NC}"
    echo -e "${CYAN}권장 버전: Maven 3.8.x 또는 3.9.x${NC}"
    echo -e "${CYAN}다운로드: https://maven.apache.org/download.cgi${NC}"
    exit 1
fi
