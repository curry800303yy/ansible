# Docker Role

此 Ansible role 用于在 Ubuntu 24.04 系统上自动化安装和配置 Docker 和 Docker Compose。

## 功能

- 安装 Docker CE 最新稳定版本
- 安装 Docker Compose
- 配置 Docker 服务自启动
- 将指定用户添加到 docker 用户组
- 创建自定义 Docker 网络
- 验证安装结果

## 要求

- Ubuntu 24.04 LTS 系统
- 具有 sudo 权限的用户
- 网络连接正常（用于下载软件包）

## 使用方法

### 在 playbook 中使用

```yaml
- hosts: docker_servers
  become: yes
  roles:
    - docker
```

### 自定义变量

你可以在 playbook 或 inventory 中覆盖默认变量：

```yaml
- hosts: docker_servers
  become: yes
  vars:
    docker_network_name: "my-custom-network"
    docker_version: "5:24.0.9-1~ubuntu.24.04~noble"
    docker_compose_version: "v2.24.0"
  roles:
    - docker
```

## 变量

### 默认变量 (roles/docker/defaults/main.yml)

| 变量名 | 默认值 | 描述 |
|--------|--------|------|
| `docker_network_name` | "open-network" | 要创建的 Docker 网络名称 |
| `docker_version` | "5:24.0.9-1~ubuntu.24.04~noble" | Docker CE 版本 |
| `docker_compose_version` | "v2.24.0" | Docker Compose 版本 |

## 文件结构

```
roles/docker/
├── README.md              # 说明文档
├── defaults/
│   └── main.yml          # 默认变量
├── handlers/
│   └── main.yml          # 事件处理器
└── tasks/
    └── main.yml          # 主要任务
```

## 安装过程

此 role 会执行以下步骤：

1. **系统准备**
   - 更新 apt 包缓存
   - 安装必要的依赖包

2. **Docker 仓库配置**
   - 添加 Docker 官方 GPG 密钥
   - 添加 Docker 官方仓库

3. **Docker 安装**
   - 安装指定版本的 Docker CE
   - 启动并启用 Docker 服务

4. **用户配置**
   - 将当前用户添加到 docker 用户组

5. **Docker Compose 安装**
   - 下载并安装 Docker Compose
   - 创建符号链接

6. **网络和验证**
   - 创建自定义 Docker 网络
   - 验证安装结果

## 注意事项

1. **系统兼容性**：此 role 专为 Ubuntu 24.04 设计
2. **用户权限**：安装后需要重新登录以应用 docker 用户组权限
3. **防火墙**：确保必要的端口已开放
4. **版本锁定**：建议在生产环境中锁定特定版本

## 使用示例

### 基本安装

```yaml
---
- name: 安装 Docker
  hosts: ubuntu_servers
  become: yes
  roles:
    - docker
```

### 自定义配置

```yaml
---
- name: 安装 Docker 自定义配置
  hosts: ubuntu_servers
  become: yes
  vars:
    docker_network_name: "production-network"
    docker_version: "5:24.0.9-1~ubuntu.24.04~noble"
  roles:
    - docker
```

## 验证安装

安装完成后，可以通过以下命令验证：

```bash
# 检查 Docker 版本
docker --version

# 检查 Docker Compose 版本
docker-compose --version

# 检查 Docker 服务状态
systemctl status docker

# 检查 Docker 网络
docker network ls

# 测试 Docker 运行
docker run hello-world
```

## 故障排除

### 检查服务状态

```bash
systemctl status docker
```

### 查看日志

```bash
journalctl -u docker -f
```

### 检查用户组

```bash
groups $USER
```

### 重启 Docker 服务

```bash
sudo systemctl restart docker
```

## 更新历史

- **v2.0**: 从 CentOS 迁移到 Ubuntu 24.04
- **v1.0**: 支持 CentOS 系统

## 依赖

- Ubuntu 24.04 LTS
- apt 包管理器
- 网络连接 