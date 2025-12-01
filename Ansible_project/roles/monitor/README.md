# Monitor Role

此角色用于部署监控系统，包括Prometheus监控服务器和N9E(夜莺)监控系统。

## 功能特性

- 自动安装Prometheus v3.1.0监控服务器
- 自动安装N9E(夜莺) v7.7.2监控系统
- 自动配置MariaDB数据库和Redis缓存
- 提供基础认证配置
- 包含监控面板JSON配置文件

## 系统要求

- Ubuntu 22.04/24.04 LTS
- root权限
- 网络连接正常

## 安装的组件

### Prometheus
- 版本: v3.1.0
- 端口: 9090
- 默认用户名: admin
- 默认密码: prometheus098

### N9E夜莺
- 版本: v7.7.2
- 端口: 17000
- 默认用户名: root
- 默认密码: root.2020

### 依赖服务
- MariaDB (数据库)
- Redis (缓存)

## 使用方法

### 单独部署监控系统
```bash
ansible-playbook -i inventory/hosts site.yml --tags monitor
```

### 配置主机组
在 `inventory/hosts` 文件中配置 `monitor_server` 主机组：
```ini
[monitor_server]
192.168.1.102 ansible_user=root ansible_ssh_pass=your_password
```

## 配置变量

可在 `inventory/group_vars/all.yml` 中覆盖默认配置：

```yaml
# Monitor installation settings
monitor_auto_mode: true
monitor_temp_dir: /tmp/monitor-install

# Prometheus settings
prometheus_port: 9090
prometheus_user: admin
prometheus_password: prometheus098

# N9E (Nightingale) settings
n9e_port: 17000
n9e_user: root
n9e_password: root.2020

# Database settings
monitor_db_password: asfhieghsid232
```

## 部署后操作

1. **访问监控系统**：
   - Prometheus: http://服务器IP:9090
   - N9E夜莺: http://服务器IP:17000

2. **修改默认密码**：
   - 登录后立即修改默认密码

3. **配置监控面板**：
   - 在N9E中添加Prometheus数据源
   - 导入提供的JSON面板配置

4. **配置告警**：
   - 根据文档配置Telegram告警通知
   - 设置CPU、内存、磁盘使用率告警规则

## 监控面板

角色包含以下预配置的监控面板JSON文件：
- 节点大盘监控.json
- 四层指标.json
- 业务指标.json
- kafka.json
- mysql.json
- redis.json

## 安全注意事项

- 请立即修改默认密码
- 建议配置防火墙规则
- 定期备份配置文件和数据库
- 监控系统应部署在安全的网络环境中

## 故障排查

### 查看服务状态
```bash
systemctl status prometheus
systemctl status n9e
systemctl status mariadb
systemctl status redis-server
```

### 查看日志
```bash
journalctl -u prometheus -f
journalctl -u n9e -f
```

### 常见问题
1. **端口被占用**：检查9090和17000端口是否被其他服务占用
2. **数据库连接失败**：确认MariaDB服务正常运行，密码配置正确
3. **网络连接问题**：确保服务器可以访问GitHub下载安装包