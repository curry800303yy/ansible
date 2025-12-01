# MCDN Agent Python Service - 部署指南

## 一键部署

```bash
cd mcdn-agent-py
sh install.sh
```

## 配置修改

```bash
# 编辑配置（在服务目录中）
vi config.json

# 重启服务
systemctl restart mcdn-agent-py

# 或
sh install.sh
```

## 服务管理

```bash
# 查看状态
systemctl status mcdn-agent-py

# 查看日志
journalctl -u mcdn-agent-py -f
```

### 健康检查
```bash
# 基本健康检查
curl http://localhost:8090/health

# 版本信息
curl http://localhost:8090/version
```
