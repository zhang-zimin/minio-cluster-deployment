# MinIO 分布式集群 Windows 部署指南

本项目用于在 Windows 环境下部署 MinIO 分布式集群。支持两种部署方式：
1. **手动启动方式**：通过批处理文件手动启动（适用于开发和测试）
2. **Windows 服务方式**：使用 NSSM 将 MinIO 注册为 Windows 服务（适用于生产环境）

## 实际应用场景

- 你可以只将其中一个节点的数据端口（比如 9000）暴露给外部用户，其他节点的数据端口和所有控制台端口只在本地或内网开放即可。
- MinIO 集群会自动在内部协调数据分布和冗余，客户端只需连接一个节点即可正常上传、下载和管理文件。
- 使用 Windows 服务方式部署，可以实现开机自启动、故障自动重启、后台运行等企业级特性。


## 目录结构

```
windows-deployment/
├── start-minio.bat              # 原始MinIO启动脚本（分布式部署）
├── nssm.exe                     # NSSM服务管理工具
```

## 部署方式选择

### 方式一：手动启动（开发测试）

适用于开发环境和功能测试，可以快速启动和调试。

### 方式二：Windows 服务（生产环境）

适用于生产环境，具有以下优势：
- ✅ 开机自动启动
- ✅ 故障自动重启
- ✅ 后台运行，不占用桌面
- ✅ 完整的日志记录

---

## 🚀 Windows 服务部署方式（推荐）

### 前置要求

1. **下载 NSSM**：
   - 访问 [NSSM 官网](https://nssm.cc/download) 下载最新版本
   - 或者使用项目中已包含的 `nssm.exe`

2. **管理员权限**：
   - 所有操作需要以管理员身份运行命令提示符或 PowerShell

### 手动安装服务

如果需要手动安装，请按以下步骤操作：

#### 步骤1：安装 MinIO 服务

使用 NSSM 安装四个 MinIO 节点服务：

你也可以使用 NSSM 的图形界面进行配置：

```batch
# 打开 NSSM 图形界面
nssm install MinIO-Node1
```

在 NSSM 图形界面中的 **Application** 选项卡配置：

- **Path**: `C:\Windows\System32\cmd.exe`
- **Startup directory**: `C:\dev\minio-cluster\windows-deployment`
- **Arguments**: `/c "C:\dev\minio-cluster\windows-deployment\start-minio1.bat"`

**为什么使用 `/c` 参数？**

`/c` 是 Windows 命令提示符 (`cmd.exe`) 的一个参数，含义如下：

- `/c` 表示 "Carries out the command specified by string and then terminates"
- 即：执行指定的命令，然后退出命令提示符
- 如果不使用 `/c`，cmd.exe 会保持打开状态等待用户输入

**参数对比说明：**

```batch
# 错误的配置（缺少 /c）
Arguments: "C:\dev\minio-cluster\windows-deployment\start-minio1.bat"
# 问题：cmd.exe 会尝试把批处理文件路径当作普通文本处理，无法正确执行

# 正确的配置（使用 /c）
Arguments: /c "C:\dev\minio-cluster\windows-deployment\start-minio1.bat"
# 效果：cmd.exe 会执行批处理文件，然后保持运行状态（因为批处理文件中的 minio.exe 会持续运行）
```

**其他常用的 cmd.exe 参数：**

- `/k` - 执行命令后保持命令提示符打开（用于调试）
- `/s` - 修改引号的处理方式
- `/q` - 关闭回显

**完整的配置示例：**

```batch
# 节点1 - 使用 GUI 配置方式
nssm install MinIO-Node1

# 在 Application 选项卡中：
# Path: C:\Windows\System32\cmd.exe
# Startup directory: C:\dev\minio-cluster\windows-deployment
# Arguments: /c "C:\dev\minio-cluster\windows-deployment\start-minio1.bat"

# 在 Details 选项卡中：
nssm set MinIO-Node1 DisplayName "MinIO Cluster Node 1"
nssm set MinIO-Node1 Description "MinIO分布式存储集群节点1"

# 在 Log on 选项卡中：
nssm set MinIO-Node1 Start SERVICE_AUTO_START

# 在 I/O 选项卡中：
nssm set MinIO-Node1 AppStdout "C:\dev\minio-cluster\windows-deployment\logs\minio-node1.log"
nssm set MinIO-Node1 AppStderr "C:\dev\minio-cluster\windows-deployment\logs\minio-node1-error.log"

# 节点2-4 也可以使用相同的 GUI 配置方式
# 只需要修改对应的批处理文件路径和日志文件路径即可


#### 步骤2：启动服务

```batch
# 启动所有服务
net start MinIO-Node1
net start MinIO-Node2
net start MinIO-Node3
net start MinIO-Node4

# 或者使用 PowerShell
Start-Service MinIO-Node1
Start-Service MinIO-Node2
Start-Service MinIO-Node3
Start-Service MinIO-Node4
```

### 服务管理命令

#### 查看服务状态

```batch
# 查看所有 MinIO 服务状态
sc query MinIO-Node1
sc query MinIO-Node2
sc query MinIO-Node3
sc query MinIO-Node4

# 或者使用 PowerShell
Get-Service MinIO-Node*
```

#### 停止服务

```batch
# 停止所有服务
net stop MinIO-Node4
net stop MinIO-Node3
net stop MinIO-Node2
net stop MinIO-Node1

# 或者使用 PowerShell
Stop-Service MinIO-Node4
Stop-Service MinIO-Node3
Stop-Service MinIO-Node2
Stop-Service MinIO-Node1
```

#### 重启服务

```batch
# 重启所有服务
net stop MinIO-Node4 && net start MinIO-Node4
net stop MinIO-Node3 && net start MinIO-Node3
net stop MinIO-Node2 && net start MinIO-Node2
net stop MinIO-Node1 && net start MinIO-Node1
```

#### 卸载服务

```batch
# 先停止服务
net stop MinIO-Node4
net stop MinIO-Node3
net stop MinIO-Node2
net stop MinIO-Node1

# 卸载服务
nssm remove MinIO-Node4 confirm
nssm remove MinIO-Node3 confirm
nssm remove MinIO-Node2 confirm
nssm remove MinIO-Node1 confirm
```

### 日志管理

服务模式下的日志文件位置：
- 标准输出日志：`logs\minio-node1.log` 到 `logs\minio-node4.log`
- 错误日志：`logs\minio-node1-error.log` 到 `logs\minio-node4-error.log`

查看实时日志：
```batch
# 查看最新的日志
tail -f logs\minio-node1.log

# 或者使用 PowerShell
Get-Content logs\minio-node1.log -Wait
```


---

## 🔧 配置说明

### 批处理文件内容说明

以 `start-minio1.bat` 为例：

```bat
@echo off
set "BASE_PATH=C:/dev/minio-cluster/windows-deployment"

set MINIO_ROOT_USER=minioadmin
set MINIO_ROOT_PASSWORD=minioadmin

REM 创建数据目录
if not exist "%BASE_PATH%\miniodata1" mkdir "%BASE_PATH%\miniodata1"
if not exist "%BASE_PATH%\miniodata2" mkdir "%BASE_PATH%\miniodata2"
if not exist "%BASE_PATH%\miniodata3" mkdir "%BASE_PATH%\miniodata3"
if not exist "%BASE_PATH%\miniodata4" mkdir "%BASE_PATH%\miniodata4"

minio.exe server ^
 http://127.0.0.1:9000/%BASE_PATH%/miniodata1 ^
 http://127.0.0.1:9001/%BASE_PATH%/miniodata2 ^
 http://127.0.0.1:9002/%BASE_PATH%/miniodata3 ^
 http://127.0.0.1:9003/%BASE_PATH%/miniodata4 ^
 --console-address :9010 --address :9000
pause
```

**参数说明**：
- `BASE_PATH`：设置基础路径，便于统一管理
- `MINIO_ROOT_USER` 和 `MINIO_ROOT_PASSWORD`：MinIO 管理员账号和密码
- `minio.exe server ...`：启动 MinIO 服务，指定所有节点的地址和数据目录
- `--console-address`：指定控制台端口
- `--address`：指定数据服务端口
- `pause`：保持窗口打开，方便查看日志

### 重要配置要求

1. **节点一致性**：所有 `.bat` 文件中的节点列表必须完全一致，顺序也要一致
2. **端口唯一性**：每个节点的 `--address` 和 `--console-address` 端口不能重复
3. **数据目录**：确保数据目录存在且有读写权限
4. **网络配置**：确保防火墙允许相关端口通信

---

## 🛠️ 故障排除

### 常见问题

#### 1. 端口冲突
**现象**：服务启动失败，提示端口被占用  
**解决方案**：
```batch
# 检查端口占用
netstat -ano | findstr :9000
netstat -ano | findstr :9010

# 杀死占用端口的进程
taskkill /PID <进程ID> /F
```

#### 2. 服务启动失败
**现象**：Windows 服务无法启动  
**解决方案**：
1. 检查批处理文件路径是否正确
2. 确认 minio.exe 文件存在
3. 查看错误日志文件
4. 检查数据目录权限
5. **检查 NSSM 配置**：
   - 确认 Path 设置为 `C:\Windows\System32\cmd.exe`
   - 确认 Arguments 包含 `/c` 参数
   - 确认 Startup directory 设置正确
   - 使用 `nssm edit MinIO-Node1` 检查配置

#### 2.1 NSSM 配置验证
```batch
# 检查 NSSM 服务配置
nssm get MinIO-Node1 Application
nssm get MinIO-Node1 AppParameters
nssm get MinIO-Node1 AppDirectory

# 编辑现有服务配置
nssm edit MinIO-Node1
```

#### 3. 集群节点无法通信
**现象**：节点启动成功但集群状态异常  
**解决方案**：
1. 检查所有节点的配置是否一致
2. 确认防火墙设置
3. 验证网络连接
4. 检查磁盘空间

#### 4. 控制台无法访问
**现象**：浏览器无法打开控制台页面  
**解决方案**：
1. 检查服务是否正常运行
2. 确认端口是否被防火墙阻止
3. 尝试使用 127.0.0.1 而不是 localhost
4. 检查浏览器是否启用了代理

### 日志分析

#### 服务模式日志
- 位置：`logs\minio-node*.log`
- 实时监控：`tail -f logs\minio-node1.log`

#### 手动模式日志
- 直接在命令行窗口中查看
- 可以重定向到文件：`start-minio1.bat > logs\manual-node1.log 2>&1`

### 性能优化建议

1. **磁盘配置**
   - 使用 SSD 磁盘提高 I/O 性能
   - 将数据目录分散到不同的磁盘上

2. **网络优化**
   - 确保节点间网络延迟低
   - 使用千兆网络

3. **系统资源**
   - 分配足够的内存（每个节点至少 1GB）
   - 确保 CPU 资源充足

---


