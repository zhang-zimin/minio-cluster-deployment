@echo off
setlocal EnableDelayedExpansion
REM ========================================
REM MinIO Distributed Cluster Startup Script
REM Version: 1.0
REM Author: Bentley Systems, Incorporated.
REM Created: 2025-07-07
REM ========================================

REM Set MinIO executable file path
set "MINIO_PATH=C:\dev\minio\minio.exe"  

REM Check if executable file path exists
if not exist "%MINIO_PATH%" (
    echo Error: MinIO executable not found at %MINIO_PATH%
    pause
    exit /b 1
)

set "BASE_PATH=C:/dev/minio-cluster/windows-deployment"

set MINIO_ROOT_USER=minioadmin
set MINIO_ROOT_PASSWORD=minioadmin

REM Create data directories
if not exist "%BASE_PATH%\miniodata1" mkdir "%BASE_PATH%\miniodata1"
if not exist "%BASE_PATH%\miniodata2" mkdir "%BASE_PATH%\miniodata2"
if not exist "%BASE_PATH%\miniodata3" mkdir "%BASE_PATH%\miniodata3"
if not exist "%BASE_PATH%\miniodata4" mkdir "%BASE_PATH%\miniodata4"

"%MINIO_PATH%" server ^
 http://127.0.0.1:9000/%BASE_PATH%/miniodata1 ^
 http://10.0.0.2:9000/%BASE_PATH%/miniodata2 ^
 http://10.0.0.3:9000/%BASE_PATH%/miniodata3 ^
 http://100.0.0.4:9000/%BASE_PATH%/miniodata4 ^
 --console-address :9001 --address :9000