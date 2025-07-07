@echo off

echo ========================================
echo MinIO 分布式集群服务安装程序
echo ========================================
echo.

REM 设置MinIO可执行文件的路径
set "MINIO_PATH=C:\dev\minio\minio.exe"  

REM 检查可执行文件的路径是否存在
if not exist "%MINIO_PATH%" (
    echo Error: MinIO executable not found at %MINIO_PATH%
    pause
    exit /b 1
)

set "BASE_PATH=C:/dev/minio-cluster/windows-deployment"

set MINIO_ROOT_USER=minioadmin
set MINIO_ROOT_PASSWORD=minioadmin

REM 创建数据目录
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