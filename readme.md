# MinIO 命令行工具 mc 全部详细命令

MinIO Client（mc）是官方提供的对象存储命令行管理工具，功能丰富，兼容 S3 API。

---

## 基本用法

```bash
mc [GLOBALFLAGS] COMMAND [COMMANDFLAGS | ARGUMENTS...]
```

---

## 常用命令一览

- `mc alias`         管理服务器别名
- `mc mb`            创建 bucket
- `mc rb`            删除 bucket
- `mc ls`            列出对象和目录
- `mc cp`            拷贝文件/对象
- `mc mv`            移动文件/对象
- `mc rm`            删除文件/对象
- `mc cat`           查看对象内容
- `mc find`          查找对象
- `mc mirror`        镜像同步
- `mc diff`          比较 bucket 或目录差异
- `mc policy`        管理 bucket 策略
- `mc admin`         管理 MinIO 服务（集群、用户、监控等）

---

## 全部详细命令

### 1. 集群管理

- `mc alias set cluster1 http://127.0.0.1:9000 minioadmin minioadmin` 集群命名
- `mc alias list`
- `mc alias remove <ALIAS>`




