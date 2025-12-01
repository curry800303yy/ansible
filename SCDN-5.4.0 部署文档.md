# V5.4.0 - SCDN 部署文档



> 标准服务器配置推荐（带宽建议无带宽限制，走流量付费更稳定）：
>
> CDN-Web_ALL-测试服务器 4C 16G 5Mbps 300GB
>
> CDN-Monitor服务器 4C 4G 5Mbps 200GB
>
> CDN-ES服务器 8C 16G 5Mbps+ 1TB
>
> ❗️：Web-all + Monitor + ES ，须都在同一个VPC，走内网



## 安装顺序

- 按照Ansible目录中的Readme进行部署即可
- 5.4.0 版本安装边缘节点时要求先安装fluent-bit再去管理后台安装边缘节点



#### 必看备注

<span style="color:red">**管理平台，用户平台，监控，日志等，需要对外暴露的，全部要走https，且接入waf。**</span>

内网服务需要屏蔽外网访问仅支持内网访问即可，以便提升安全性，mysql/redis/prometheus之类服务器

对外开放安全端口梳理：

80/443端口
