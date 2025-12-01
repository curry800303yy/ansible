# Auth Agent Role

这个role用于自动化部署Auth Agent服务。

## 功能特性

- 自动加载Docker镜像
- 自动检测网卡并获取MAC地址
- 创建必要的目录和权限设置
- 启动Auth Agent服务
- 验证部署状态

## 目录结构

```
roles/auth-agent/
├── defaults/main.yml          # 默认变量
├── tasks/main.yml            # 主要任务
├── templates/
│   └── docker-compose.yml.j2 # Docker Compose模板
├── files/
│   └── agent.tar             # Docker镜像文件
└── README.md                 # 说明文档
```

## 默认配置

```yaml
# Auth Agent 配置
auth_agent_install_dir: "/opt/auth-agent"
auth_agent_container_name: "agent"
auth_agent_image_name: "auth/agent:1.0.0"
auth_agent_image_file: "agent.tar"

# 端口配置
auth_agent_port_1: "10111"
auth_agent_port_2: "10211"

# 数据目录配置
auth_agent_data_dir: "/opt/data_lease"

# 网络配置
auth_agent_network_name: "open-network"

# 网卡名称 (需要根据实际环境配置)
auth_agent_network_interface: "eth0"

# 是否自动检测网卡
auth_agent_auto_detect_interface: true

# 是否加载镜像文件
auth_agent_load_image: true
```

## 使用方法

### 1. 在playbook中使用

```yaml
- hosts: web_server
  become: true
  roles:
    - auth-agent
```

### 2. 自定义配置

```yaml
- hosts: web_server
  become: true
  vars:
    auth_agent_network_interface: "ens33"  # 指定网卡名称
    auth_agent_auto_detect_interface: false # 禁用自动检测
    auth_agent_port_1: "20111"             # 自定义端口
  roles:
    - auth-agent
```

### 3. 独立运行

创建 `auth-agent.yml` playbook：

```yaml
---
- hosts: web_server
  become: true
  roles:
    - auth-agent
```

运行：
```bash
ansible-playbook -i inventory/hosts auth-agent.yml
```

## 部署流程

1. **创建目录**: 创建安装目录和数据目录
2. **复制文件**: 复制Docker镜像文件到目标服务器
3. **加载镜像**: 使用docker load加载镜像
4. **检测网卡**: 自动检测或使用指定的网卡名称
5. **获取MAC**: 获取宿主机MAC地址
6. **创建网络**: 创建Docker网络
7. **生成配置**: 根据模板生成docker-compose.yml
8. **启动服务**: 启动Auth Agent容器
9. **设置权限**: 设置数据目录权限
10. **验证状态**: 检查容器运行状态

## 网卡检测

Role支持两种方式获取网卡名称：

### 自动检测（默认）
```yaml
auth_agent_auto_detect_interface: true
```
会自动检测默认路由使用的网卡。

### 手动指定
```yaml
auth_agent_auto_detect_interface: false
auth_agent_network_interface: "ens33"
```

## 注意事项

1. **Docker环境**: 确保目标服务器已安装Docker和Docker Compose
2. **网络权限**: 确保容器可以访问指定的端口
3. **文件权限**: 数据目录会被设置为777权限
4. **镜像文件**: agent.tar文件较大(55MB)，传输可能需要时间
5. **MAC地址**: 服务依赖宿主机MAC地址，确保网卡配置正确

## 故障排除

### 1. 网卡检测失败
```bash
# 手动检查网卡
ip route | grep default
ifconfig
```

### 2. 端口冲突
检查端口是否被占用：
```bash
netstat -tlnp | grep 10111
netstat -tlnp | grep 10211
```

### 3. 容器启动失败
检查容器日志：
```bash
docker logs agent
```

### 4. 权限问题
确保数据目录权限正确：
```bash
ls -la /opt/data_lease
```

## 相关服务

Auth Agent通常与以下服务配合使用：
- CDN管理系统
- 认证服务
- 监控系统

建议在部署顺序中将Auth Agent放在基础服务之后，应用服务之前。 