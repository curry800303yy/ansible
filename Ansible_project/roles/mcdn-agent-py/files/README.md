# MCDN Agent - Python Implementation

仅保留配置文件说明与服务工作原理，便于对接与运维。

## 配置文件说明（config.json）

使用标准 JSON 配置服务行为。字段含义如下：

```json
{
  "server": {
    "host": "0.0.0.0", // 服务 host
    "port": 8090 // 服务端口
  },
  "app": {
    "admin_api_url": "http://markcdn-admin-api:8080", // 管理后台 api 容器地址
    "console_api_url": "http://markcdn-console-api:8081" // 用户后台 api 容器地址
  },
  "log": {
    "level": "INFO",
    "file": "log/mcdn-agent.log" // 日志保存地址
  },
  "nginx": {
    "path": "/opt/nginx", // nginx 目录
    "config_path": "/opt/nginx/conf", // nginx 配置目录
    "cert_path": "/opt/nginx/cert", // nginx 证书目录
    "container_name": "nginx" // nginx 容器名
  }
}
```

说明：
- 配置文件用于控制监听地址/端口、日志级别、Nginx 输出目录，以及上游 API 地址。
- 证书与私钥会按域名分别写入 `cert_path` 下的 `{domain}.crt` 与 `{domain}.key`。
- 渲染出的 Nginx 站点配置会写入 `config_path` 下的 `{domain}.conf`。

## 服务工作原理

1. 启动 HTTP 服务，提供以下端点：
   - `GET /health`：健康检查
   - `GET /version`：版本信息
   - `POST /api/v1/update-config`：接收域名配置（支持 admin/console/api 的任意子集）

2. 接收配置后执行：
   - 校验提交的数据：
     - 每个条目包含 `protocol`（http/https）、`domain`；若为 `https`，需提供合法 PEM 格式的 `cert` 与 `key`。
     - 支持仅提交部分条目（例如只提交 `admin`）。
   - 写入证书与私钥到 `cert_path`。
   - 使用内置模板渲染 Nginx 站点配置到 `config_path`。
   - 通过 Docker Compose 重启 Nginx：优先使用 `docker compose`，无法使用时自动回退 `docker-compose`。

3. 日志与可观测性：
   - 日志输出到标准输出（由 systemd/journalctl 收集）。
   - 通过 `log.level` 控制日志冗余度。
