# Web-MySQL Ansible Role

这个Ansible role用于部署和配置MySQL数据库服务，专门为CDN管理系统设计，包含自动化的数据库初始化流程。

## 功能特性

- 自动部署MySQL 5.7容器
- 自动创建mastercdn数据库
- 按顺序执行SQL初始化脚本
- 自动导入IP地理位置数据
- 提供完整的数据库验证和状态检查
- 支持自定义配置参数

## 默认配置

- **安装目录**: `/opt/web-mysql`
- **MySQL版本**: `mysql:5.7`
- **数据库名**: `mastercdn`
- **root密码**: `654321`
- **端口**: `3306`
- **字符集**: `utf8mb4`

## 初始化流程

role会按以下顺序自动执行数据库初始化：

1. **创建数据库**: `CREATE DATABASE mastercdn`
2. **执行表结构**: `tables.sql`
3. **执行初始数据**: `init.sql`
4. **导入IP数据**: `ip2region_regions.txt`

## 使用方法

### 1. 独立部署

```bash
ansible-playbook -i inventory/hosts test-web-mysql.yml
```

### 2. 作为role使用

```yaml
- hosts: mysql_servers
  roles:
    - web-mysql
  vars:
    mysql_root_password: "your_secure_password"
    mysql_database_name: "your_database"
```

## 可配置变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `mysql_install_dir` | `/opt/web-mysql` | 安装目录 |
| `mysql_root_password` | `654321` | root用户密码 |
| `mysql_database_name` | `mastercdn` | 数据库名称 |
| `mysql_container_name` | `mysql` | 容器名称 |
| `mysql_image` | `mysql:5.7` | MySQL镜像版本 |
| `mysql_port` | `3306` | 数据库端口 |
| `mysql_charset` | `utf8mb4` | 字符集 |
| `mysql_collation` | `utf8mb4_unicode_ci` | 排序规则 |
| `mysql_init_database` | `true` | 是否执行初始化 |
| `docker_network_name` | `open-network` | Docker网络名称 |

## 文件结构

role需要以下文件放置在`files/`目录中：

```
roles/web-mysql/files/
├── tables.sql              # 数据库表结构
├── init.sql                # 初始化数据
└── ip2region_regions.txt   # IP地理位置数据
```

## 部署后验证

role会自动执行以下验证：

1. **容器状态检查**: 确认MySQL容器正常运行
2. **数据库连接测试**: 验证数据库可正常连接
3. **表结构验证**: 显示创建的数据库表
4. **数据导入验证**: 检查IP数据表记录数

## 访问信息

部署完成后，可以通过以下方式访问：

- **数据库地址**: `服务器IP:3306`
- **数据库名**: `mastercdn`
- **用户名**: `root`
- **密码**: `654321` (或自定义)

## 连接示例

```bash
# 命令行连接
mysql -h 服务器IP -P 3306 -u root -p mastercdn

# 应用程序连接字符串
mysql://root:654321@服务器IP:3306/mastercdn?charset=utf8mb4
```

## 目录结构

```
/opt/web-mysql/
├── data/                    # MySQL数据目录
├── initdb/                  # 初始化脚本目录
│   ├── tables.sql
│   └── init.sql
├── mysql-files/             # 数据文件目录
│   └── ip2region_regions.txt
└── docker-compose.yml       # Docker Compose配置
```

## 注意事项

1. 确保目标服务器已安装Docker和Docker Compose
2. 确保防火墙已开放3306端口
3. 建议在生产环境中修改默认密码
4. IP数据文件较大(32MB)，首次部署可能需要较长时间
5. 确保Docker网络`open-network`已存在

## 故障排除

### 常见问题

1. **容器启动失败**
   ```bash
   docker logs mysql
   ```

2. **数据导入失败**
   ```bash
   docker exec -it mysql mysql -uroot -p -e "SHOW VARIABLES LIKE 'secure_file_priv';"
   ```

3. **权限问题**
   ```bash
   docker exec -it mysql ls -la /var/lib/mysql-files/
   ```

### 手动验证

```bash
# 检查容器状态
docker ps | grep mysql

# 检查数据库
docker exec -it mysql mysql -uroot -p -e "SHOW DATABASES;"

# 检查表
docker exec -it mysql mysql -uroot -p mastercdn -e "SHOW TABLES;"

# 检查数据
docker exec -it mysql mysql -uroot -p mastercdn -e "SELECT COUNT(*) FROM ip2region_regions;"
``` 