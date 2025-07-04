@echo off
set MINIO_VOLUMES=http://172.17.169.150:9000/mnt/data/minio http://172.17.169.101:9000/mnt/data/minio http://172.17.160.1:9000/miniodata
set MINIO_STORAGE_CLASS_STANDARD=EC:1
set MINIO_OPTS=--console-address :9001
set MINIO_ROOT_USER=minioadmin
set MINIO_ROOT_PASSWORD=minioadmin

minio.exe server %MINIO_VOLUMES% %MINIO_OPTS%
pause