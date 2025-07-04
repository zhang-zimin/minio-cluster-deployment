# MinIO 命令行工具 mc 全部详细命令

MinIO Client（mc）是官方提供的对象存储命令行管理工具，功能丰富，兼容 S3 API。

---

## 基本用法

### 1. 集群管理

- `mc alias set cluster1 http://127.0.0.1:9000 minioadmin minioadmin` 
- 集群命名
- 
- `mc alias list`
- 
- `mc alias remove <ALIAS>`

- `mc admin info <ALIAS>`  
  查看集群的基本信息（节点状态、版本、健康状况等）


---

