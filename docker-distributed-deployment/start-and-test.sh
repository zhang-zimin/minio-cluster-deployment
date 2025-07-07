#!/bin/bash
# MinIO 分布式集群启动和测试脚本

set -e

echo "========== MinIO 集群启动和测试脚本 =========="
echo "时间: $(date)"
echo ""

# 检查Docker和Docker Compose
echo "检查Docker环境..."
docker --version || { echo "ERROR: Docker未安装或未启动"; exit 1; }
docker-compose --version || { echo "ERROR: Docker Compose未安装"; exit 1; }

# 检查网络连通性
echo ""
echo "检查网络连通性..."
NODES=("172.24.168.85" "172.24.170.19")
for node in "${NODES[@]}"; do
    if ping -c 2 "$node" > /dev/null 2>&1; then
        echo "✓ $node 网络连通"
    else
        echo "✗ $node 网络不通"
    fi
done

# 创建必要的目录
echo ""
echo "创建数据和日志目录..."
sudo mkdir -p /data1 /data2
sudo mkdir -p /var/log/minio/app /var/log/minio/audit
sudo chmod 755 /var/log/minio /var/log/minio/app /var/log/minio/audit

# 设置目录权限
echo "设置目录权限..."
sudo chown -R 1000:1000 /data1 /data2 /var/log/minio

# 停止现有容器
echo ""
echo "停止现有的MinIO容器..."
docker-compose down 2>/dev/null || echo "没有运行的容器"

# 启动MinIO集群
echo ""
echo "启动MinIO集群..."
docker-compose up -d

# 等待服务启动
echo ""
echo "等待MinIO服务启动..."
sleep 10

# 检查容器状态
echo ""
echo "检查容器状态..."
docker-compose ps

# 检查日志
echo ""
echo "检查容器日志..."
docker-compose logs --tail=20 minio

# 检查日志文件
echo ""
echo "检查日志文件..."
if [ -f "/var/log/minio/app/minio.log" ]; then
    echo "✓ 应用日志文件存在"
    echo "最新的应用日志:"
    tail -5 /var/log/minio/app/minio.log
else
    echo "✗ 应用日志文件不存在"
fi

if [ -f "/var/log/minio/audit/audit.log" ]; then
    echo "✓ 审计日志文件存在"
    echo "最新的审计日志:"
    tail -5 /var/log/minio/audit/audit.log
else
    echo "✗ 审计日志文件不存在"
fi

# 检查MinIO服务状态
echo ""
echo "检查MinIO服务状态..."
if curl -s http://localhost:9000/minio/health/live > /dev/null; then
    echo "✓ MinIO API服务正常"
else
    echo "✗ MinIO API服务异常"
fi

if curl -s http://localhost:9001 > /dev/null; then
    echo "✓ MinIO Console服务正常"
else
    echo "✗ MinIO Console服务异常"
fi

echo ""
echo "========== 启动测试完成 =========="
echo "MinIO Console: http://localhost:9001"
echo "MinIO API: http://localhost:9000"
echo "用户名: minioadmin"
echo "密码: minioadmin"
echo ""
echo "查看实时日志: docker-compose logs -f minio"
echo "查看应用日志: tail -f /var/log/minio/app/minio.log"
echo "查看审计日志: tail -f /var/log/minio/audit/audit.log"
