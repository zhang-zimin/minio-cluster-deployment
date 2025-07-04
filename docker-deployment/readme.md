## MinIO 集群 Docker 部署指南

### 部署方式选择

#### 1. 单机多容器部署（当前的 docker-compose.yml）
**适用场景：** 开发测试、资源有限的环境
- 在单台机器上运行4个MinIO容器
- 容器间通过Docker网络通信
- 使用不同端口区分服务

**部署步骤：**
```bash
cd c:\dev\minio-cluster\docker-deployment
docker-compose up -d
```

#### 2. 多机分布式部署（docker-compose-distributed.yml）
**适用场景：** 生产环境、真正的高可用集群
- 每台物理机运行一个MinIO实例
- 需要4台独立的服务器
- 通过IP地址互相通信

**部署步骤：**
1. 在每台机器上修改hostname和IP地址
2. 确保网络互通（防火墙开放9000端口）
3. 在每台机器上运行：
```bash
docker-compose -f docker-compose-distributed.yml up -d
```

### 使用 Docker Compose

1. **启动集群**
   ```bash
   docker-compose up -d
   ```

2. **查看集群状态**
   ```bash
   docker-compose ps
   ```

3. **停止集群**
   ```bash
   docker-compose down
   ```

4. **查看日志**
   ```bash
   docker-compose logs -f minio1
   ```


### 注意事项
1. 确保所有节点的 `MINIO_ROOT_USER` 和 `MINIO_ROOT_PASSWORD` 相同
2. 集群至少需要4个节点才能实现高可用
3. 每个节点需要至少2个驱动器路径才能启用纠删码


## minio 国内镜像源
- https://docker.aityp.com/r/docker.io/minio/minio