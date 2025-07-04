# MinIO 集群部署

MinIO 分布式对象存储集群的部署方案。

## 部署方式

### 1. Docker部署

**单机集群**：
```bash
cd docker-deployment
docker-compose up -d
```

**多机分布式**：
1. 修改 `docker-compose-distributed.yml` 中的IP地址
2. 在每台机器上运行：
```bash
docker-compose -f docker-compose-distributed.yml up -d
```

### 2. Linux原生部署

1. 查看详细指南：`linux-deployment/README.md`
2. 配置服务器IP地址
3. 在每台服务器上运行：
```bash
sudo systemctl start minio
sudo systemctl enable minio
```

### 3. Windows本地部署

```bash
cd windows-deployment
start-minio1.bat
```

## 项目结构

```
├── docker-deployment/          # Docker容器化部署
│   ├── docker-compose.yml      # 单机多容器
│   └── docker-compose-distributed.yml  # 多机分布式
├── linux-deployment/           # Linux原生部署
│   ├── README.md               # 详细部署指南
│   └── etc/                    # 配置文件模板
├── windows-deployment/         # Windows批处理脚本
├── WARP/                      # 性能测试工具
└── mc.md                      # MinIO客户端命令参考
```


## 注意事项

- **集群要求**：至少需要4个节点才能实现高可用
- **网络配置**：确保防火墙开放相应端口（9000, 9001等）
- **数据备份**：定期备份重要数据
- **时间同步**：Linux部署时确保所有节点时间同步

