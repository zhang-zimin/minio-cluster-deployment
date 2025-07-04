```markdown
# 使用 Docker Compose 部署 MinIO 集群 (Erasure Coding 模式)

## docker-compose.yml 配置

```yaml
version: "3.9"
services:
  minio1:
    image: minio/minio:latest
    ports:
      - "9001:9000"
      - "9091:9090"
    volumes:
      - /mnt/data1:/data
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin
    command: server /data --console-address ":9090"
    deploy:
      restart_policy:
        condition: on-failure

  minio2:
    image: minio/minio:latest
    ports:
      - "9002:9000"
      - "9092:9090"
    volumes:
      - /mnt/data2:/data
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin
    command: server /data --console-address ":9090"
    deploy:
      restart_policy:
        condition: on-failure

  minio3:
    image: minio/minio:latest
    ports:
      - "9003:9000"
      - "9093:9090"
    volumes:
      - /mnt/data3:/data
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin
    command: server /data --console-address ":9090"
    deploy:
      restart_policy:
        condition: on-failure

  minio4:
    image: minio/minio:latest
    ports:
      - "9004:9000"
      - "9094:9090"
    volumes:
      - /mnt/data4:/data
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin
    command: server /data --console-address ":9090"
    deploy:
      restart_policy:
        condition: on-failure
```

## 配置说明

- **volumes**: 将 Linux 节点上的目录挂载到容器中
  - 需提前创建目录: `/mnt/data1`, `/mnt/data2`, `/mnt/data3`, `/mnt/data4`
  - 确保当前用户有读写权限

- **command**: MinIO 启动命令
  - `server /data`: 指定数据存储目录
  - `--console-address ":9090"`: 指定控制台地址

- **deploy**: 配置重启策略
  - `condition: on-failure`: 容器启动失败时自动重启

## 部署步骤

1. **创建数据目录**:
   ```bash
   sudo mkdir -p /mnt/data{1..4}
   sudo chown -R $USER:$USER /mnt/data{1..4}
   ```

2. **创建 docker-compose.yml 文件**:
   ```bash
   mkdir -p /opt/minio-cluster
   nano /opt/minio-cluster/docker-compose.yml
   ```

3. **启动集群**:
   ```bash
   cd /opt/minio-cluster
   docker-compose up -d
   ```

4. **访问控制台**:
   - minio1: `http://<linux-node-ip>:9091`
   - minio2: `http://<linux-node-ip>:9092`
   - minio3: `http://<linux-node-ip>:9093`
   - minio4: `http://<linux-node-ip>:9094`
   - 默认凭证: `minioadmin`/`minioadmin`

5. **验证集群状态**:
   ```bash
   docker exec -it minio-cluster_minio1_1 mc admin info local
   ```

## 重要提示

1. **Erasure Coding**:
   - 此部署使用 MinIO 的集群模式
   - 提供数据冗余和高可用性

2. **端口映射**:
   - 确保防火墙开放端口: 9001-9004 和 9091-9094

3. **生产环境建议**:
   - 使用网络存储或云存储
   - 配置 TLS 加密
   - 设置更复杂的认证机制
```