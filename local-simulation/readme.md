# 本地模拟 MinIO 分布式集群启动说明

本项目用于在 Windows 本地环境下模拟 MinIO 分布式集群。你可以通过分别启动 4 个批处理（.bat）文件，体验和测试 MinIO 的分布式特性。

## 目录结构

```
─ local-simulation\
     ├─ start-minio1.bat
     ├─ start-minio2.bat
     ├─ start-minio3.bat
     └─ start-minio4.bat
```

## 启动步骤

1. **启动 4 个节点**
   - 分别双击 `start-minio1.bat`、`start-minio2.bat`、`start-minio3.bat`、`start-minio4.bat`，每个文件会打开一个命令行窗口，模拟一个 MinIO 节点。
   - 每个节点监听不同的数据端口（9001~9004）和控制台端口（9011~9014）。

2. **访问控制台**
   - 分别在浏览器访问：
     - [http://127.0.0.1:9011](http://127.0.0.1:9011)
     - [http://127.0.0.1:9012](http://127.0.0.1:9012)
     - [http://127.0.0.1:9013](http://127.0.0.1:9013)
     - [http://127.0.0.1:9014](http://127.0.0.1:9014)
   - 默认用户名和密码均为 `minioadmin`。

3. **注意事项**
   - 四个 `.bat` 文件中的节点列表（`http://127.0.0.1:900X/miniodataX`）必须完全一致，顺序也要一致。
   - 每个节点的 `--address` 和 `--console-address` 端口不能重复。
   - 这些脚本仅用于本地测试和学习，生产环境请使用多台服务器和真实 IP。

## 批处理文件内容说明（以 start-minio4.bat 为例）

```bat
@echo off
set MINIO_ROOT_USER=minioadmin
set MINIO_ROOT_PASSWORD=minioadmin
minio.exe server ^
 http://127.0.0.1:9001/miniodata1 ^
 http://127.0.0.1:9002/miniodata2 ^
 http://127.0.0.1:9003/miniodata3 ^
 http://127.0.0.1:9004/miniodata4 ^
 --console-address :9014 --address :9004
pause
```

- `MINIO_ROOT_USER` 和 `MINIO_ROOT_PASSWORD`：设置 MinIO 管理员账号和密码。
- `minio.exe server ...`：启动 MinIO 服务，参数为所有节点的地址和数据目录。
- `--console-address`：指定控制台端口。
- `--address`：指定数据服务端口。
- `pause`：窗口保持，方便查看日志和错误信息。

## 常见问题

- **端口冲突**：确保 9001~9004 和 9011~9014 端口未被其他程序占用。
- **节点启动失败**：检查数据目录是否存在，命令参数是否一致。
- **访问不了控制台**：确认防火墙未阻止相关端口。
