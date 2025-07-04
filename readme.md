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

### 1. 服务器管理

- `mc alias set <ALIAS> <URL> <ACCESSKEY> <SECRETKEY> [--api S3v4|S3v2]`
- `mc alias list`
- `mc alias remove <ALIAS>`

### 2. Bucket 和对象操作

- `mc mb <ALIAS>/<BUCKET>`  
  创建 bucket

- `mc rb <ALIAS>/<BUCKET> [--force]`  
  删除 bucket

- `mc ls <ALIAS>/<BUCKET/PATH>`  
  列出对象和目录

- `mc cp [FLAGS] <SRC> <TARGET>`  
  拷贝对象或文件

- `mc mv [FLAGS] <SRC> <TARGET>`  
  移动对象或文件

- `mc rm [FLAGS] <ALIAS>/<BUCKET/PATH>`  
  删除对象

- `mc cat <ALIAS>/<BUCKET/OBJECT>`  
  查看对象内容

- `mc head <ALIAS>/<BUCKET/OBJECT>`  
  查看对象元数据

- `mc stat <ALIAS>/<BUCKET/OBJECT>`  
  查看对象详细信息

- `mc find <ALIAS>/<BUCKET/PATH> [FLAGS]`  
  查找对象

- `mc mirror [FLAGS] <SRC> <TARGET>`  
  镜像同步

- `mc diff <SRC> <TARGET>`  
  比较差异

### 3. 策略与权限

- `mc policy set <download|upload|public|none> <ALIAS>/<BUCKET>`
- `mc policy info <ALIAS>/<BUCKET>`
- `mc policy list <ALIAS>/<BUCKET>`

### 4. 用户和组管理（admin）

- `mc admin user add <ALIAS> <USERNAME> <PASSWORD>`
- `mc admin user disable <ALIAS> <USERNAME>`
- `mc admin user enable <ALIAS> <USERNAME>`
- `mc admin user remove <ALIAS> <USERNAME>`
- `mc admin user list <ALIAS>`
- `mc admin group add <ALIAS> <GROUPNAME> <USER1> ...`
- `mc admin group disable <ALIAS> <GROUPNAME>`
- `mc admin group enable <ALIAS> <GROUPNAME>`
- `mc admin group remove <ALIAS> <GROUPNAME>`
- `mc admin group list <ALIAS>`

### 5. 服务管理（admin）

- `mc admin info <ALIAS>`
- `mc admin service restart <ALIAS>`
- `mc admin service stop <ALIAS>`
- `mc admin heal <ALIAS>`
- `mc admin prometheus generate <ALIAS>`
- `mc admin trace <ALIAS>`

### 6. 监控与日志

- `mc admin top locks <ALIAS>`
- `mc admin top ops <ALIAS>`
- `mc admin top bandwidth <ALIAS>`
- `mc admin trace <ALIAS>`

### 7. 其他实用命令

- `mc config host add <ALIAS> <URL> <ACCESSKEY> <SECRETKEY>`
- `mc encrypt set|clear|info`
- `mc retention set|get|clear`
- `mc legalhold set|get|clear`
- `mc share download|upload|list|revoke`
- `mc version enable|suspend|info`
- `mc tag set|get|remove`
- `mc ilm add|edit|export|import|list|remove`
- `mc quota set|get|clear`
- `mc support diag|callhome|profile`
- `mc update`
- `mc help [COMMAND]`

---

## 查看所有命令和帮助

```bash
mc --help
mc <command> --help
```
