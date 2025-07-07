# MinIO 集群日志配置详细说明

## 概述

本文档详细介绍了MinIO集群的日志配置、管理和监控方案，包括日志级别、轮转策略、收集分析等最佳实践。

## 日志类型

### 1. 应用日志 (Application Logs)
- **位置**: `/var/log/minio/app/minio.log`
- **内容**: MinIO服务运行时的所有信息
- **格式**: JSON格式（推荐）或文本格式
- **级别**: OFF, FATAL, ERROR, WARN, INFO, DEBUG, TRACE

### 2. 审计日志 (Audit Logs)
- **位置**: `/var/log/minio/audit/audit.log`
- **内容**: 所有API调用的详细记录
- **格式**: JSON格式
- **包含**: 用户身份、操作时间、请求详情、响应状态

### 3. 容器日志 (Docker Logs)
- **位置**: Docker容器标准输出
- **内容**: 容器启动信息和错误
- **查看**: `docker-compose logs`

## 日志级别说明

| 级别 | 说明 | 使用场景 |
|------|------|----------|
| OFF | 关闭日志 | 不推荐 |
| FATAL | 致命错误 | 服务无法启动 |
| ERROR | 错误信息 | 操作失败、异常 |
| WARN | 警告信息 | 性能问题、配置问题 |
| INFO | 一般信息 | 生产环境推荐 |
| DEBUG | 调试信息 | 开发测试环境 |
| TRACE | 跟踪信息 | 详细调试 |

## 配置方式

### 1. 环境变量配置

```yaml
environment:
  # 日志级别
  MINIO_LOG_LEVEL: INFO
  
  # 日志格式
  MINIO_LOG_FORMAT: json
  
  # 日志文件路径
  MINIO_LOG_FILE: /var/log/minio/app/minio.log
  
  # 审计日志
  MINIO_AUDIT_WEBHOOK_ENABLE: "on"
  MINIO_AUDIT_LOGGER_HTTP_ENABLE: "on"
  MINIO_AUDIT_LOGGER_HTTP_ENDPOINT: "file:///var/log/minio/audit/audit.log"
  
  # 控制台日志
  MINIO_CONSOLE_LOG_LEVEL: INFO
  MINIO_CONSOLE_LOG_FORMAT: json
```

### 2. 卷挂载配置

```yaml
volumes:
  # 日志目录挂载
  - /var/log/minio:/var/log/minio
  - /var/log/minio/audit:/var/log/minio/audit
  - /var/log/minio/app:/var/log/minio/app
```

### 3. Docker日志配置

```yaml
logging:
  driver: "json-file"
  options:
    max-size: "100m"      # 单个日志文件最大大小
    max-file: "10"        # 保留的日志文件数量
    compress: "true"      # 压缩历史日志文件
```

## 日志轮转策略

### 1. 应用日志轮转
- **频率**: 每天轮转
- **保留期**: 30天
- **压缩**: 是
- **权限**: 644

### 2. 审计日志轮转
- **频率**: 每天轮转
- **保留期**: 90天（合规要求）
- **压缩**: 是
- **权限**: 600（更严格）

### 3. 配置文件

```bash
# 复制到 /etc/logrotate.d/minio
/var/log/minio/app/*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 0644 root root
    postrotate
        docker-compose -f /path/to/docker-compose.yml exec minio pkill -HUP minio || true
    endscript
}
```

## 日志管理工具

### 1. 基本管理脚本

提供了Linux和Windows两个版本的日志管理脚本：

- **Linux版本**: `manage-logs.sh`
- **Windows版本**: `manage-logs.ps1`

### 2. 主要功能

- **检查目录**: 创建和检查日志目录
- **查看日志**: 实时查看不同类型的日志
- **分析统计**: 日志级别统计和错误分析
- **清理日志**: 清理指定天数前的日志文件
- **导出日志**: 导出指定日期范围的日志
- **监控异常**: 实时监控日志异常和磁盘空间

### 3. 使用示例

```bash
# Linux
./manage-logs.sh check                    # 检查目录
./manage-logs.sh view app                 # 查看应用日志
./manage-logs.sh analyze                  # 分析日志统计
./manage-logs.sh cleanup 30               # 清理30天前的日志
./manage-logs.sh export 2024-01-01 2024-01-31  # 导出日志
./manage-logs.sh monitor 30               # 监控异常

# Windows
.\manage-logs.ps1 -Command check
.\manage-logs.ps1 -Command view -Parameter1 app
.\manage-logs.ps1 -Command analyze
.\manage-logs.ps1 -Command cleanup -Parameter1 30
.\manage-logs.ps1 -Command export -Parameter1 2024-01-01 -Parameter2 2024-01-31
.\manage-logs.ps1 -Command monitor -Parameter1 30
```

## 日志监控和告警

### 1. 关键指标监控

- **错误率**: ERROR级别日志的频率
- **响应时间**: API调用响应时间
- **磁盘空间**: 日志目录磁盘使用率
- **日志文件大小**: 单个日志文件大小

### 2. 告警规则

```bash
# 磁盘空间告警（使用率超过80%）
if [ "$disk_usage" -gt 80 ]; then
    send_alert "日志目录磁盘使用率过高: ${disk_usage}%"
fi

# 错误日志告警（错误数量超过阈值）
if [ "$error_count" -gt 10 ]; then
    send_alert "发现 $error_count 个错误日志条目"
fi

# 日志文件大小告警（超过100MB）
if [ "$log_size" -gt 100 ]; then
    send_alert "日志文件过大: ${log_size}MB"
fi
```

### 3. 集成监控系统

#### Prometheus + Grafana

```yaml
# prometheus.yml
scrape_configs:
  - job_name: 'minio'
    static_configs:
      - targets: ['localhost:9000']
    metrics_path: /minio/v2/metrics/cluster
    scrape_interval: 15s
```

#### ELK Stack

```yaml
# filebeat.yml
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/minio/app/*.log
  fields:
    service: minio
    log_type: application
  
- type: log
  enabled: true
  paths:
    - /var/log/minio/audit/*.log
  fields:
    service: minio
    log_type: audit
```

## 日志分析和故障排查

### 1. 常见问题排查

#### 启动失败
```bash
# 查看ERROR级别日志
grep "ERROR" /var/log/minio/app/minio.log | tail -10

# 查看Docker容器日志
docker-compose logs minio | grep -i error
```

#### 性能问题
```bash
# 查看WARN级别日志
grep "WARN" /var/log/minio/app/minio.log | tail -10

# 分析响应时间
grep "response_time" /var/log/minio/app/minio.log | tail -20
```

#### 网络问题
```bash
# 查看网络相关错误
grep -i "network\|connection\|timeout" /var/log/minio/app/minio.log
```

### 2. 日志分析工具

#### jq分析JSON日志
```bash
# 统计日志级别
cat /var/log/minio/app/minio.log | jq -r '.level' | sort | uniq -c

# 查看错误详情
cat /var/log/minio/app/minio.log | jq 'select(.level=="ERROR")'

# 分析API调用
cat /var/log/minio/audit/audit.log | jq -r '.api.name' | sort | uniq -c
```

#### awk分析
```bash
# 统计每小时的日志数量
awk '{print $1" "$2}' /var/log/minio/app/minio.log | cut -d: -f1 | sort | uniq -c

# 查找响应时间超过1秒的请求
awk '/response_time/ && $NF > 1000 {print}' /var/log/minio/app/minio.log
```

## 最佳实践

### 1. 生产环境配置

- **日志级别**: INFO（平衡性能和信息量）
- **轮转策略**: 每天轮转，保留30天
- **审计日志**: 必须启用，保留90天
- **监控告警**: 实时监控错误率和磁盘空间

### 2. 安全建议

- **权限控制**: 严格控制日志文件访问权限
- **加密传输**: 使用TLS传输日志到远程系统
- **审计保护**: 防止审计日志被篡改
- **敏感信息**: 避免在日志中记录密码等敏感信息

### 3. 性能优化

- **异步日志**: 使用异步写入减少性能影响
- **分离存储**: 将日志存储在独立的磁盘上
- **压缩归档**: 及时压缩和归档历史日志
- **定期清理**: 自动清理过期日志文件

### 4. 合规要求

- **数据保留**: 根据合规要求设置日志保留期
- **访问控制**: 记录日志访问行为
- **完整性检查**: 定期检查日志文件完整性
- **备份恢复**: 定期备份重要日志文件

## 故障处理流程

### 1. 日志收集
```bash
# 收集当前日志
./manage-logs.sh export $(date -d "7 days ago" +%Y-%m-%d) $(date +%Y-%m-%d)

# 收集系统信息
docker-compose ps > system_status.txt
df -h >> system_status.txt
free -h >> system_status.txt
```

### 2. 问题分析
```bash
# 分析错误模式
./manage-logs.sh analyze

# 检查网络连接
telnet other-nodes 9000

# 检查磁盘空间
df -h /data*
```

### 3. 解决方案
```bash
# 重启服务
docker-compose restart minio

# 清理空间
./manage-logs.sh cleanup 7

# 检查配置
docker-compose config
```

