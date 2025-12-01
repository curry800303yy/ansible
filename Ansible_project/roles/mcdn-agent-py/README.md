# MCDN Agent Python Role

## 描述
部署 MCDN Agent Python 服务，这是一个 CDN 管理系统的 Python 代理服务。

## 功能
- 自动安装 Python3 环境
- 复制服务文件到安装目录
- 启动 Python 服务
- 监听端口 8090

## 默认变量
- `mcdn_agent_py_install_dir`: `/opt/mcdn-agent-py` - 服务安装目录
- `mcdn_agent_py_port`: `8090` - 服务端口

## 使用方法
```yaml
- role: mcdn-agent-py
  tags: ['mcdn-agent-py']
```

## 文件结构
```
/opt/mcdn-agent-py/
├── main.py           # 主程序文件
├── startup.sh        # 启动脚本
├── config.json       # 配置文件
└── log/             # 日志目录
```

## 部署顺序
在 web_server 部署中，此服务在 auth-agent 之后部署。