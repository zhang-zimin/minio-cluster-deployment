#!/bin/bash
# MinIO 日志检查和分析脚本

set -e

echo "========== MinIO 日志检查脚本 =========="
echo "时间: $(date)"
echo ""

# 检查日志目录
echo "检查日志目录结构..."
if [ -d "/var/log/minio" ]; then
    echo "日志目录结构:"
    find /var/log/minio -type f -exec ls -la {} \;
    echo ""
    echo "目录权限:"
    ls -la /var/log/minio/
    echo ""
else
    echo "✗ 日志目录不存在"
    exit 1
fi

# 检查应用日志
echo "检查应用日志..."
if [ -f "/var/log/minio/app/minio.log" ]; then
    echo "✓ 应用日志文件存在"
    echo "文件大小: $(du -h /var/log/minio/app/minio.log | cut -f1)"
    echo "文件权限: $(ls -la /var/log/minio/app/minio.log)"
    echo ""
    echo "最新的应用日志 (最后10行):"
    tail -10 /var/log/minio/app/minio.log
    echo ""
else
    echo "✗ 应用日志文件不存在"
fi

# 检查审计日志
echo "检查审计日志..."
if [ -f "/var/log/minio/audit/audit.log" ]; then
    echo "✓ 审计日志文件存在"
    echo "文件大小: $(du -h /var/log/minio/audit/audit.log | cut -f1)"
    echo "文件权限: $(ls -la /var/log/minio/audit/audit.log)"
    echo ""
    echo "最新的审计日志 (最后10行):"
    tail -10 /var/log/minio/audit/audit.log
    echo ""
else
    echo "✗ 审计日志文件不存在"
fi

# 检查容器日志
echo "检查容器日志..."
if docker-compose ps | grep -q minio; then
    echo "✓ MinIO容器正在运行"
    echo ""
    echo "容器日志 (最后20行):"
    docker-compose logs --tail=20 minio
    echo ""
else
    echo "✗ MinIO容器未运行"
fi

# 分析日志内容
echo "分析日志内容..."
if [ -f "/var/log/minio/app/minio.log" ]; then
    echo "应用日志统计:"
    echo "- 总行数: $(wc -l < /var/log/minio/app/minio.log)"
    echo "- ERROR级别: $(grep -c 'ERROR' /var/log/minio/app/minio.log 2>/dev/null || echo 0)"
    echo "- WARN级别: $(grep -c 'WARN' /var/log/minio/app/minio.log 2>/dev/null || echo 0)"
    echo "- INFO级别: $(grep -c 'INFO' /var/log/minio/app/minio.log 2>/dev/null || echo 0)"
    echo ""
fi

if [ -f "/var/log/minio/audit/audit.log" ]; then
    echo "审计日志统计:"
    echo "- 总行数: $(wc -l < /var/log/minio/audit/audit.log)"
    echo "- API调用: $(grep -c 'api' /var/log/minio/audit/audit.log 2>/dev/null || echo 0)"
    echo ""
fi

# 检查日志轮转
echo "检查日志轮转..."
if ls /var/log/minio/app/minio.log.* 2>/dev/null; then
    echo "✓ 发现已轮转的日志文件:"
    ls -la /var/log/minio/app/minio.log.*
else
    echo "- 没有已轮转的日志文件"
fi

# 磁盘空间检查
echo ""
echo "磁盘空间检查..."
echo "日志目录空间使用:"
du -sh /var/log/minio/*
echo ""
echo "可用空间:"
df -h /var/log/minio

echo ""
echo "========== 日志检查完成 =========="
