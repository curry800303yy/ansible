# Ansible 部署文档

⚠️  注意如下

> 目前已全量支持支持ansible安装，提前配置好对应域名的dns解析再去安装（会去自动申请SSL证书），以及配置好hosts和all.yml即可开始安装.
>
> 
>
> DNS解析使用A记录，如果使用Cloudflare请不要开启代理模式：
>
> 请准备好如下对应您的三个域名以及解析 (用于管理后台、API通讯，用户后台)：
>
> admin.domain.com ，api.domain.com ， console.domain.com



## 部署步骤

### 1. 环境配置

1. **更新系统并安装 Ansible**：

   - 在所有服务器上执行以下命令，安装必要工具：

     ```bash
     sudo apt update
     sudo apt install -y ansible lrzsz unzip sshpass
     ```

2. **上传 Ansible 项目包**`（可以选择其他的文件上传工具）`：

   - 安装上传工具：

     ```bash
     sudo apt install -y lrzsz
     ```

   - 上传压缩包（文件较大，需耐心等待）：

     ```bash
     rz
     ```

     将 Ansible_project 目录压缩为 Ansible_project.zip 包，选择 `Ansible_project.zip` 上传。

3. **解压项目包**：

   - 解压上传的压缩包：

     ```bash
     unzip Ansible_project.zip
     ```

### 2. 编辑配置文件

1. **进入项目目录**：

   ```bash
   cd Ansible_project
   ```

2. **编辑 hosts 文件**：

   - 修改服务器 IP 和登录信息：

     ```bash
     vim inventory/hosts
     ```

     配置格式：

     ```toml
     [servers]
     server1 ansible_host=<服务器IP> ansible_user=root ansible_password=<密码>
     server2 ansible_host=<服务器IP> ansible_user=root ansible_password=<密码>
     # 替换 <服务器IP>、<密码> 为实际值，保存退出
     ```

3. **编辑 all.yml 文件**：

   - 配置服务器用途和 IP：

     ```bash
     vim inventory/group_vars/all.yml
     ```

     配置格式：

     ```toml
     Web_all服务器IP地址：（此内网IP建议先行使用公网IP）
     	main_server_ip           # web服务器公网IP
     	main_server_private_ip   # web服务器公网IP
     
     服务主机配置：（ES，prometheus服务器IP信息）
     	elastic_public_ip: "ES公网IP"
     	elastic_intranet_ip: "ES内网IP"
     	prometheus_intranet_ip: "Prometheus 内网IP"
     ```

### 3. 执行一键部署

运行以下命令，部分下载的文件文件较大，需要耐心等待，报错可重试。

⚠️ **重要提示**：
- 部署顺序很重要，请按照以下步骤依次执行
- Prometheus 配置更新必须在 Web 服务部署完成后执行
- 如需仅部署特定服务，可使用对应的 tags

#### 选项 A：一键完整部署

```bash
# 部署所有服务（包括自动更新 Prometheus 配置）
ansible-playbook -i inventory/hosts site.yml
```

#### 选项 B：分步部署 (推荐)

1. **进入项目目录**（如未进入）：

   ```bash
   cd Ansible_project
   ```

2. **部署日志系统（ES/Kibana）**：

   ```bash
   ansible-playbook -i inventory/hosts site.yml --tags es-kibana
   ```

3. **部署监控系统（Prometheus/夜莺）**：

   ```bash
   ansible-playbook -i inventory/hosts site.yml --tags monitor
   ```

4. **部署 Web 服务（CDN 管理系统）**：

   ```bash
   ansible-playbook -i inventory/hosts site.yml --tags cdn
   ```
   
   这将自动部署以下服务：
   - Docker 环境
   - MySQL 数据库
   - Redis 缓存
   - Kafka 消息队列
   - Auth Agent 认证服务
   - MCDN Agent Python 服务
   - Console 前端
   - API 服务
   - Admin 管理后台
   - Nginx Web服务器

5. **更新 Prometheus 监控配置**（自动从 admin-api-go 获取）：

   ```bash
   ansible-playbook -i inventory/hosts site.yml --tags prometheus-config
   ```
   
   注意：此步骤需要在 Web 服务完全部署后执行

6. **验证部署**：

   ```bash
   ansible-playbook -i inventory/hosts site.yml --tags verify
   ```

### 4. 服务访问地址

#### 主要服务端口：

- **CDN 管理后台**: `http://IP:89` 或 `https://admin.domain.com`
- **CDN API 服务**: `http://IP:90` 或 `https://api.domain.com`  
- **用户控制台**: `http://IP:91` 或 `https://console.domain.com`
- **MCDN Agent**: `http://IP:8090` (内部服务)
- **Prometheus 监控**: `http://IP:9090` (用户名: admin, 密码: prometheus098)
- **N9E 夜莺监控**: `http://IP:17000` (用户名: root, 密码: root.2020)
- **Kibana 日志**: `http://IP:5601`

#### 登录管理后台：

- **默认登录信息**：

  ```plaintext
  账号：admin@qq.com
  密码：m88888888
  ```

⚠️ **安全提醒**：
- 需要开放安全组端口：89、90、91、8090、9090、17000、5601
- 部署完成后请立即修改所有默认密码
- 建议配置防火墙规则限制访问来源
- 如果在某个步骤环境安装失败，可以删除此环节的所有服务或初始化次此服务器系统并重新安装
