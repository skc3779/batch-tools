do {
    Clear-Host
    Write-Host "================================"
    Write-Host "    Java Version Switcher"
    Write-Host "================================"
    Write-Host ""
    Write-Host "Available Java Versions:"
    Write-Host ""
    Write-Host "  1) Java 6"
    Write-Host "  2) Java 7"
    Write-Host "  3) Java 8"
    Write-Host "  4) Java 11"
    Write-Host "  5) Java 17"
    Write-Host "  6) Java 21"
    Write-Host "  7) Java 25"
    Write-Host ""
    Write-Host "================================"
    Write-Host ""

    $choice = Read-Host "Select a version (1-7)"

    $javaHomeEnv = ""
    $javaVersion = ""
    $validChoice = $true

    switch ($choice) {
        "1" {
            $javaHomeEnv = $env:JAVA_HOME_6
            $javaVersion = "Java 6"
        }
        "2" {
            $javaHomeEnv = $env:JAVA_HOME_7
            $javaVersion = "Java 7"
        }
        "3" {
            $javaHomeEnv = "C:\Java\jdk-1.8u472-b08"
            $javaVersion = "Java 8"
        }
        "4" {
            $javaHomeEnv = $env:JAVA_HOME_11
            $javaVersion = "Java 11"
        }
        "5" {
            $javaHomeEnv = $env:JAVA_HOME_17
            $javaVersion = "Java 17"
        }
        "6" {
            $javaHomeEnv = $env:JAVA_HOME_21
            $javaVersion = "Java 21"
        }
        "7" {
            $javaHomeEnv = $env:JAVA_HOME_25
            $javaVersion = "Java 25"
        }
        default {
            Write-Host ""
            Write-Host "Invalid selection. Please try again." -ForegroundColor Red
            Start-Sleep -Seconds 2
            $validChoice = $false
        }
    }

    if ($validChoice) {
        if ([string]::IsNullOrEmpty($javaHomeEnv)) {
            Write-Host ""
            Write-Host "Error: Environment variable for selected version is not set" -ForegroundColor Red
            Start-Sleep -Seconds 3
            $validChoice = $false
        }
    }

    if ($validChoice) {
        $env:JAVA_HOME = $javaHomeEnv
        $env:PATH = "$env:JAVA_HOME\bin;$env:PATH"

        Write-Host ""
        Write-Host "$javaVersion activated." -ForegroundColor Green
        Write-Host ""
        java -version
        Write-Host ""
        
        $retry = Read-Host "Switch to another version? (y/n)"
        if ($retry -ne 'y' -and $retry -ne 'Y') {
            exit 0
        }
    }
} while ($true)