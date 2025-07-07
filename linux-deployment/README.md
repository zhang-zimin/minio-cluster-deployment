# Linux 原生部署 MinIO 集群指南

在 Linux 环境下不使用 Docker 部署 MinIO 分布式集群的完整指南。

## 📋 项目概述

本指南提供了在 Linux 环境下部署 MinIO 分布式存储集群的完整流程，包括：
- 🔧 系统配置和用户管理
- 📁 SystemD 服务配置
- 🔐 安全性配置
- 📊 监控和日志管理
- 🛠️ 故障排除和维护

## 📂 文件结构说明

```
linux-deployment/
├── README.md                    # 本部署指南
├── etc/
│   ├── default/
│   │   └── minio               # MinIO 环境变量配置文件
│   └── systemd/
│       └── system/
│           └── minio.service   # SystemD 服务配置文件
```

**配置文件说明：**
- `minio.service`: SystemD 服务单元文件，定义服务启动、停止、重启策略
- `minio`: 环境变量配置，包含存储卷路径、管理员账户等设置

## 🌐 环境要求

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
sudo wget https://dl.min.io/server/minio/release/linux-amd64/archive/minio.RELEASE.2025-01-18T00-31-37Z

# 重命名为minio
sudo mv minio.RELEASE.2025-01-18T00-31-37Z minio  

# 赋予执行权限
sudo chmod +x minio

# 移动到系统二进制目录
sudo mv minio /usr/local/bin/

# 验证安装是否成功
minio --version
```

**安装说明：**
- 下载的是静态链接的二进制文件，无需额外依赖
- `/usr/local/bin/` 是用户自安装程序的标准位置
- 所有节点必须使用相同版本的 MinIO

### 2. 创建 MinIO 用户和数据目录

```bash
# 创建系统用户（不允许登录，提高安全性）
# -r: 系统用户，-s /bin/false: 禁止登录
sudo useradd -r -s /bin/false minio-user

# 创建数据存储目录
sudo mkdir -p /mnt/data/minio

# 设置目录所有权为 minio-user
sudo chown -R minio-user:minio-user /mnt/data/minio

# 设置目录权限（755: 所有者读写执行，其他人只读执行）
sudo chmod 755 /mnt/data/minio
```

**安全说明：**
- 使用专用的系统用户运行 MinIO，避免使用 root 用户
- 数据目录权限设置确保只有 minio-user 可以写入
- 建议将数据目录挂载到独立的磁盘分区

### 3. 配置 MinIO 环境文件

将项目中的配置文件复制到对应位置：

```bash
# 复制环境配置文件到系统目录
sudo cp etc/default/minio /etc/default/minio

# 设置文件所有权为 root（系统配置文件标准权限）
sudo chown root:root /etc/default/minio

# 设置文件权限（644: 所有者读写，其他人只读）
sudo chmod 644 /etc/default/minio
```

**根据实际环境修改 `/etc/default/minio`：**

```bash
# 节点1 (172.17.169.150) 配置
# 所有节点的卷配置必须完全相同
MINIO_VOLUMES="http://172.17.169.150:9000/mnt/data/minio http://172.17.169.101:9000/mnt/data/minio"
# 控制台访问端口
MINIO_OPTS="--console-address :9001"
# 管理员账户（生产环境请使用强密码）
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin
```

```bash
# 节点2 (172.17.169.101) 配置
# 配置与节点1完全相同
MINIO_VOLUMES="http://172.17.169.150:9000/mnt/data/minio http://172.17.169.101:9000/mnt/data/minio"
MINIO_OPTS="--console-address :9001"
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin
```

> **⚠️ 重要提醒**: 
> - 所有节点的 `MINIO_VOLUMES` 配置必须相同！
> - 卷列表中的顺序也必须保持一致
> - 生产环境中请修改默认的管理员密码

### 4. 配置 SystemD 服务

```bash
# 复制服务配置文件到系统目录
sudo cp etc/systemd/system/minio.service /etc/systemd/system/minio.service

# 设置服务文件权限
sudo chown root:root /etc/systemd/system/minio.service
sudo chmod 644 /etc/systemd/system/minio.service

# 重新加载 SystemD 配置以识别新服务
sudo systemctl daemon-reload
```

**SystemD 服务配置说明：**
- 服务文件定义了 MinIO 的启动参数、用户、工作目录等
- 配置了自动重启策略和资源限制
- 设置了对网络服务的依赖关系

### 5. 配置防火墙

```bash
# Ubuntu/Debian 系统使用 UFW
sudo ufw allow 9000/tcp  # MinIO API 端口
sudo ufw allow 9001/tcp  # MinIO Web 控制台端口

# CentOS/RHEL 系统使用 firewalld
sudo firewall-cmd --permanent --add-port=9000/tcp
sudo firewall-cmd --permanent --add-port=9001/tcp
sudo firewall-cmd --reload

# 验证防火墙规则
sudo ufw status      # Ubuntu/Debian
sudo firewall-cmd --list-all  # CentOS/RHEL
```

**端口说明：**
- **9000**: MinIO API 端口，用于 S3 兼容 API 访问
- **9001**: MinIO Web 控制台端口，用于浏览器管理界面
- 确保所有节点之间的这些端口能够互相访问
sudo firewall-cmd --permanent --add-port=9000/tcp
sudo firewall-cmd --permanent --add-port=9001/tcp
sudo firewall-cmd --reload

### 6. 启动 MinIO 服务

**⚠️ 重要：必须在所有节点上同时启动服务！**

```bash
# 启动 MinIO 服务
sudo systemctl start minio

# 设置开机自启动
sudo systemctl enable minio

# 查看服务状态
sudo systemctl status minio

# 如果服务启动失败，查看详细错误信息
sudo journalctl -u minio --no-pager
```

**启动顺序说明：**
- 分布式 MinIO 要求所有节点几乎同时启动
- 如果某个节点启动过晚，可能会导致集群初始化失败
- 建议使用脚本或工具在所有节点上同时执行启动命令

### 7. 验证集群状态

```bash
# 实时查看服务日志
sudo journalctl -u minio -f

# 检查端口监听状态
sudo netstat -tlnp | grep 9000  # API 端口
sudo netstat -tlnp | grep 9001  # 控制台端口

# 检查进程状态
sudo ps aux | grep minio

# 测试集群连接
curl -I http://localhost:9000/minio/health/live
```

**验证要点：**
- 确认所有端口都在监听
- 检查日志中没有错误信息
- 验证集群节点之间能够正常通信

## 🌐 访问集群

配置完成后，可以通过以下方式访问 MinIO 集群：

### Web 控制台访问
- **节点1控制台**: http://172.17.169.150:9001
- **节点2控制台**: http://172.17.169.101:9001
- **默认用户名**: minioadmin
- **默认密码**: minioadmin

### API 端点访问
- **节点1 API**: http://172.17.169.150:9000
- **节点2 API**: http://172.17.169.101:9000

**访问说明：**
- 可以通过任意节点的地址访问集群
- 集群会自动在节点间同步数据
- 建议在生产环境中使用负载均衡器

## 📊 日志管理和监控

### 日志存储位置

MinIO 在 Linux 环境下的日志存储位置：

#### . SystemD 日志（默认）
- **位置**: SystemD 日志系统（journald）
- **持久化路径**: `/var/log/journal/`（如果启用持久化）
- **临时路径**: `/run/log/journal/`（默认，重启后清空）

### 日志查看和管理

```bash
# 查看所有 MinIO 日志
sudo journalctl -u minio

# 查看最近的日志
sudo journalctl -u minio --since "1 hour ago"

# 实时跟踪日志
sudo journalctl -u minio -f

# 查看特定时间范围的日志
sudo journalctl -u minio --since "2025-07-07 00:00:00" --until "2025-07-07 23:59:59"

# 查看最新的 100 行日志
sudo journalctl -u minio -n 100

# 导出日志到文件
sudo journalctl -u minio > minio.log

# 查看日志级别为错误的条目
sudo journalctl -u minio -p err

# 清理旧日志（保留最近 30 天）
sudo journalctl --vacuum-time=30d
```

## 🔧 集群管理

### 安装 MinIO 客户端 (mc)

```bash
# 下载 mc 客户端
wget https://dl.min.io/client/mc/release/linux-amd64/mc

# 赋予执行权限
chmod +x mc

# 移动到系统二进制目录
sudo mv mc /usr/local/bin/

# 验证安装
mc --version
```

### 配置和管理操作

```bash
# 添加集群别名配置
mc alias set mycluster http://172.17.169.150:9000 minioadmin minioadmin

# 查看集群详细信息
mc admin info mycluster

# 查看集群服务状态
mc admin service status mycluster

# 创建存储桶
mc mb mycluster/test-bucket

# 上传文件
mc cp /path/to/file mycluster/test-bucket/

# 查看存储桶列表
mc ls mycluster

# 查看集群磁盘使用情况
mc admin info mycluster
```

**管理命令说明：**
- `mc alias`: 配置集群连接信息
- `mc admin info`: 显示集群状态和磁盘使用情况
- `mc admin service`: 管理集群服务状态
- `mc mb/ls/cp`: 基本的存储桶和文件操作

## 🛠️ 故障排除

### 常见问题及解决方案

#### 1. 时间同步问题
**现象**: 集群节点间时间不同步导致认证失败
**解决方案**:
```bash
# Ubuntu/Debian 系统
sudo apt install ntp
sudo systemctl start ntp
sudo systemctl enable ntp

# CentOS/RHEL 系统
sudo yum install ntp
sudo systemctl start ntpd
sudo systemctl enable ntpd

# 手动同步时间
sudo ntpdate -s time.nist.gov
```

#### 2. 权限问题
**现象**: 服务无法启动或无法写入数据
**解决方案**:
```bash
# 检查数据目录权限
ls -la /mnt/data/

# 修复权限
sudo chown -R minio-user:minio-user /mnt/data/minio
sudo chmod 755 /mnt/data/minio

# 检查服务文件权限
sudo ls -la /etc/systemd/system/minio.service
```

#### 3. 网络连接问题
**现象**: 节点间无法通信
**解决方案**:
```bash
# 测试节点间连通性
telnet 172.17.169.101 9000
ping 172.17.169.101

# 检查防火墙状态
sudo ufw status
sudo firewall-cmd --list-all

# 检查 SELinux 状态（CentOS/RHEL）
getenforce
```

#### 4. 磁盘空间问题
**现象**: 存储操作失败
**解决方案**:
```bash
# 检查磁盘使用情况
df -h /mnt/data/minio

# 清理日志文件
sudo journalctl --vacuum-time=7d

# 检查大文件
sudo find /mnt/data/minio -type f -size +1G -exec ls -lh {} \;
```

### 服务管理常用命令

```bash
# 启动服务
sudo systemctl start minio

# 停止服务
sudo systemctl stop minio

# 重启服务
sudo systemctl restart minio

# 查看服务状态
sudo systemctl status minio

# 查看服务日志
sudo journalctl -u minio -f

# 禁用服务自启动
sudo systemctl disable minio

# 启用服务自启动
sudo systemctl enable minio
```

## 📋 维护检查清单

### 日常维护

- [ ] 检查服务状态: `sudo systemctl status minio`
- [ ] 查看磁盘使用: `df -h /mnt/data/minio`
- [ ] 检查日志错误: `sudo journalctl -u minio --since "1 hour ago"`
- [ ] 验证集群健康: `mc admin info mycluster`

### 定期维护

- [ ] 备份配置文件: `/etc/default/minio`, `/etc/systemd/system/minio.service`
- [ ] 清理旧日志文件: `sudo journalctl --vacuum-time=30d`
- [ ] 检查系统更新: `sudo apt update && sudo apt upgrade`

### 应急处理

- [ ] 准备节点故障恢复流程
- [ ] 准备数据备份和恢复方案
- [ ] 建立监控告警机制
- [ ] 制定扩容计划

---

## 📚 参考资料

- [MinIO 官方文档](https://min.io/docs/minio/linux/index.html)
- [MinIO 分布式部署指南](https://min.io/docs/minio/linux/operations/install-deploy-manage/deploy-minio-multi-node-multi-drive.html)
- [SystemD 服务管理](https://www.freedesktop.org/software/systemd/man/systemd.service.html)
- [MinIO 客户端工具](https://min.io/docs/minio/linux/reference/minio-mc.html)

---

