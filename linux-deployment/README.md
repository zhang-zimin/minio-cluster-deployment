# Linux 原生部署 MinIO 集群指南

在 Linux 环境下不使用 Docker 部署 MinIO 分布式集群的完整指南。

## 环境要求

- Linux 系统 (Ubuntu 20.04+ )
- 至少 2 台服务器 (推荐 4 台)
- 每台服务器至少 2GB 内存
- 网络互通，防火墙开放 9000 和 9001 端口

## 服务器规划

假设有两台服务器：
- **节点1**: 172.17.169.150
- **节点2**: 172.17.169.101

## 部署步骤

### 1. 在所有节点上安装 MinIO

```bash
# 下载 MinIO 二进制文件
wget https://dl.min.io/server/minio/release/linux-amd64/minio
chmod +x minio
sudo mv minio /usr/local/bin/

# 验证安装
minio --version
```

### 2. 创建 MinIO 用户和数据目录

```bash
# 创建 minio 用户
sudo useradd -r -s /bin/false minio-user

# 创建数据目录
sudo mkdir -p /mnt/data/minio
sudo chown -R minio-user:minio-user /mnt/data/minio
sudo chmod 755 /mnt/data/minio
```

### 3. 配置 MinIO 环境文件

将项目中的配置文件复制到对应位置：

```bash
# 复制环境配置文件
sudo cp etc/default/minio /etc/default/minio
sudo chown root:root /etc/default/minio
sudo chmod 644 /etc/default/minio
```

**根据实际环境修改 `/etc/default/minio`：**

```bash
# 节点1 (172.17.169.150) 配置
MINIO_VOLUMES="http://172.17.169.150:9000/mnt/data/minio http://172.17.169.101:9000/mnt/data/minio"
MINIO_OPTS="--console-address :9001"
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin
```

```bash
# 节点2 (172.17.169.101) 配置
MINIO_VOLUMES="http://172.17.169.150:9000/mnt/data/minio http://172.17.169.101:9000/mnt/data/minio"
MINIO_OPTS="--console-address :9001"
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin
```

> **注意**: 所有节点的 `MINIO_VOLUMES` 配置必须相同！

### 4. 配置 systemd 服务

```bash
# 复制服务文件
sudo cp etc/systemd/system/minio.service /etc/systemd/system/minio.service
sudo chown root:root /etc/systemd/system/minio.service
sudo chmod 644 /etc/systemd/system/minio.service

# 重新加载 systemd 配置
sudo systemctl daemon-reload
```

### 5. 配置防火墙

```bash
# Ubuntu/Debian
sudo ufw allow 9000/tcp
sudo ufw allow 9001/tcp

# CentOS/RHEL
sudo firewall-cmd --permanent --add-port=9000/tcp
sudo firewall-cmd --permanent --add-port=9001/tcp
sudo firewall-cmd --reload
```

### 6. 启动 MinIO 服务

**在所有节点上同时启动**（重要！）：

```bash
# 启动服务
sudo systemctl start minio

# 设置开机自启
sudo systemctl enable minio

# 查看服务状态
sudo systemctl status minio
```

### 7. 验证集群状态

```bash
# 查看服务日志
sudo journalctl -u minio -f

# 检查端口监听
sudo netstat -tlnp | grep 9000
sudo netstat -tlnp | grep 9001
```

## 访问集群

- **Web 控制台**: http://172.17.169.150:9001 或 http://172.17.169.101:9001
- **API 端点**: http://172.17.169.150:9000 或 http://172.17.169.101:9000
- **用户名**: minioadmin
- **密码**: minioadmin

## 集群管理

### 安装 mc 客户端

```bash
wget https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x mc
sudo mv mc /usr/local/bin/
```

### 配置和管理

```bash
# 添加集群别名
mc alias set mycluster http://172.17.169.150:9000 minioadmin minioadmin

# 查看集群信息
mc admin info mycluster

# 查看集群状态
mc admin service status mycluster
```

## 故障排除

### 常见问题

1. **时间同步问题**
   ```bash
   # 安装并启动 NTP
   sudo apt install ntp  # Ubuntu/Debian
   sudo yum install ntp  # CentOS/RHEL
   sudo systemctl start ntp
   sudo systemctl enable ntp
   ```

2. **权限问题**
   ```bash
   # 检查数据目录权限
   ls -la /mnt/data/
   sudo chown -R minio-user:minio-user /mnt/data/minio
   ```

3. **网络连接问题**
   ```bash
   # 测试节点间连通性
   telnet 172.17.169.101 9000
   ```

4. **查看详细日志**
   ```bash
   # 实时查看日志
   sudo journalctl -u minio -f
   
   # 查看完整日志
   sudo journalctl -u minio --no-pager
   ```

## 扩展集群

要添加更多节点，需要：

1. 停止所有现有节点
2. 更新所有节点的 `MINIO_VOLUMES` 配置
3. 同时重启所有节点

