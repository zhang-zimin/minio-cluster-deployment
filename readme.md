# MinIO 集群部署

MinIO 分布式对象存储集群的快速部署方案。

## 快速开始

### 单机集群部署（推荐用于开发测试）

```bash
cd docker-deployment
docker-compose up -d
```

**访问地址：**
- 控制台：http://localhost:9001
- API：http://localhost:9000
- 用户名/密码：minioadmin/minioadmin

### 多机分布式部署

1. 修改 `docker-compose-distributed.yml` 中的IP地址
2. 在每台机器上运行：
```bash
docker-compose -f docker-compose-distributed.yml up -d
```

### Windows 本地部署

```bash
cd windows-deployment
start-minio1.bat
```

## 项目结构

```
├── docker-deployment/          # Docker容器化部署
│   ├── docker-compose.yml      # 单机多容器
│   └── docker-compose-distributed.yml  # 多机分布式
├── windows-deployment/         # Windows批处理脚本
├── linux-deployment/           # Linux服务配置
├── WARP/                      # 性能测试工具
└── mc.md                      # MinIO客户端命令参考
```

## 管理命令

### 集群状态检查
```bash
mc alias set mycluster http://localhost:9000 minioadmin minioadmin
mc admin info mycluster
```

### 创建存储桶
```bash
mc mb mycluster/mybucket
```

### 上传文件
```bash
mc cp file.txt mycluster/mybucket/
```

## 端口说明

| 服务 | API端口 | 控制台端口 |
|------|---------|------------|
| minio1 | 9000 | 9001 |
| minio2 | 9010 | 9011 |
| minio3 | 9020 | 9021 |
| minio4 | 9030 | 9031 |

## 注意事项

- 集群至少需要4个节点
- 确保防火墙开放相应端口
- 生产环境建议使用HTTPS
- 定期备份重要数据
