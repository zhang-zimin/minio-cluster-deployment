# MinIO 集群部署指南

🚀 MinIO 分布式对象存储集群的完整部署方案集合

## 📋 项目概述

本项目提供了多种 MinIO 集群部署方案，包括 Docker 容器化部署、Linux 原生部署和 Windows 本地部署。支持单机多节点和多机分布式两种架构，满足不同场景的需求。

### ✨ 特性

- 🐳 **容器化部署**：基于 Docker 的快速部署方案
- 🐧 **原生部署**：Linux 系统下的生产级部署
- 🪟 **Windows 支持**：Windows 环境下的开发测试方案
- 📊 **监控日志**：完整的日志管理和监控配置
- 🔧 **自动化脚本**：一键部署和管理脚本

## 🚀 快速开始

### 环境要求

- **最低硬件要求**：每台服务器至少 2GB 内存，50GB 磁盘空间
- **推荐硬件配置**：4GB+ 内存，SSD 存储，千兆网络
- **操作系统支持**：Linux（Ubuntu 20.04+, CentOS 7+），Windows 10+
- **网络要求**：节点间网络互通，防火墙开放 9000、9001 端口

## 📦 部署方式

### 1. 🐳 Docker 部署（推荐用于开发测试）

**优势**：部署简单，环境隔离，易于管理
**适用场景**：开发测试、概念验证、快速部署

#### 单机集群部署
```bash
# 克隆项目
git clone <repository-url>
cd minio-cluster

# 启动单机集群（4个节点）
cd docker-deployment
docker-compose up -d

# 查看服务状态
docker-compose ps

# 访问 Web 控制台
# http://localhost:9001 (用户名: minioadmin, 密码: minioadmin)
```

#### 多机分布式部署
```bash
# 1. 修改配置文件中的IP地址
cd docker-distributed-deployment
vim docker-compose-distributed.yml

# 2. 在每台机器上运行
docker-compose -f docker-compose-distributed.yml up -d

# 3. 查看集群状态
docker-compose -f docker-compose-distributed.yml ps
```

### 2. 🐧 Linux 原生部署（推荐用于生产环境）

**优势**：性能最优，资源利用率高，生产级稳定性
**适用场景**：生产环境，高性能需求，企业级部署

```bash
# 查看详细部署指南
cat linux-deployment/README.md

# 快速部署步骤
cd linux-deployment

# 1. 安装 MinIO 二进制文件
sudo wget https://dl.min.io/server/minio/release/linux-amd64/minio
sudo chmod +x minio
sudo mv minio /usr/local/bin/

# 2. 创建用户和目录
sudo useradd -r -s /bin/false minio-user
sudo mkdir -p /mnt/data/minio
sudo chown -R minio-user:minio-user /mnt/data/minio

# 3. 复制配置文件
sudo cp etc/default/minio /etc/default/minio
sudo cp etc/systemd/system/minio.service /etc/systemd/system/minio.service

# 4. 修改配置文件中的IP地址
sudo vim /etc/default/minio

# 5. 启动服务
sudo systemctl daemon-reload
sudo systemctl start minio
sudo systemctl enable minio

# 6. 查看服务状态
sudo systemctl status minio
```

### 3. 🪟 Windows 本地部署（推荐用于开发调试）

**优势**：Windows 环境友好，开发调试方便
**适用场景**：Windows 开发环境，本地测试

```batch
:: 进入 Windows 部署目录
cd windows-deployment

:: 启动 MinIO 服务
start-minio.bat

:: 查看服务状态
:: 打开任务管理器查看 minio.exe 进程
:: 或查看日志文件：logs/minio-service.log
```

## 📁 项目结构

```
minio-cluster/
├── README.md                                   # 项目总体说明（本文件）
├── mc.md                                      # MinIO 客户端命令参考手册
├── docker-deployment/                        # Docker 容器化部署
│   ├── docker-compose.yml                   # 单机多容器配置
│   └── readme.md                            # Docker 部署说明
├── docker-distributed-deployment/           # Docker 分布式部署
│   ├── docker-compose-distributed.yml      # 多机分布式配置
│   ├── check-logs.sh                       # 日志检查脚本
│   ├── LOG_MANAGEMENT.md                   # 日志管理指南
│   └── logrotate-minio.conf                # 日志轮转配置
├── linux-deployment/                        # Linux 原生部署
│   ├── README.md                           # 详细部署指南
│   └── etc/                                # 配置文件模板
│       ├── default/
│       │   └── minio                       # 环境变量配置
│       └── systemd/
│           └── system/
│               └── minio.service           # SystemD 服务配置
└── windows-deployment/                      # Windows 批处理脚本
    ├── readme.md                           # Windows 部署说明
    ├── start-minio.bat                     # 启动脚本
    ├── nssm.exe                           # Windows 服务管理工具
    └── logs/                              # 日志目录
        └── minio-service.log              # 服务日志文件
```

### 📋 文件说明

| 文件/目录 | 说明 | 用途 |
|-----------|------|------|
| `README.md` | 项目总体说明 | 快速了解项目和部署方案 |
| `mc.md` | MinIO 客户端命令参考 | MinIO 管理和操作命令 |
| `docker-deployment/` | Docker 单机部署 | 开发测试环境快速部署 |
| `docker-distributed-deployment/` | Docker 分布式部署 | 多机器容器化部署 |
| `linux-deployment/` | Linux 原生部署 | 生产环境推荐部署方案 |
| `windows-deployment/` | Windows 本地部署 | Windows 开发调试环境 |


## 🔧 集群管理

### MinIO 客户端 (mc) 配置

```bash
# 安装 MinIO 客户端
wget https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x mc
sudo mv mc /usr/local/bin/

# 配置集群连接
mc alias set mycluster http://your-cluster-endpoint:9000 minioadmin minioadmin

# 查看集群状态
mc admin info mycluster

# 创建存储桶
mc mb mycluster/my-bucket

# 查看存储桶列表
mc ls mycluster
```

### 常用管理命令

```bash
# 集群健康检查
mc admin service status mycluster

# 查看集群配置
mc admin config get mycluster

# 重启集群服务
mc admin service restart mycluster

# 查看用户列表
mc admin user list mycluster

# 设置存储桶策略
mc policy set public mycluster/my-bucket
```

## 🌐 访问集群

### Web 控制台
- **URL**: `http://your-server-ip:9001`
- **默认用户名**: `minioadmin`
- **默认密码**: `minioadmin`

### API 端点
- **API URL**: `http://your-server-ip:9000`
- **S3 兼容**: 支持 AWS S3 API

### 客户端连接示例

**Python (boto3)**:
```python
import boto3

s3_client = boto3.client(
    's3',
    endpoint_url='http://your-server-ip:9000',
    aws_access_key_id='minioadmin',
    aws_secret_access_key='minioadmin'
)
```

**Java (AWS SDK)**:
```java
AmazonS3 s3Client = AmazonS3ClientBuilder.standard()
    .withEndpointConfiguration(new EndpointConfiguration("http://your-server-ip:9000", "us-east-1"))
    .withCredentials(new AWSStaticCredentialsProvider(new BasicAWSCredentials("minioadmin", "minioadmin")))
    .build();
```

## ⚠️ 重要注意事项

### 生产环境部署
- **安全性**：
  - 🔒 修改默认用户名和密码
  - 🛡️ 配置 HTTPS/TLS 加密
  - 🔐 设置适当的访问策略和权限
  - 🚪 配置防火墙规则

- **高可用性**：
  - 🔄 至少部署 4 个节点实现高可用
  - ⚖️ 使用负载均衡器分发流量
  - 🕒 确保所有节点时间同步 (NTP)
  - 📊 配置监控和告警

- **性能优化**：
  - 💾 使用 SSD 存储提高 I/O 性能
  - 🌐 配置高速网络连接
  - 🔧 调整系统内核参数
  - 📈 监控磁盘使用情况

### 数据安全
- **备份策略**：
  - 📋 制定定期备份计划
  - 🔄 测试备份恢复流程
  - 🌍 考虑异地备份方案
  - 📝 保留备份历史记录

- **网络配置**：
  - 🚧 确保防火墙开放必要端口 (9000, 9001)
  - 🔗 验证节点间网络连通性
  - 🛡️ 配置网络隔离和访问控制
  - 📡 监控网络流量和性能

### 维护建议
- **日常维护**：
  - 🔍 定期检查集群健康状态
  - 📊 监控磁盘使用情况
  - 📜 查看系统日志
  - 🔄 更新 MinIO 版本

- **故障处理**：
  - 🚨 建立故障响应流程
  - 🔧 准备故障排除工具
  - 📞 建立技术支持联系方式
  - 📋 记录故障处理过程

## 🆘 故障排除

### 常见问题

1. **服务无法启动**
   ```bash
   # 检查服务状态
   sudo systemctl status minio
   
   # 查看详细日志
   sudo journalctl -u minio -f
   
   # 检查端口占用
   sudo netstat -tlnp | grep 9000
   ```

2. **节点无法连接**
   ```bash
   # 检查网络连通性
   ping target-node-ip
   telnet target-node-ip 9000
   
   # 检查防火墙
   sudo ufw status
   sudo firewall-cmd --list-all
   ```

3. **权限问题**
   ```bash
   # 检查数据目录权限
   ls -la /mnt/data/minio
   
   # 修复权限
   sudo chown -R minio-user:minio-user /mnt/data/minio
   ```

### 获取帮助

- 📚 [MinIO 官方文档](https://min.io/docs/)
- 🐛 [GitHub Issues](https://github.com/minio/minio/issues)
- 💬 [MinIO Slack 社区](https://slack.min.io/)
- 📧 [技术支持](https://min.io/support/)

---

## 📜 许可证

本项目采用 MIT 许可证，详情请参阅 LICENSE 文件。

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进本项目！

---

**⭐ 如果这个项目对你有帮助，请给个 Star！**

