@echo off
set MINIO_ROOT_USER=minioadmin
set MINIO_ROOT_PASSWORD=minioadmin

REM 创建C盘数据目录（如果不存在）
if not exist "C:\dev\minio-cluster\windows-deployment\miniodata1" mkdir "C:\dev\minio-cluster\windows-deployment\miniodata1"
if not exist "C:\dev\minio-cluster\windows-deployment\miniodata2" mkdir "C:\dev\minio-cluster\windows-deployment\miniodata2"
if not exist "C:\dev\minio-cluster\windows-deployment\miniodata3" mkdir "C:\dev\minio-cluster\windows-deployment\miniodata3"
if not exist "C:\dev\minio-cluster\windows-deployment\miniodata4" mkdir "C:\dev\minio-cluster\windows-deployment\miniodata4"

minio.exe server ^
 http://127.0.0.1:9000/C:/dev/minio-cluster/windows-deployment/miniodata1 ^
 http://127.0.0.2:9000/C:/dev/minio-cluster/windows-deployment/miniodata2 ^
 http://127.0.0.3:9000/C:/dev/minio-cluster/windows-deployment/miniodata3 ^
 http://127.0.0.4:9000/C:/dev/minio-cluster/windows-deployment/miniodata4 ^
 --console-address :9001 --address :9000