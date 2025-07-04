@echo off
set MINIO_ROOT_USER=minioadmin
set MINIO_ROOT_PASSWORD=minioadmin
minio.exe server ^
 http://127.0.0.1:9001/miniodata1 ^
 http://127.0.0.1:9002/miniodata2 ^
 http://127.0.0.1:9003/miniodata3 ^
 http://127.0.0.1:9004/miniodata4 ^
 --console-address :9012 --address :9002
pause