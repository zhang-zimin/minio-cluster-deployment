# MinIO 集群部署指南

🚀 MinIO 分布式对象存储集群的完整部署方案集合

## 📋 项目概述

本项目提供了多种 MinIO 集群部署方案，包括 Docker 容器化部署、Linux 原生部署和 Windows 本地部署。支持单机多节点和多机分布式两种架构，满足不同场景的需求。

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

