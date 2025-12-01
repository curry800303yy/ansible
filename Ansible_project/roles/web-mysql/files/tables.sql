SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for admin_logs
-- ----------------------------
CREATE TABLE IF NOT EXISTS `admin_logs` (
  `id` int unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `create_time` bigint unsigned NOT NULL COMMENT '创建时间(毫秒)',
  `update_time` bigint unsigned NOT NULL COMMENT '更新时间(毫秒)',
  `uid` int unsigned NOT NULL DEFAULT '0' COMMENT '用户ID',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '姓名',
  `type` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '操作类型',
  `action` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '操作动作',
  `rule_menu` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '节点权限路径',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '操作标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci COMMENT '操作描述',
  `ip` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '登录ip',
  `param_id` int unsigned NOT NULL DEFAULT '0' COMMENT '操作数据id',
  `param` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci COMMENT '参数json格式',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '0删除 1正常',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='员工操作日志表';

-- ----------------------------
-- Table structure for admin_menu_roles
-- ----------------------------
CREATE TABLE IF NOT EXISTS `admin_menu_roles` (
  `menu_id` int unsigned NOT NULL DEFAULT '0' COMMENT '菜单ID',
  `role_id` int unsigned NOT NULL DEFAULT '0' COMMENT '角色id',
  UNIQUE KEY `idex_menu_id_role_id` (`menu_id`,`role_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='菜单角色表';

-- ----------------------------
-- Table structure for admin_menu_users
-- ----------------------------
CREATE TABLE IF NOT EXISTS `admin_menu_users` (
  `type` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '0增加权限；1减权限',
  `menu_id` int unsigned NOT NULL DEFAULT '0' COMMENT '菜单ID',
  `user_id` int unsigned NOT NULL DEFAULT '0' COMMENT '用户id',
  KEY `idex_user_id` (`user_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='菜单用户表';

-- ----------------------------
-- Table structure for admin_menus
-- ----------------------------
CREATE TABLE IF NOT EXISTS `admin_menus` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '修改时间',
  `pid` int unsigned NOT NULL DEFAULT '0' COMMENT '父级菜单ID，0表示根菜单',
  `route` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '菜单路径',
  `redirect` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '重定义',
  `icon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '菜单图标',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '菜单名',
  `name_en` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '菜单名英文',
  `sort` int NOT NULL DEFAULT '0' COMMENT '越小越靠前',
  `status` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '0可用，1不可用',
  `is_show` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '是否显示菜单0不显示，1显示',
  `component` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '前端组件路径',
  `path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '前端组件路由',
  `type` tinyint unsigned NOT NULL COMMENT '类型：0系统后台，1用户后台 2 ddos菜单 3 回国加速',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_path` (`path`) USING BTREE,
  KEY `idx_is_show` (`is_show`) USING BTREE,
  KEY `idx_type` (`type`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='后台菜单';

-- ----------------------------
-- Table structure for admin_messages
-- ----------------------------
CREATE TABLE IF NOT EXISTS `admin_messages` (
  `message_id` int unsigned NOT NULL AUTO_INCREMENT,
  `role_id` int unsigned NOT NULL COMMENT '角色id',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '标题',
  `detail` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '详情',
  `user_id` int unsigned NOT NULL DEFAULT '0' COMMENT '用户id',
  `payment_intent_id` int unsigned NOT NULL COMMENT '支付id',
  `release` int unsigned NOT NULL DEFAULT '0' COMMENT '发布人 0表示系统',
  `create_time` int unsigned NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`message_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='管理员消息列表';

-- ----------------------------
-- Table structure for admin_users
-- ----------------------------
CREATE TABLE IF NOT EXISTS `admin_users` (
  `id` int unsigned NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '修改时间',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '登录名',
  `user_type` int NOT NULL DEFAULT '0' COMMENT '员工类型（0未设置1正式2适用3实习）',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '用户密码',
  `realname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '展示名',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '头像',
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '邮箱',
  `mobile_code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '手机区号',
  `mobile_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '手机号',
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '状态 0未激活 1激活 2禁用',
  `token` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT 'token',
  `last_login_ip` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '登录ip',
  `last_login_time` datetime DEFAULT NULL COMMENT '最后登录时间',
  `login_num` int unsigned NOT NULL DEFAULT '0' COMMENT '登录次数',
  `google_auth_secret` varchar(50) DEFAULT ''  NOT NULL COMMENT '谷歌身份验证器密钥',
  `google_auth_status` tinyint unsigned DEFAULT '0' NOT NULL COMMENT '谷歌身份验证器绑定状态  0 未绑定  1 已绑定',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uni_email` (`email`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='admin用户表';

-- ----------------------------
-- Table structure for agent_users
-- ----------------------------
CREATE TABLE IF NOT EXISTS `agent_users` (
  `agent_user_id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL DEFAULT '0',
  `status` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '状态  0 停用 1 启用',
  `name` varchar(255) NOT NULL DEFAULT '' COMMENT '代理商名',
  `app_backend_name` varchar(255) NOT NULL DEFAULT '' COMMENT '系统名称（中文）',
  `app_backend_name_en` varchar(255) NOT NULL DEFAULT '' COMMENT '系统名称（英文）',
  `official_website` varchar(255) NOT NULL DEFAULT '' COMMENT '官网域名',
  `user_background` varchar(255) NOT NULL DEFAULT '' COMMENT '用户后台',
  `more_config` json NOT NULL COMMENT '更多配置数据',
  `email_config` json NOT NULL COMMENT '邮箱配置',
  `create_time` int unsigned NOT NULL COMMENT '创建时间',
  `update_time` int unsigned NOT NULL DEFAULT '0' COMMENT '修改时间',
  PRIMARY KEY (`agent_user_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='代理商';

-- ----------------------------
-- Table structure for announcement_reads
-- ----------------------------
CREATE TABLE IF NOT EXISTS `announcement_reads` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `announcement_id` int unsigned NOT NULL DEFAULT '1' COMMENT 'announcements表id',
  `user_id` int unsigned NOT NULL DEFAULT '0' COMMENT '已阅用户id，ocation为0用户后台，对应的users表id, 1系统后台admin_users表id',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '0未阅，1已阅 2,要删除,3 有修改',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `unq_announcement_id_user_id` (`announcement_id`,`user_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='公告已阅表';

-- ----------------------------
-- Table structure for announcements
-- ----------------------------
CREATE TABLE IF NOT EXISTS `announcements` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '修改时间',
  `group_id` int unsigned NOT NULL DEFAULT '1' COMMENT 'groups表id',
  `role_id` int unsigned NOT NULL DEFAULT '1' COMMENT '角色表id，暂时未用',
  `user_id` int unsigned NOT NULL DEFAULT '0' COMMENT '消息归属用户id，默认0所有用户， location为0用户后台，对应的users表id, 1系统后台admin_users表id',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '标题',
  `detail` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '内容',
  `attach_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '附件名称',
  `attachment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '附件地址',
  `release` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '发布人 0表示系统 ,1后台人工',
  `location` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '发布位置 0用户后台 ,1系统后台',
  `admin_user_id` int unsigned NOT NULL DEFAULT '0' COMMENT '发布人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='公告表';

-- ----------------------------
-- Table structure for cache_clear_logs
-- ----------------------------
CREATE TABLE IF NOT EXISTS `cache_clear_logs` (
  `clear_log_id` int unsigned NOT NULL AUTO_INCREMENT,
  `clear_id` int unsigned NOT NULL DEFAULT '0' COMMENT '清除id',
  `user_services_id` int unsigned NOT NULL DEFAULT '0' COMMENT '服务id',
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '状态  -1 失败  0 未提交  1 提交刷新中 2 完成',
  `task_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '厂商返回的id值',
  `more` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '厂商返回的详情数据，做保存处理',
  `create_time` int unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  `update_time` int unsigned NOT NULL DEFAULT '0' COMMENT '修改时间',
  PRIMARY KEY (`clear_log_id`),
  KEY `clear_id` (`clear_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='厂商刷新日志记录';

-- ----------------------------
-- Table structure for cache_clears
-- ----------------------------
CREATE TABLE IF NOT EXISTS `cache_clears` (
  `clear_id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL DEFAULT '0' COMMENT '用户id',
  `domain_id` int unsigned NOT NULL DEFAULT '0' COMMENT '域名id',
  `type` tinyint unsigned NOT NULL COMMENT '类型  0 文件刷新  1目录刷新  2 文件预热',
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '状态 -1 失败 0 未执行  1 执行中  2 已完成',
  `rules` json NOT NULL COMMENT '目录|文件',
  `create_time` int unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  `update_time` int unsigned NOT NULL DEFAULT '0' COMMENT '修改时间',
  PRIMARY KEY (`clear_id`) USING BTREE,
  KEY `user_id` (`user_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='清楚缓存表';

-- ----------------------------
-- Table structure for cache_do_logs
-- ----------------------------
CREATE TABLE IF NOT EXISTS `cache_do_logs` (
  `cache_log_id` int unsigned NOT NULL AUTO_INCREMENT,
  `cache_id` int unsigned NOT NULL COMMENT '缓存id',
  `config_id` varchar(255) NOT NULL COMMENT '厂商配置返回的id',
  `create_time` int unsigned NOT NULL COMMENT '创建时间',
  `update_time` int unsigned NOT NULL COMMENT '修改时间',
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '未提交',
  PRIMARY KEY (`cache_log_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='缓存执行表';

-- ----------------------------
-- Table structure for caches
-- ----------------------------
CREATE TABLE IF NOT EXISTS `caches` (
  `cache_id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL DEFAULT '0' COMMENT '用户id',
  `domain_id` int unsigned NOT NULL DEFAULT '0' COMMENT '域名id',
  `status` tinyint unsigned NOT NULL COMMENT '规则类型 0 无规则 1 有规则',
  `type` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '类型 0 目录 1 文件后缀',
  `value` varchar(255) NOT NULL COMMENT '缓存目录',
  `time` int unsigned COMMENT '缓存时间（秒）',
  `time_type` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '时间类型 0 小时 1 天',
  `weight` tinyint unsigned NOT NULL DEFAULT '5' COMMENT '权重',
  `create_time` int unsigned NOT NULL COMMENT '创建时间',
  `update_time` int unsigned NOT NULL COMMENT '修改时间',
  PRIMARY KEY (`cache_id`),
  KEY `user_id` (`user_id`) USING BTREE,
  KEY `domain_id` (`domain_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='缓存配置';

-- ----------------------------
-- Table structure for client_configs
-- ----------------------------
CREATE TABLE IF NOT EXISTS `client_configs` (
  `id` int unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '修改时间',
  `config_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '配置名称',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '备注',
  `config_value` text NOT NULL COMMENT 'json数据加密配置值',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `unq_config_key` (`config_key`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='第三方平台配置';

-- ----------------------------
-- Table structure for contacts
-- ----------------------------
CREATE TABLE IF NOT EXISTS `contacts` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `agent_user_id` int unsigned NOT NULL DEFAULT '0' COMMENT '代理商id  0 表示全部',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '修改时间',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '联系人',
  `way` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '联系方式',
  `image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '二维码图片',
  `is_show` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '是否显示: 0不显示1显示',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '备注',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='公司联系方式';

-- ----------------------------
-- Table structure for daily_defense_reports
-- ----------------------------
CREATE TABLE IF NOT EXISTS `daily_defense_reports` (
  `daily_defense_id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL DEFAULT '0' COMMENT '用户id',
  `type` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '类型  0 域名统计  1 IP统计 2 url 统计',
  `day` date NOT NULL COMMENT '统计时间',
  `value` varchar(255) NOT NULL COMMENT '值',
  `number` bigint unsigned NOT NULL DEFAULT '0' COMMENT '统计数量',
  PRIMARY KEY (`daily_defense_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='防护统计';

-- ----------------------------
-- Table structure for daily_report_counts
-- ----------------------------
CREATE TABLE IF NOT EXISTS `daily_report_counts` (
  `daily_id` int unsigned NOT NULL AUTO_INCREMENT,
  `day` date NOT NULL COMMENT '当前日',
  `hours` json NOT NULL COMMENT '分钟详细数',
  `volume` bigint unsigned NOT NULL DEFAULT '0' COMMENT '流量总值, 单位byte',
  `volume_origin` bigint unsigned NOT NULL DEFAULT '0' COMMENT '回源流量, 单位byte',
  `request` bigint unsigned NOT NULL DEFAULT '0' COMMENT '请求数总值，单位个',
  `request_origin` bigint unsigned NOT NULL DEFAULT '0' COMMENT '回源带宽数',
  `source_response_time` decimal(10,4) unsigned NOT NULL DEFAULT '0.0000' COMMENT '平均耗时',
  `req_hit_rate` decimal(20,4) unsigned NOT NULL DEFAULT '0.0000' COMMENT '请求命中率',
  `hit_rate` decimal(20,4) unsigned NOT NULL DEFAULT '0.0000' COMMENT '流量命中率',
  `bandwidth` decimal(20,4) unsigned NOT NULL DEFAULT '0.0000' COMMENT '带宽 kbps',
  `qps` decimal(20,4) unsigned NOT NULL DEFAULT '0.0000' COMMENT 'QPS',
  `updated_time` int unsigned NOT NULL DEFAULT '0' COMMENT '修改时间',
  PRIMARY KEY (`daily_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='单天数据总数统计';

-- ----------------------------
-- Table structure for daily_report_domains
-- ----------------------------
CREATE TABLE IF NOT EXISTS `daily_report_domains` (
  `daily_report_domain_id` int unsigned NOT NULL AUTO_INCREMENT,
  `daily_id` int unsigned NOT NULL COMMENT '父级id',
  `domain` varchar(255) NOT NULL COMMENT '域名',
  `day` date NOT NULL COMMENT '天数',
  `hours` json NOT NULL COMMENT '分钟详细数据',
  `volume` bigint unsigned NOT NULL DEFAULT '0' COMMENT '流量数',
  `volume_origin` bigint unsigned NOT NULL DEFAULT '0' COMMENT '回源流量, 单位byte',
  `request` bigint unsigned NOT NULL DEFAULT '0' COMMENT '请求数',
  `request_origin` bigint unsigned NOT NULL DEFAULT '0' COMMENT '回源带宽数',
  `source_response_time` decimal(20,4) unsigned NOT NULL DEFAULT '0.0000' COMMENT '回源平均耗时 单位 s',
  `req_hit_rate` decimal(10,2) unsigned NOT NULL DEFAULT '0.00' COMMENT '请求命中率',
  `hit_rate` decimal(10,2) unsigned NOT NULL DEFAULT '0.00' COMMENT '流量命中率',
  `bandwidth` decimal(16,2) unsigned NOT NULL DEFAULT '0.00' COMMENT '带宽 kbps',
  `qps` decimal(16,2) unsigned NOT NULL DEFAULT '0.00' COMMENT 'QPS ',
  `updated_time` int unsigned NOT NULL DEFAULT '0' COMMENT '修改时间',
  PRIMARY KEY (`daily_report_domain_id`) USING BTREE,
  KEY `daily_id` (`daily_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='报表多域名数据';

-- ----------------------------
-- Table structure for daily_reports
-- ----------------------------
CREATE TABLE IF NOT EXISTS `daily_reports` (
  `daily_id` int unsigned NOT NULL AUTO_INCREMENT,
  `domain_id` int unsigned NOT NULL COMMENT '域名id',
  `day` date NOT NULL COMMENT '当前日',
  `hours` json NOT NULL COMMENT '分组数据组 json格式\r\n{"volume": [], "request": [], "hit_rate": [], "req_hit_rate": [], "volume_origin": [], "request_origin": []}',
  `volume` bigint unsigned NOT NULL DEFAULT '0' COMMENT '流量总值, 单位byte',
  `volume_origin` bigint unsigned NOT NULL DEFAULT '0' COMMENT '回源流量, 单位byte',
  `request` bigint unsigned NOT NULL COMMENT '请求数总值，单位个数',
  `request_origin` bigint unsigned NOT NULL COMMENT '回源请求数，单位个数',
  `source_response_time` decimal(20,4) unsigned NOT NULL DEFAULT '0.0000' COMMENT '平均耗时',
  `req_hit_rate` decimal(10,2) unsigned NOT NULL COMMENT '请求命中率',
  `hit_rate` decimal(10,2) unsigned NOT NULL COMMENT '流量命中率',
  `bandwidth` decimal(10,2) unsigned NOT NULL DEFAULT '0.00' COMMENT '带宽 kbps',
  `qps` decimal(10,2) unsigned NOT NULL DEFAULT '0.00' COMMENT 'QPS ',
  `updated_time` int unsigned NOT NULL DEFAULT '0' COMMENT '修改时间（判断是否以及统计过）',
  `status` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '状态 1 正常  2 废弃',
  PRIMARY KEY (`daily_id`) USING BTREE,
  KEY `domain_id` (`domain_id`) USING BTREE,
  CONSTRAINT `daily_reports_ibfk_1` FOREIGN KEY (`domain_id`) REFERENCES `domains` (`domain_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='报表数据（日报表）';

-- ----------------------------
-- Table structure for dns_set_logs
-- ----------------------------
CREATE TABLE IF NOT EXISTS `dns_set_logs` (
  `dns_set_log_id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL DEFAULT '0' COMMENT '用户id',
  `domain_group_id` int unsigned NOT NULL COMMENT '分组id',
  `user_dns_api_id` int unsigned NOT NULL DEFAULT '0' COMMENT 'dns配置',
  `type` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '类型 0、DNS API 1、节点删除 2、节点加入分组 3、切换节点 4、套餐移除节点 5、套餐添加节点 6、启用禁用节点 7、删除网站分组 8、配置gateway 9、增加CNAME域名 10、删除CNAME域名',
  `action` enum('0','1') NOT NULL DEFAULT '0' COMMENT '动作 0 删除 1 新增',
  `domain` varchar(255) NOT NULL COMMENT '域名',
  `partner` varchar(255) NOT NULL COMMENT '厂商',
  `status` enum('0','1') NOT NULL DEFAULT '0' COMMENT '状态 0 失败 1 成功',
  `remark` varchar(255) NOT NULL DEFAULT '' COMMENT '备注',
  `value` varchar(255) NOT NULL DEFAULT '' COMMENT '保存值',
  `more` json DEFAULT NULL COMMENT '重试数据暂存',
  `line` varchar(255) NOT NULL DEFAULT '默认' COMMENT '线路',
  `create_time` int unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  `update_time` int unsigned NOT NULL DEFAULT '0' COMMENT '修改时间',
  PRIMARY KEY (`dns_set_log_id`) USING BTREE,
  KEY `user_id` (`user_id`),
  KEY `domian_group_id` (`domain_group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='dns操作记录';

-- ----------------------------
-- Table structure for domain_details
-- ----------------------------
CREATE TABLE IF NOT EXISTS `domain_details` (
  `domain_id` int unsigned NOT NULL,
  `cert_id` int unsigned DEFAULT NULL COMMENT '证书id',
  `origin_type` tinyint DEFAULT '0' COMMENT '源站类型 0:域名,1:ip',
  `origin_domain` json DEFAULT NULL COMMENT '回源地址  可以是ip或域名',
  `origin_host` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '回源host配置',
  `read_timeout` int unsigned NOT NULL DEFAULT '0' COMMENT '回源超时',
  `conn_timeout` int unsigned NOT NULL DEFAULT '0' COMMENT '连接超时',
  `max_conns` int unsigned NOT NULL DEFAULT '0' COMMENT '最大连接数',
  `max_idle_conns` int unsigned NOT NULL DEFAULT '0' COMMENT '最大空闲连接数',
  `idle_time` int unsigned NOT NULL DEFAULT '0' COMMENT '连接最大空闲时间',
  `ssl_type` tinyint unsigned DEFAULT NULL COMMENT '协议类型 0：不指定，1：http ，2：https',
  `created_time` int unsigned NOT NULL COMMENT '创建时间',
  `updated_time` int unsigned NOT NULL COMMENT '修改时间',
  `head` json DEFAULT NULL COMMENT '自定义主机头',
  `sni` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '是否开启sni功能',
  `force` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '是否强制跳转， 0不设置  1 强制https 2 强制http',
  `force_type` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '强制跳转方式   0、301  1、302',
  `app_id` varchar(100) NOT NULL DEFAULT '' COMMENT 'waf分配的应用id',
  `cert_status` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '证书申请状态  0、未申请 1、cname未配置 2、证书申请种 3、证书获取成功 4、证书已经上传',
  `waf_area_type` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '设置源站区域类型  0 自动指定  1 手动指定',
  `http2` tinyint unsigned NOT NULL DEFAULT '0' COMMENT 'http2状态 0 关闭  1 开启',
  `ocsp` tinyint unsigned NOT NULL DEFAULT '0' COMMENT 'oscp状态 0 关闭  1 开启',
  `hsts` tinyint unsigned NOT NULL DEFAULT '0' COMMENT 'hsts状态  0 关闭  1 开启',
  `cert_vendor` smallint NOT NULL DEFAULT '0' COMMENT '指定证书的签发厂商 0 let''s encript  -2 zero ssl',
  `cache_enabled` enum('0','1') NOT NULL DEFAULT '1' COMMENT '是否启用cache 0 否1 是',
  `cache_type` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '缓存类型 0 分组 1 域名',
  `port_following` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '是否启用端口跟随 0 不启用 1 启用',
  `waf_enabled` TINYINT(1) UNSIGNED DEFAULT 1 COMMENT '是否启用WAF 0 否 1 是',
  `cc_enabled` TINYINT(1) UNSIGNED DEFAULT 1 COMMENT '是否启用CC防护 0 否 1 是',
  PRIMARY KEY (`domain_id`) USING BTREE,
  KEY `cert_id` (`cert_id`) USING BTREE,
  CONSTRAINT `domain_id` FOREIGN KEY (`domain_id`) REFERENCES `domains` (`domain_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='域名详情';

-- ----------------------------
-- Table structure for domain_group_advances
-- ----------------------------
CREATE TABLE IF NOT EXISTS `domain_group_advances` (
  `domain_group_id` int unsigned NOT NULL,
  `gzip` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '是否启用gzip 0 否 1 是',
  `cors_enabled` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '是否启用  0 否 1 是',
  `allow_origin` varchar(255) NOT NULL DEFAULT '*' COMMENT '允许在哪个网站发起',
  `allow_methods` varchar(255) NOT NULL DEFAULT '*' COMMENT ' 允许使用哪些请求方式来访问，逗号分隔多个值，*表示任意方式',
  `allow_headers` varchar(255) NOT NULL DEFAULT '*' COMMENT '允许添加哪些自定义的头，逗号分隔多个，*表示任意头',
  `expose_headers` varchar(255) NOT NULL DEFAULT '*' COMMENT '针对本站的响应头，哪些HTTP头字段可以读取',
  `allow_credentials` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '是否允许附带本站的【Cookie、客户端证书或自定义Http头】 0 否 1 是',
  `max_age` int unsigned NOT NULL DEFAULT '0' COMMENT '下次预检的间隔时间是多久',
  `web_socket` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '是否启用  1 是 0 否',
  `log_enabled` TINYINT(1) UNSIGNED DEFAULT 1 COMMENT '是否启用日志 0 否 1 是',
  `auto_buffer_enabled` TINYINT(1) UNSIGNED DEFAULT 1 COMMENT '是否启用自动缓冲 0 否 1 是',
  PRIMARY KEY (`domain_group_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='高级设置';

-- ----------------------------
-- Table structure for domain_group_list_certs
-- ----------------------------
CREATE TABLE IF NOT EXISTS `domain_group_list_certs` (
  `domain_group_list_cert_id` int unsigned NOT NULL AUTO_INCREMENT,
  `domain_group_list_id` int unsigned NOT NULL DEFAULT '0' COMMENT '域名分组列表ID',
  `type` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '类型 0 系统签发 1 用户上传',
  `name` varchar(255) NOT NULL COMMENT '证书名称',
  `institution` varchar(255) NOT NULL DEFAULT '' COMMENT '机构',
  `status` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '状态 0 待签发 1 已签发',
  `use_status` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '使用状态 0 已禁用 1 启用',
  `waf_cert_id` varchar(255) NOT NULL DEFAULT '' COMMENT '远程证书ID',
  `error` varchar(255) NOT NULL DEFAULT '' COMMENT '报错',
  `from_time` int unsigned NOT NULL DEFAULT '0' COMMENT '开始时间',
  `to_time` int unsigned NOT NULL DEFAULT '0' COMMENT '结束时间',
  PRIMARY KEY (`domain_group_list_cert_id`) USING BTREE,
  KEY `domain_group_list_id` (`domain_group_list_id`),
  CONSTRAINT `domain_group_list_cert_key1` FOREIGN KEY (`domain_group_list_id`) REFERENCES `domain_group_lists` (`domain_group_list_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='证书列表';

-- ----------------------------
-- Table structure for domain_group_listen_ports
-- ----------------------------
CREATE TABLE IF NOT EXISTS `domain_group_listen_ports` (
  `domain_group_listen_port_id` int unsigned NOT NULL AUTO_INCREMENT,
  `domain_group_id` int unsigned NOT NULL DEFAULT '0' COMMENT '分组id',
  `type` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '类型 0 http 1 https',
  `port` smallint unsigned NOT NULL DEFAULT '0' COMMENT '端口',
  PRIMARY KEY (`domain_group_listen_port_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='分组监听端口数据';

-- ----------------------------
-- Table structure for domain_group_lists
-- ----------------------------
CREATE TABLE IF NOT EXISTS `domain_group_lists` (
  `domain_group_list_id` int unsigned NOT NULL AUTO_INCREMENT,
  `domain_group_id` int unsigned NOT NULL DEFAULT '0',
  `domain` varchar(255) NOT NULL COMMENT '域名',
  PRIMARY KEY (`domain_group_list_id`),
  KEY `domain_group_id` (`domain_group_id`),
  KEY `idx_domain_group_lists_domain_group_id` (`domain_group_id`),
  KEY `idx_domain_group_lists_domain` (`domain`),
  KEY `idx_domain_group_lists_group_domain` (`domain_group_id`,`domain`),
  CONSTRAINT `domain_group_lists_key1` FOREIGN KEY (`domain_group_id`) REFERENCES `domain_groups` (`domain_group_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='多域名组';

-- ----------------------------
-- Table structure for domain_group_logs
-- ----------------------------
CREATE TABLE IF NOT EXISTS `domain_group_logs` (
  `domain_group_log_id` int unsigned NOT NULL AUTO_INCREMENT,
  `domain_group_id` int unsigned NOT NULL DEFAULT '0' COMMENT '分组id',
  `name` varchar(255) NOT NULL COMMENT '文件名',
  `url` json DEFAULT NULL COMMENT '下载地址',
  `status` tinyint unsigned NOT NULL COMMENT '状态 ： 0 未生成 1 可下载 2 生成失败',
  `count` bigint unsigned NOT NULL DEFAULT '0' COMMENT '日志总数',
  `create_time` int unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  `update_time` int unsigned NOT NULL DEFAULT '0' COMMENT '修改时间',
  `start_time` int unsigned NOT NULL DEFAULT '0' COMMENT '开始时间',
  `end_time` int unsigned NOT NULL DEFAULT '0' COMMENT '结束时间',
  PRIMARY KEY (`domain_group_log_id`),
  KEY `domain_group_id` (`domain_group_id`),
  CONSTRAINT `domain_group_log_key1` FOREIGN KEY (`domain_group_id`) REFERENCES `domain_groups` (`domain_group_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='新版日志记录';

-- ----------------------------
-- Table structure for domain_group_node_port2s
-- ----------------------------
CREATE TABLE IF NOT EXISTS `domain_group_node_port2s` (
  `domain_group_node_port_id` int unsigned NOT NULL DEFAULT '0',
  `port` smallint unsigned NOT NULL DEFAULT '0' COMMENT '端口',
  `type` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '类型  0 http 1 https',
  KEY `domain_group_node_port_key_11` (`domain_group_node_port_id`),
  CONSTRAINT `domain_group_node_port_key_11` FOREIGN KEY (`domain_group_node_port_id`) REFERENCES `domain_group_node_ports` (`domain_group_node_port_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='域名分组ip对应的端口数据';

-- ----------------------------
-- Table structure for domain_group_node_ports
-- ----------------------------
CREATE TABLE IF NOT EXISTS `domain_group_node_ports` (
  `domain_group_node_port_id` int unsigned NOT NULL AUTO_INCREMENT,
  `domain_group_id` int unsigned NOT NULL DEFAULT '0' COMMENT '分组id',
  `waf_node_id` int unsigned NOT NULL DEFAULT '0' COMMENT '节点ip 的id',
  `type` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '类型  0 http 1 https',
  `port` int unsigned NOT NULL DEFAULT '0' COMMENT '端口号',
  `status` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '状态  0 关闭  1 启用',
  `remark` varchar(255) NOT NULL DEFAULT '' COMMENT '备注',
  PRIMARY KEY (`domain_group_node_port_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='ip加端口数据列表';

-- ----------------------------
-- Table structure for domain_group_urls
-- ----------------------------
CREATE TABLE IF NOT EXISTS `domain_group_urls` (
  `domain_group_url_id` int unsigned NOT NULL AUTO_INCREMENT,
  `domain_group_id` int unsigned NOT NULL COMMENT '分组id',
  `more` json DEFAULT NULL COMMENT '更多条件规则',
  `redirect_id` varchar(255) NOT NULL DEFAULT '' COMMENT '远程id',
  `port` varchar(50) NOT NULL DEFAULT '*' COMMENT '端口匹配',
  `uri` varchar(255) NOT NULL COMMENT '匹配的uri',
  `url` varchar(255) NOT NULL COMMENT '转向到url',
  `code` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '响应码  0、301 1、302',
  `create_time` int unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  PRIMARY KEY (`domain_group_url_id`),
  KEY `domain_group_id` (`domain_group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='匹配uri转向';

-- ----------------------------
-- Table structure for domain_groups
-- ----------------------------
CREATE TABLE IF NOT EXISTS `domain_groups` (
  `domain_group_id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL DEFAULT '0' COMMENT '用户id',
  `agent_user_id` int unsigned NOT NULL DEFAULT '0' COMMENT '代理商id',
  `cname` char(9) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'CNAME，固定g前缀 + domain_group_id 8个混淆字符',
  `dns` char(8) NOT NULL DEFAULT '' COMMENT 'dns 记录值',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '组名称',
  `group_id` varchar(255) NOT NULL DEFAULT '' COMMENT 'waf分组id',
  `status` tinyint unsigned NOT NULL COMMENT '是否启用组CNAME，1启用，0不启用  2 禁用   3 删除',
  `type` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '类型  0 旧版  1 新版',
  `user_power_traffics_id` int unsigned NOT NULL COMMENT '套餐id',
  `has_cdn` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '是否有cdn  0 没有  1 有',
  `config_status` tinyint NOT NULL DEFAULT '0' COMMENT 'waf配置状态  -2 waf 配置失败  -1 cdn配置失败  0 未配置  1 cdn配置中  2 waf配置完成',
  `traffic_arr` json NOT NULL COMMENT '当前分组使用的流量包',
  `use_dns` enum('0','1') NOT NULL DEFAULT '0' COMMENT '是否启用dnsapi  0 否  1 是',
  `user_dns_api_id` int unsigned NOT NULL DEFAULT '0' COMMENT 'dns id',
  `port_type` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '是否开启监听端口 0 否 1 是',
  `created_time` timestamp NOT NULL COMMENT '创建时间',
  `updated_time` timestamp NOT NULL COMMENT '修改时间',
  `weight_enabled` tinyint unsigned DEFAULT '0' COMMENT '启用权重 0 未启用 1 启用',
  PRIMARY KEY (`domain_group_id`),
  KEY `domain_groups_user_power_traffics_id_index` (`user_power_traffics_id`),
  KEY `domain_groups_group_id_index` (`group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='域名分组表，组内的域名共用一个 cname';

-- ----------------------------
-- Table structure for domain_node_dns
-- ----------------------------
CREATE TABLE IF NOT EXISTS `domain_node_dns` (
  `domain_node_dns_id` int unsigned NOT NULL AUTO_INCREMENT,
  `domain_group_id` int unsigned NOT NULL COMMENT '分组id',
  `waf_node_id` int unsigned NOT NULL COMMENT '节点id',
  `waf_node_line_id` int unsigned NOT NULL DEFAULT '0' COMMENT '节点区域id',
  `partner_dns_domain_id` int unsigned NOT NULL DEFAULT '0' COMMENT '厂商域名id',
  `partner_dns_id` int unsigned NOT NULL DEFAULT '0' COMMENT '厂商id',
  `dns_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '远程 dns 解析id',
  `sub_domain` varchar(255) NOT NULL COMMENT '记录值',
  `root_domain` varchar(255) NOT NULL COMMENT '主域名',
  `status` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '状态  1 上线 0 下线',
  `create_time` int unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`domain_node_dns_id`) USING BTREE,
  KEY `waf_node_id` (`waf_node_id`),
  KEY `domain_group_id` (`domain_group_id`),
  KEY `sub_domain` (`sub_domain`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='域名节点记录表';

-- ----------------------------
-- Table structure for domain_node_to_dns
-- ----------------------------
CREATE TABLE IF NOT EXISTS `domain_node_to_dns` (
  `domain_node_dns_id` int unsigned NOT NULL,
  `waf_node_id` int unsigned NOT NULL,
  `status` enum('0','1') NOT NULL DEFAULT '1' COMMENT '状态 0 停用 1 启用',
  KEY `dns_to_node_key1` (`domain_node_dns_id`),
  CONSTRAINT `dns_to_node_key1` FOREIGN KEY (`domain_node_dns_id`) REFERENCES `domain_node_dns` (`domain_node_dns_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='domain_node_dns 关联 waf_nodes  ns1 解析使用的';

-- ----------------------------
-- Table structure for domains
-- ----------------------------
CREATE TABLE IF NOT EXISTS `domains` (
  `domain_id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL,
  `agent_user_id` int unsigned NOT NULL DEFAULT '0' COMMENT '代理商id',
  `domain_group_id` int unsigned NOT NULL DEFAULT '1' COMMENT '域名所属的分组',
  `domain` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '域名',
  `cname` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '分配的cname前缀',
  `status` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '状态 0未开通 1启用中 2禁用 3 删除 无cdn无流量 4 删除有cdn无流量 5 删除 有cdn有流量',
  `type` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '类型  0 普通cdn  1 安全cdn',
  `created_time` int unsigned NOT NULL COMMENT '创建时间',
  `deleted_time` int unsigned NOT NULL DEFAULT '0' COMMENT '删除时间',
  `updated_time` int unsigned NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`domain_id`) USING BTREE,
  KEY `user_id` (`user_id`) USING BTREE,
  KEY `domain_group_id` (`domain_group_id`) USING BTREE,
  CONSTRAINT `domain_group_id` FOREIGN KEY (`domain_group_id`) REFERENCES `domain_groups` (`domain_group_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='用户域名列表';

-- ----------------------------
-- Table structure for groups
-- ----------------------------
CREATE TABLE IF NOT EXISTS `groups` (
  `group_id` int unsigned NOT NULL AUTO_INCREMENT,
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '修改时间',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '分类名',
  `name_en` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '分类名,英文名',
  `type` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '类型  0 产品 1无 2 消息',
  PRIMARY KEY (`group_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='CDN分类标签';

-- ----------------------------
-- Table structure for ip2region_regions
-- ----------------------------
CREATE TABLE IF NOT EXISTS `ip2region_regions` (
  `region_id` int unsigned NOT NULL AUTO_INCREMENT,
  `geoname_id` int unsigned DEFAULT NULL COMMENT 'geoname 的 id',
  `parent_id` int unsigned DEFAULT NULL COMMENT '父级ID',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '英文名称',
  `cn_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'ip2region中的名称',
  `level` float unsigned DEFAULT NULL COMMENT '0:区域，1:国家，2:省份，3:城市，4县级',
  `postcode` int DEFAULT NULL COMMENT '邮编',
  `latitude` decimal(10,6) DEFAULT NULL COMMENT '精度',
  `longitude` decimal(10,6) DEFAULT NULL COMMENT '维度',
  `timezone` varchar(255) DEFAULT NULL COMMENT '时区',
  `sort` tinyint unsigned DEFAULT '0' COMMENT '排序',
  `short_name` varchar(255) DEFAULT NULL COMMENT '短名称',
  `notsure` tinyint unsigned DEFAULT NULL COMMENT '是否确定',
  `updated_time` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`region_id`) USING BTREE,
  KEY `parent_id` (`parent_id`) USING BTREE,
  KEY `idx_cn_name` (`cn_name`) USING BTREE,
  KEY `idx_name` (`name`) USING BTREE,
  KEY `idx_level` (`level`) USING BTREE,
  KEY `unq_geoname_id` (`geoname_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='ip2region城市信息表，用于替换 maxmind,geonames 的城市信息';

-- ----------------------------
-- Table structure for log_operations
-- ----------------------------
CREATE TABLE IF NOT EXISTS `log_operations` (
  `log_id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL COMMENT '用户id',
  `show_user` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '是否显示用户端  1 显示 0 不显示',
  `ip` int unsigned NOT NULL COMMENT '操作ip',
  `created_time` bigint unsigned NOT NULL COMMENT '创建时间(毫秒)',
  `action` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '动作  ',
  `action_en` varchar(50) NOT NULL DEFAULT '' COMMENT '动作 英文',
  `detail` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '内容',
  `detail_en` text NOT NULL COMMENT '内容  英文',
  `is_system` tinyint DEFAULT '0' COMMENT '是否系统记录， 0 否， 1 是',
  PRIMARY KEY (`log_id`) USING BTREE,
  KEY `user_id` (`user_id`) USING BTREE,
  CONSTRAINT `log_operations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='操作日志';

-- ----------------------------
-- Table structure for messages
-- ----------------------------
CREATE TABLE IF NOT EXISTS `messages` (
  `message_id` int unsigned NOT NULL AUTO_INCREMENT,
  `group_id` int unsigned NOT NULL,
  `announcement_id` int unsigned NOT NULL DEFAULT '1' COMMENT 'announcements表id',
  `user_id` int unsigned NOT NULL DEFAULT '0' COMMENT '消息归属用户id',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '消息标题',
  `detail` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '消息内容详情',
  `status` tinyint unsigned DEFAULT '0' COMMENT '状态 0未读 1已读',
  `attach_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '附件名称',
  `attachment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '附件地址',
  `create_time` int unsigned DEFAULT NULL COMMENT '创建时间',
  `release` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '发布人 0表示系统 ',
  PRIMARY KEY (`message_id`) USING BTREE,
  KEY `message_group_id` (`group_id`) USING BTREE,
  KEY `announcement_id` (`announcement_id`) USING BTREE,
  CONSTRAINT `message_group_id` FOREIGN KEY (`group_id`) REFERENCES `groups` (`group_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='消息中心';

-- ----------------------------
-- Table structure for order_offline_pay_logs
-- ----------------------------
CREATE TABLE IF NOT EXISTS `order_offline_pay_logs` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `order_id` int unsigned NOT NULL DEFAULT '0' COMMENT '订单id',
  `admin_id` int unsigned NOT NULL DEFAULT '0' COMMENT '管理员id',
  `pay_config_id` int unsigned NOT NULL COMMENT '支付方式,pay_configs表',
  `remark` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '备注或者请输入流水号或转账信息',
  `pay_type` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '支付方式：1支付宝2微信支付3PayPal4信用卡支付5对公转账6其它支付7USDT',
  `create_time` int unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`) USING BTREE,
  KEY `idx_admin_id` (`admin_id`) USING BTREE,
  KEY `idx_pay_config_id` (`pay_config_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='订单设为已支付记录表';

-- ----------------------------
-- Table structure for order_price_logs
-- ----------------------------
CREATE TABLE IF NOT EXISTS `order_price_logs` (
  `log_id` int unsigned NOT NULL AUTO_INCREMENT,
  `order_id` int unsigned NOT NULL DEFAULT '0' COMMENT '订单id',
  `admin_id` int unsigned NOT NULL DEFAULT '0' COMMENT '管理员id',
  `original_price` bigint unsigned NOT NULL DEFAULT '0' COMMENT '原价  单位 分',
  `price` bigint unsigned NOT NULL DEFAULT '0' COMMENT '现价  单位 分 ',
  `remake` varchar(255) NOT NULL COMMENT '原因 备注',
  `create_time` int unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  PRIMARY KEY (`log_id`),
  KEY `order_id` (`order_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='价格修改记录表';

-- ----------------------------
-- Table structure for order_refund_logs
-- ----------------------------
CREATE TABLE IF NOT EXISTS `order_refund_logs` (
  `order_refund_log_id` int unsigned NOT NULL AUTO_INCREMENT,
  `order_id` int unsigned NOT NULL DEFAULT '0' COMMENT '订单id',
  `admin_id` int unsigned NOT NULL DEFAULT '0' COMMENT '管理员id',
  `pay_config_id` int unsigned NOT NULL COMMENT '支付方式,pay_configs表',
  `price` int unsigned NOT NULL DEFAULT '0' COMMENT '退款金额  单位  分',
  `create_time` int unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  PRIMARY KEY (`order_refund_log_id`) USING BTREE,
  KEY `idx_order_id` (`order_id`) USING BTREE,
  KEY `idx_admin_id` (`admin_id`) USING BTREE,
  KEY `idx_pay_config_id` (`pay_config_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='订单 退款 记录';

-- ----------------------------
-- Table structure for orders
-- ----------------------------
CREATE TABLE IF NOT EXISTS `orders` (
  `order_id` int unsigned NOT NULL AUTO_INCREMENT,
  `product_traffic_id` int unsigned NOT NULL COMMENT '流量包id',
  `order_node` char(8) NOT NULL COMMENT '加密的订单号',
  `user_id` int unsigned NOT NULL COMMENT '用户id',
  `agent_user_id` int unsigned NOT NULL DEFAULT '0' COMMENT '代理商id',
  `pay_config_id` int unsigned NOT NULL COMMENT '支付id',
  `user_power_traffics_id` int unsigned NOT NULL DEFAULT '0' COMMENT '订单对应的流量包id',
  `type` tinyint unsigned NOT NULL COMMENT '类型',
  `product_type` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '产品类型',
  `product` varchar(255) NOT NULL DEFAULT '' COMMENT '产品名称',
  `product_en` varchar(255) NOT NULL DEFAULT '' COMMENT '产品名称英文',
  `traffic` bigint unsigned NOT NULL COMMENT '流量总数',
  `num` smallint unsigned NOT NULL DEFAULT '0' COMMENT '数量',
  `periods` smallint unsigned NOT NULL DEFAULT '1' COMMENT '期数',
  `expiration` smallint unsigned NOT NULL COMMENT '有效期值',
  `exp_unit` tinyint unsigned NOT NULL COMMENT '有效期单位',
  `original_price` bigint unsigned NOT NULL DEFAULT '0' COMMENT '原价总计',
  `price` bigint unsigned NOT NULL DEFAULT '0' COMMENT '现价',
  `traffic_area_id` int unsigned NOT NULL COMMENT '流量包区域id',
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '状态',
  `domain_num` int unsigned NOT NULL COMMENT '购买加速域名数量',
  `waf_status` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '是否包含waf',
  `create_time` int unsigned NOT NULL COMMENT '创建时间',
  `update_time` int unsigned NOT NULL COMMENT '修改时间',
  `pay_time` int unsigned NOT NULL DEFAULT '0' COMMENT '支付时间',
  `is_automatic` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '是否自动续订',
  `buy_param` json NOT NULL COMMENT '购买时记录的参数值',
  `universal_dns` enum('0','1') NOT NULL DEFAULT '1' COMMENT '是否支持泛域名',
  `products` json DEFAULT NULL COMMENT '包含的cdn值',
  PRIMARY KEY (`order_id`),
  KEY `user_id` (`user_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='订单表';

-- ----------------------------
-- Table structure for partner_dns
-- ----------------------------
CREATE TABLE IF NOT EXISTS `partner_dns` (
  `partner_dns_id` int unsigned NOT NULL AUTO_INCREMENT,
  `partner` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '类型  1 阿里 2 ns1',
  `name` varchar(255) NOT NULL DEFAULT '' COMMENT '厂商名备注',
  `secret_id` varchar(255) NOT NULL DEFAULT '' COMMENT 'secret_id',
  `secret_key` varchar(255) NOT NULL DEFAULT '' COMMENT 'secret_key',
  `create_time` int unsigned NOT NULL COMMENT '创建时间',
  `update_time` int unsigned NOT NULL COMMENT '修改时间',
  PRIMARY KEY (`partner_dns_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='dns厂商管理';

-- ----------------------------
-- Table structure for partner_dns_domains
-- ----------------------------
CREATE TABLE IF NOT EXISTS `partner_dns_domains` (
  `partner_dns_domain_id` int unsigned NOT NULL AUTO_INCREMENT,
  `partner_dns_id` int unsigned NOT NULL DEFAULT '0' COMMENT '关联Dns厂商ID',
  `domain` varchar(255) NOT NULL COMMENT '域名',
  `type` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '类型   0 未启用 1 共享 2 私享',
  `remark` varchar(255) NOT NULL COMMENT '备注',
  `version_type` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '域名版本 0 不支持线路 1 支持线路',
  `record_count` int unsigned NOT NULL DEFAULT '0' COMMENT '解析总数',
  `ttl` smallint unsigned NOT NULL DEFAULT '600' COMMENT '应用时间',
  `create_time` int unsigned NOT NULL COMMENT '创建时间',
  `update_time` int unsigned NOT NULL COMMENT '修改时间',
  PRIMARY KEY (`partner_dns_domain_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='dns 厂商 域名 管理';

-- ----------------------------
-- Table structure for pay_configs
-- ----------------------------
CREATE TABLE IF NOT EXISTS `pay_configs` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '修改时间',
  `pay_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '支付方式名称',
  `pay_name_en` varchar(255) NOT NULL DEFAULT '' COMMENT '支付方式英文',
  `icon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '支付方式图标',
  `is_default` tinyint NOT NULL DEFAULT '0' COMMENT '是否默认支付 1是 0否',
  `pay_key` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '支付别名',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '是否显示客户端 1显示 0隐藏',
  `order` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '排序 数字越小 排序越高',
  `api_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '需要调用的api文件',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `UNIQUE_PAY_KEY` (`pay_key`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='支付配置表';

-- ----------------------------
-- Table structure for payment_intents
-- ----------------------------
CREATE TABLE IF NOT EXISTS `payment_intents` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `see_id` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '生成的id掩码',
  `user_id` int unsigned NOT NULL COMMENT '用户id',
  `subscribe_id` int unsigned NOT NULL DEFAULT '0' COMMENT '订阅id, user_subscribes表id',
  `order_id` int unsigned NOT NULL DEFAULT '0' COMMENT '订单id',
  `packages_id` int unsigned NOT NULL DEFAULT '0' COMMENT '当前支付的套餐id',
  `pay_config_id` int unsigned NOT NULL COMMENT '支付方式  1 信用卡支付',
  `type` tinyint unsigned NOT NULL COMMENT '扣款类型  1 月费 2 超额费 3 新增cdn 4 在线支付  5 线下付款',
  `price` int unsigned NOT NULL COMMENT '金额 （美分）',
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '支付状态 -2 已退款 -1支付失败 0未支付 1支付成功',
  `last_error` json DEFAULT NULL COMMENT '最后支付失败的原因',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '备注, 记录(支付 ID)',
  `excess_more` json DEFAULT NULL COMMENT '超额扣费部分数据记录',
  `created_time` int unsigned NOT NULL COMMENT '支付创建时间',
  `pay_time` int unsigned NOT NULL COMMENT '支付时间',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `user_id` (`user_id`) USING BTREE,
  KEY `idx_order_id` (`order_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='支付记录';

-- ----------------------------
-- Table structure for prom_traffic_flows
-- ----------------------------
CREATE TABLE IF NOT EXISTS `prom_traffic_flows` (
  `group_id` varchar(255) DEFAULT NULL COMMENT '分组id',
  `group_name` varchar(255) DEFAULT NULL COMMENT '分组名',
  `user_id` varchar(255) DEFAULT NULL COMMENT '用户id',
  `protocol` varchar(50) DEFAULT NULL COMMENT '协议',
  `value` double DEFAULT NULL COMMENT '流量(B)',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  KEY `idx_prom_traffic_flows_group_id` (`group_id`),
  KEY `idx_prom_traffic_flows_user_id` (`user_id`),
  KEY `idx_prom_traffic_flows_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for traffic_product_agents
-- ----------------------------
CREATE TABLE IF NOT EXISTS `traffic_product_agents` (
  `traffic_product_id` int unsigned NOT NULL DEFAULT '0' COMMENT '套餐id',
  `agent_user_id` int unsigned NOT NULL DEFAULT '0' COMMENT '代理商id',
  KEY `traffic_product_id` (`traffic_product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='套餐代理商管理';

-- ----------------------------
-- Table structure for traffic_product_area_prices
-- ----------------------------
CREATE TABLE IF NOT EXISTS `traffic_product_area_prices` (
  `traffic_product_area_price_id` int unsigned NOT NULL AUTO_INCREMENT COMMENT '表id',
  `traffic_product_id` int unsigned NOT NULL DEFAULT '0' COMMENT 'traffic_products表id, 流量包表id',
  `traffic_volume_id` int unsigned NOT NULL DEFAULT '0' COMMENT 'traffic_volumes表id, 流量包流量表id',
  `traffic_term_id` int unsigned NOT NULL DEFAULT '0' COMMENT 'traffic_terms表id, 流量包有效期表id',
  `traffic_period_id` int unsigned NOT NULL DEFAULT '0' COMMENT 'traffic_periods表id, 流量包可用时段表id',
  `price` decimal(20,3) unsigned NOT NULL DEFAULT '0.000' COMMENT '价格',
  `waf_price` decimal(20,2) unsigned NOT NULL DEFAULT '0.00' COMMENT 'waf 价格',
  `status` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '状态1启用 0禁用',
  PRIMARY KEY (`traffic_product_area_price_id`) USING BTREE,
  KEY `idx_traffic_product_id` (`traffic_product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='流量包区域价格列表';

-- ----------------------------
-- Table structure for traffic_product_dns_domains
-- ----------------------------
CREATE TABLE IF NOT EXISTS `traffic_product_dns_domains` (
  `traffic_product_dns_domain_id` int unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `traffic_product_id` int unsigned NOT NULL COMMENT '套餐ID',
  `partner_dns_domain_id` int unsigned NOT NULL COMMENT '合作私有域名ID',
  PRIMARY KEY (`traffic_product_dns_domain_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='套餐私有域名';

-- ----------------------------
-- Table structure for traffic_product_node_groups
-- ----------------------------
CREATE TABLE IF NOT EXISTS `traffic_product_node_groups` (
  `traffic_product_id` int unsigned NOT NULL COMMENT '产品 ID',
  `waf_node_group_id` bigint NOT NULL COMMENT '节点分组 ID',
  KEY `traffic_product_id` (`traffic_product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='产品节点组';

-- ----------------------------
-- Table structure for traffic_product_terms
-- ----------------------------
CREATE TABLE IF NOT EXISTS `traffic_product_terms` (
  `traffic_product_id` int unsigned NOT NULL DEFAULT '0',
  `traffic_term_id` int unsigned NOT NULL DEFAULT '0',
  KEY `idx_traffic_product_id` (`traffic_product_id`),
  KEY `idx_traffic_term_id` (`traffic_term_id`),
  KEY `unq_traffic_product_id_traffic_term_id` (`traffic_product_id`,`traffic_term_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='流量包有效期';

-- ----------------------------
-- Table structure for traffic_product_vips
-- ----------------------------
CREATE TABLE IF NOT EXISTS `traffic_product_vips` (
  `traffic_product_id` int unsigned NOT NULL DEFAULT '0' COMMENT 'traffic_products表',
  `user_id` int unsigned NOT NULL DEFAULT '0' COMMENT 'users表可购买用户',
  UNIQUE KEY `unq_traffic_product_id_user_id` (`traffic_product_id`,`user_id`) USING BTREE,
  KEY `idx_traffic_product_id` (`traffic_product_id`) USING BTREE,
  KEY `idx_ user_id` (`user_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='流量包大客户定制可购买用户';

-- ----------------------------
-- Table structure for traffic_product_volumes
-- ----------------------------
CREATE TABLE IF NOT EXISTS `traffic_product_volumes` (
  `traffic_product_id` int unsigned NOT NULL DEFAULT '0' COMMENT 'traffic_products表',
  `traffic_volume_id` int unsigned NOT NULL DEFAULT '0' COMMENT 'traffic_volumes表',
  UNIQUE KEY `unq_traffic_product_id_traffic_volume_id` (`traffic_product_id`,`traffic_volume_id`) USING BTREE,
  KEY `idx_traffic_product_id` (`traffic_product_id`) USING BTREE,
  KEY `idx_traffic_volume_id` (`traffic_volume_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='流量包流量';

-- ----------------------------
-- Table structure for traffic_products
-- ----------------------------
CREATE TABLE IF NOT EXISTS `traffic_products` (
  `traffic_product_id` int unsigned NOT NULL AUTO_INCREMENT,
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '修改时间',
  `delete_time` datetime DEFAULT NULL COMMENT '软删除',
  `name` varchar(255) NOT NULL COMMENT '流量包名称',
  `name_en` varchar(255) NOT NULL DEFAULT '' COMMENT '流量包名称，英文',
  `type` tinyint unsigned NOT NULL COMMENT ' 类型  0 官网  1 定制 2 回国加速全体  3 回国加速定制',
  `sort` int unsigned NOT NULL DEFAULT '0' COMMENT '排序',
  `status` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '状态0上架 1下架',
  `is_custom_cdn` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '是否支持自定义CDN：0不支持 1支持',
  `product_price_strategy` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '加价策略0不加价 1加价',
  `product_price_up` int unsigned NOT NULL DEFAULT '0' COMMENT '加价策略，基础上增加多少如涨30%， 填写30',
  `product_price_base` varchar(20) NOT NULL DEFAULT '' COMMENT '加价策略，按高价｜｜按低价',
  `restriction` int unsigned NOT NULL DEFAULT '0' COMMENT '限制购买次数  0 表示不限制',
  `is_renewalable` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '是否可续期; 0到期不可续期，1到期可续期',
  `max_domain_num` int unsigned NOT NULL DEFAULT '0' COMMENT '最大可加速域名数量；0为不限',
  `excess_traffic_price_type` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '超额流量价格，0跟随加价策略，1固定价格',
  `excess_traffic_fixed_price` decimal(10,0) unsigned NOT NULL DEFAULT '0' COMMENT '超额流量价格 1固定价格，单位：美分',
  `waf_price` decimal(20,2) unsigned NOT NULL DEFAULT '0.00' COMMENT 'waf超额费用   单位 美分  / 月 /域名',
  `waf_status` tinyint unsigned NOT NULL DEFAULT '0' COMMENT 'waf状态 0 关闭 1 开启',
  `fusion_max` smallint unsigned NOT NULL DEFAULT '0' COMMENT '融合最大家数  0表示全部',
  `show_cdn_detail` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '是否显示cdn详情  0 不显示  1 显示',
  `show_period` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '是否显示期数  0 否  1 是',
  `cname` varchar(255) NOT NULL DEFAULT '' COMMENT '指定cname',
  `partner_dns_domain_id` int unsigned NOT NULL DEFAULT '0' COMMENT '域名id',
  `cname_type` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '类型  1 网站组生成 2 套餐生成',
  `can_agent_buy` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '代理商是否可售 0 否 1 是',
  `universal_dns` enum('0','1') NOT NULL DEFAULT '1' COMMENT '是否支持泛域名  0 否 1 是',
  PRIMARY KEY (`traffic_product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='流量包表';

-- ----------------------------
-- Table structure for traffic_terms
-- ----------------------------
CREATE TABLE IF NOT EXISTS `traffic_terms` (
  `traffic_term_id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '名',
  `name_en` varchar(255) NOT NULL DEFAULT '' COMMENT '英文名',
  `status` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '状态0上架 1下架',
  `expiration` int unsigned NOT NULL DEFAULT '1' COMMENT '有效期值',
  `exp_unit` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '有效期单位  0 天  1 月  2 年',
  PRIMARY KEY (`traffic_term_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='流量包有效期名';

-- ----------------------------
-- Table structure for traffic_volumes
-- ----------------------------
CREATE TABLE IF NOT EXISTS `traffic_volumes` (
  `traffic_volume_id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '名',
  `volume` bigint unsigned NOT NULL DEFAULT '0' COMMENT '流量，GB单位',
  `status` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '状态0上架 1下架',
  `type` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '类型0官方，1自定义',
  PRIMARY KEY (`traffic_volume_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='流量包流量名';

-- ----------------------------
-- Table structure for user_certificates
-- ----------------------------
CREATE TABLE IF NOT EXISTS `user_certificates` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '修改时间',
  `submit_time` datetime DEFAULT NULL COMMENT '认证提交时间',
  `user_id` int unsigned NOT NULL DEFAULT '0' COMMENT '用户ID',
  `type` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '认证类型1个人认证，2企业认证',
  `status` tinyint unsigned NOT NULL COMMENT '状态 0未提交，1  认证通过 2  认证拒绝 3 审核中',
  `reason` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '备注||拒绝理由',
  `remark` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '备注||拒绝理由',
  `link_man` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '姓名||企业联系人',
  `link_region_id` int unsigned NOT NULL DEFAULT '0' COMMENT '区域||企业所在区域',
  `link_phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '联系电话',
  `link_addr` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '地址||企业办公地址',
  `cert_type` tinyint NOT NULL DEFAULT '0' COMMENT '证件类型||联系人证件类型:1身份证2军官证3香港身份证4澳门身份证5台湾身份证6台胞证7护照',
  `cert_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '证件号||联系人证件号',
  `cert_photo_front` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '证件照正面||联系人证件照',
  `cert_photo_back` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '证件照背面||联系人证件照',
  `business_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '企业名称',
  `business_cert_type` tinyint NOT NULL DEFAULT '0' COMMENT '企业证件类型1营业执照2组织机构代码证',
  `business_identity_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '企业证件号',
  `business_photo` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '营业执照扫描件',
  `optional_cert_type` tinyint NOT NULL DEFAULT '0' COMMENT '可选证件类型：1增值电信业务经营许可证 2网络文化经营许可证 3金融类经营许可批文 4医疗保健药品许可批文 5教育类经营许可批文 6新闻出版广电类许可批文',
  `optional_cert_photo` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '可选证件类型扫描件',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='用户实名认证表';

-- ----------------------------
-- Table structure for user_invoices
-- ----------------------------
CREATE TABLE IF NOT EXISTS `user_invoices` (
  `user_id` int unsigned NOT NULL DEFAULT '0',
  `business` varchar(255) NOT NULL DEFAULT '' COMMENT '公司名称',
  `address` varchar(500) NOT NULL DEFAULT '' COMMENT '公司地址',
  `man` varchar(255) NOT NULL DEFAULT '' COMMENT '联系人',
  `mobile_code` varchar(5) NOT NULL DEFAULT '86' COMMENT '手机区号',
  `mobile_number` varchar(50) NOT NULL DEFAULT '' COMMENT '手机号',
  `email` varchar(255) NOT NULL DEFAULT '' COMMENT '邮箱',
  PRIMARY KEY (`user_id`),
  CONSTRAINT `user_invoice_key_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='发票信息';

-- ----------------------------
-- Table structure for user_levels
-- ----------------------------
CREATE TABLE IF NOT EXISTS `user_levels` (
  `level_id` int unsigned NOT NULL AUTO_INCREMENT,
  `update_time` datetime DEFAULT NULL COMMENT '修改时间',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '等级名称',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '备注',
  `from` float unsigned NOT NULL DEFAULT '0' COMMENT '区间起点',
  `to` float unsigned NOT NULL DEFAULT '0' COMMENT '区间终点  0表示无穷大',
  `order` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '排序  数字越小排位越在前面',
  PRIMARY KEY (`level_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户等级表';

-- ----------------------------
-- Table structure for user_message_configs
-- ----------------------------
CREATE TABLE IF NOT EXISTS `user_message_configs` (
  `user_id` int unsigned NOT NULL,
  `type` tinyint unsigned NOT NULL COMMENT '选择告警方式  100 邮箱 010 telegram 001 短信  二进制选择',
  `email` varchar(255) NOT NULL DEFAULT '' COMMENT '邮箱',
  `telegram_token` varchar(255) NOT NULL DEFAULT '' COMMENT 'telegram 机器人token',
  `telegram` varchar(255) NOT NULL DEFAULT '' COMMENT 'telegram',
  `phone` varchar(255) NOT NULL DEFAULT '' COMMENT '手机号码',
  `config` json NOT NULL COMMENT '配置',
  `create_time` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`user_id`),
  CONSTRAINT `user_message_configs_key1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户消息通知开关配置';

-- ----------------------------
-- Table structure for user_porfile_logs
-- ----------------------------
CREATE TABLE IF NOT EXISTS `user_porfile_logs` (
  `log_id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL DEFAULT '0' COMMENT '用户id',
  `pay_config_id` int unsigned NOT NULL DEFAULT '0' COMMENT '支付id',
  `type` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '类型  0 充值  1 支付',
  `order_id` int unsigned NOT NULL DEFAULT '0' COMMENT '订单id',
  `recharge_id` int unsigned NOT NULL DEFAULT '0' COMMENT '充值id',
  `balance` bigint unsigned NOT NULL DEFAULT '0' COMMENT '当前账号余额',
  `create_time` int unsigned NOT NULL DEFAULT '0' COMMENT '创建实践',
  PRIMARY KEY (`log_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='资金流水记录';

-- ----------------------------
-- Table structure for user_porfiles
-- ----------------------------
CREATE TABLE IF NOT EXISTS `user_porfiles` (
  `user_id` int unsigned NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '个人描述',
  `console_settings` json DEFAULT NULL COMMENT '前端的个性化设置',
  `balance` bigint unsigned NOT NULL DEFAULT '0' COMMENT '余额 (分)',
  `is_novice` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '0 未使用过新手教程 1使用过新手教程',
  `extends` json NOT NULL COMMENT '扩展信息，dns_providers[$provider=>[$key=>$val]], ...',
  `google_auth_secret` varchar(50) NOT NULL DEFAULT '' COMMENT '谷歌身份验证器密钥',
  `google_auth_status` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '谷歌身份验证器绑定状态  0 未绑定  1 已绑定',
  PRIMARY KEY (`user_id`) USING BTREE,
  CONSTRAINT `fk_user_porfiles_users_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='用户其他信息表';

-- ----------------------------
-- Table structure for user_power_traffic_additionals
-- ----------------------------
CREATE TABLE IF NOT EXISTS `user_power_traffic_additionals` (
  `user_power_traffic_additional_id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_power_traffic_period_id` int unsigned NOT NULL,
  `order_id` int unsigned NOT NULL DEFAULT '0' COMMENT '订单id',
  `type` tinyint unsigned NOT NULL COMMENT '类型  1 流量 2域名',
  `status` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '状态 1 正常 2 退款',
  `num` int unsigned NOT NULL DEFAULT '1' COMMENT '数量  单位： 个（域名）| gb （流量）',
  `create_time` int unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  PRIMARY KEY (`user_power_traffic_additional_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='分期加购记录';

-- ----------------------------
-- Table structure for user_power_traffic_count_logs
-- ----------------------------
CREATE TABLE IF NOT EXISTS `user_power_traffic_count_logs` (
  `user_power_traffic_count_log_id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_power_traffics_id` int unsigned NOT NULL DEFAULT '0' COMMENT '用户流量包id',
  `user_id` int unsigned NOT NULL DEFAULT '0' COMMENT '用户id',
  `day` date NOT NULL COMMENT '记录日期',
  `used` bigint unsigned NOT NULL DEFAULT '0' COMMENT '流量 单位： byte',
  PRIMARY KEY (`user_power_traffic_count_log_id`),
  KEY `user_power_traffics_id` (`user_power_traffics_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='套餐流量每日统计表';

-- ----------------------------
-- Table structure for user_power_traffic_logs
-- ----------------------------
CREATE TABLE IF NOT EXISTS `user_power_traffic_logs` (
  `log_id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_power_traffics_id` int unsigned NOT NULL COMMENT '用户流量包id',
  `user_power_traffic_period_id` int unsigned NOT NULL DEFAULT '0' COMMENT '分期流量包id',
  `domain_id` int unsigned NOT NULL DEFAULT '0' COMMENT '域名id',
  `traffic_area_id` int unsigned NOT NULL COMMENT '区域id',
  `type` tinyint unsigned NOT NULL COMMENT '类型   0 扣除  1 修正  2 未扣除数据 3 已经补扣',
  `day` date NOT NULL COMMENT '记录日期',
  `used` bigint NOT NULL COMMENT '当前使用量 单位： byte',
  `residue` bigint NOT NULL COMMENT '剩余流量数  单位： byte',
  `used_request` int NOT NULL COMMENT '当日使用请求数  单位： 个',
  `create_time` int unsigned NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`log_id`),
  KEY `traffic_id` (`user_power_traffics_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户流量扣除记录';

-- ----------------------------
-- Table structure for user_power_traffic_message_logs
-- ----------------------------
CREATE TABLE IF NOT EXISTS `user_power_traffic_message_logs` (
  `message_id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_power_traffics_id` int unsigned NOT NULL COMMENT '流量包id',
  `user_power_traffic_period_id` int unsigned NOT NULL DEFAULT '0' COMMENT '分期流量包id',
  `type` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '类型 1、7天 2、3天 3、到期  4、50g 5、10g 6、用完',
  `create_time` int unsigned NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`message_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='流量包通知记录';

-- ----------------------------
-- Table structure for user_power_traffic_periods
-- ----------------------------
CREATE TABLE IF NOT EXISTS `user_power_traffic_periods` (
  `user_power_traffic_period_id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_power_traffics_id` int unsigned NOT NULL COMMENT '用流量包id',
  `traffic` bigint unsigned NOT NULL DEFAULT '0' COMMENT '流量总数    单位  gb',
  `buy_traffic` int unsigned NOT NULL DEFAULT '0' COMMENT '购买流量   单位 gb',
  `used_traffic` bigint unsigned NOT NULL DEFAULT '0' COMMENT '使用 流量数   单位 byte',
  `status` tinyint unsigned NOT NULL COMMENT '状态  0 未开始 1 生效   2 过期   3 用完  4 退款',
  `buy_domain` smallint unsigned NOT NULL DEFAULT '0' COMMENT '本期加购的域名数（用做记录）',
  `begin_time` int unsigned NOT NULL DEFAULT '0' COMMENT '开始时间',
  `exp_time` int unsigned NOT NULL DEFAULT '0' COMMENT '过期时间',
  `create_time` int unsigned NOT NULL COMMENT '创建时间',
  `update_time` int unsigned NOT NULL DEFAULT '0' COMMENT '修改时间',
  PRIMARY KEY (`user_power_traffic_period_id`) USING BTREE,
  KEY `user_power_traffics_id` (`user_power_traffics_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户流量包分期处理';

-- ----------------------------
-- Table structure for user_power_traffics
-- ----------------------------
CREATE TABLE IF NOT EXISTS `user_power_traffics` (
  `user_power_traffics_id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL DEFAULT '0' COMMENT '用户id',
  `order_id` int unsigned NOT NULL DEFAULT '0' COMMENT '订单id，通过这个id查询当前流量包的限制',
  `status` tinyint unsigned NOT NULL COMMENT '状态 1 生效 2 过期 3 用完 4 不能续费 5 被禁用',
  `type` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '类型 0 旧版 1 新版',
  `traffic` bigint unsigned NOT NULL DEFAULT '0' COMMENT '流量总数 单位 gb',
  `used_traffic` bigint unsigned NOT NULL DEFAULT '0' COMMENT '使用流量数 单位 byte',
  `create_time` int unsigned NOT NULL COMMENT '创建时间',
  `exp_time` int unsigned NOT NULL DEFAULT '0' COMMENT '结束时间',
  `remark` varchar(255) NOT NULL DEFAULT '' COMMENT '备注',
  `update_time` int unsigned NOT NULL COMMENT '修改时间',
  `domain_num` int unsigned NOT NULL DEFAULT '0' COMMENT '加速域名数量；0为不限',
  PRIMARY KEY (`user_power_traffics_id`) USING BTREE,
  KEY `user_id` (`user_id`) USING BTREE,
  KEY `user_power_traffics_status_index` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户流量包';

-- ----------------------------
-- Table structure for user_recharge_records
-- ----------------------------
CREATE TABLE IF NOT EXISTS `user_recharge_records` (
  `recharge_id` int unsigned NOT NULL AUTO_INCREMENT,
  `pay_order` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '订单号',
  `user_id` int unsigned NOT NULL DEFAULT '0' COMMENT '用户id',
  `trade_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '交易号',
  `pay_id` int unsigned NOT NULL DEFAULT '0' COMMENT '支付方式',
  `amount` bigint unsigned NOT NULL DEFAULT '0' COMMENT '金额 （分）',
  `status` tinyint unsigned NOT NULL COMMENT '-1 支付失败TRADE_CLOSED  0 等待支付 WAIT_BUYER_PAY， 1 交易支付成功。 TRADE_SUCCESS TRADE_FINISHED',
  `created_time` int unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  `pay_time` int unsigned NOT NULL DEFAULT '0' COMMENT '支付时间',
  `refund_time` int unsigned NOT NULL DEFAULT '0' COMMENT '退款时间',
  `rate` double(10,4) unsigned NOT NULL DEFAULT '1.0000' COMMENT '现汇买入价   1美元 = x 人民币',
  `type` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '类型  0 充值   1 在线支付',
  `order_id` int unsigned NOT NULL DEFAULT '0' COMMENT '订单id',
  `origin_amount` int unsigned NOT NULL DEFAULT '0' COMMENT '如果是后台入账，就有此值， 充值金额(分)',
  `credential_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '支付信息截图',
  `admin_user_id` bigint unsigned NOT NULL DEFAULT '0' COMMENT '后台管理员用户id',
  `pay_type` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '支付方式：1支付宝2微信支付3PayPal4信用卡支付5对公转账6其它支付',
  PRIMARY KEY (`recharge_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='充值记录';

-- ----------------------------
-- Table structure for user_waf_ids
-- ----------------------------
CREATE TABLE IF NOT EXISTS `user_waf_ids` (
  `user_id` int unsigned NOT NULL,
  `user_string` varchar(255) NOT NULL COMMENT '远程用户id',
  `waf_rule_level` tinyint unsigned NOT NULL DEFAULT '2' COMMENT '防护等级  0 宽松 1 基础 2 严格',
  `user_string_multi` varchar(255) NOT NULL DEFAULT '' COMMENT '融合cdn用户id',
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for users
-- ----------------------------
CREATE TABLE IF NOT EXISTS `users` (
  `user_id` int unsigned NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `level_id` int unsigned NOT NULL DEFAULT '0' COMMENT '等级id',
  `user_type` enum('user','proxy','sub_user') CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL DEFAULT 'user' COMMENT '用户类型：普通、代理商、子用户',
  `agent_user_id` int unsigned NOT NULL DEFAULT '0' COMMENT '代理商id',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '登录名',
  `password` varchar(255) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL COMMENT '用户密码',
  `realname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '展示名',
  `avatar` varchar(255) CHARACTER SET ascii COLLATE ascii_general_ci DEFAULT NULL COMMENT '头像',
  `role_id` int unsigned DEFAULT NULL COMMENT '用户角色',
  `created_time` int unsigned NOT NULL COMMENT '用户创建时间',
  `updated_time` int unsigned DEFAULT NULL COMMENT '更新时间',
  `lastlogin_time` int unsigned DEFAULT NULL COMMENT '最后登录时间',
  `lastlogin_ip` int unsigned DEFAULT NULL COMMENT '登录ip',
  `email` varchar(255) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL COMMENT '邮箱',
  `is_vip` tinyint DEFAULT '0' COMMENT '是否为VIP',
  `mobile_code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '手机区号',
  `mobile_number` varchar(50) CHARACTER SET ascii COLLATE ascii_general_ci DEFAULT NULL COMMENT '手机号',
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '状态 0，未激活，1，邮箱激活 2 禁用 3 手机激活 4 手机邮箱都激活',
  `sale_id` int unsigned NOT NULL DEFAULT '0' COMMENT '销售id, 对应admin_users表id',
  PRIMARY KEY (`user_id`) USING BTREE,
  KEY `fk_users_roles_1` (`role_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='用户表';

-- ----------------------------
-- Table structure for waf_apks
-- ----------------------------
CREATE TABLE IF NOT EXISTS `waf_apks` (
  `waf_apk_id` int unsigned NOT NULL AUTO_INCREMENT,
  `version` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '版本号',
  `md5` varchar(255) NOT NULL COMMENT 'md5值',
  `url` varchar(255) NOT NULL COMMENT '下载地址',
  `remark` varchar(255) NOT NULL DEFAULT '' COMMENT '备注',
  `create_time` int unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  PRIMARY KEY (`waf_apk_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='安装包管理';

-- ----------------------------
-- Table structure for waf_apps
-- ----------------------------
CREATE TABLE IF NOT EXISTS `waf_apps` (
  `waf_id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL DEFAULT '0' COMMENT '用户id',
  `waf_cc_rule_group_id` int unsigned NOT NULL DEFAULT '0' COMMENT 'cc规则id',
  `domain_group_id` int unsigned NOT NULL DEFAULT '0' COMMENT '域名组id 表示一个应用是组类型的',
  `group_id` varchar(255) NOT NULL DEFAULT '' COMMENT '远程组id',
  `name` varchar(255) NOT NULL COMMENT '应用名称',
  `scheme` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '回源协议',
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '状态',
  `auto_cc_switch` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '自动cc切换状态',
  `create_time` int unsigned NOT NULL COMMENT '创建时间',
  `update_time` int unsigned NOT NULL COMMENT '修改时间',
  PRIMARY KEY (`waf_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='waf应用管理';

-- ----------------------------
-- Table structure for waf_area_regions
-- ----------------------------
CREATE TABLE IF NOT EXISTS `waf_area_regions` (
  `waf_area_id` int unsigned NOT NULL,
  `region_id` int unsigned NOT NULL,
  KEY `id` (`waf_area_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='区域管理表';

-- ----------------------------
-- Table structure for waf_areas
-- ----------------------------
CREATE TABLE IF NOT EXISTS `waf_areas` (
  `waf_area_id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL COMMENT '中文名',
  `name_en` varchar(255) NOT NULL COMMENT '英文名',
  PRIMARY KEY (`waf_area_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='国外大区';

-- ----------------------------
-- Table structure for waf_block_htmls
-- ----------------------------
CREATE TABLE IF NOT EXISTS `waf_block_htmls` (
  `user_id` int unsigned NOT NULL,
  `block_html` text COMMENT 'waf自定义阻挡html页面',
  `create_time` int unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  `update_time` int unsigned NOT NULL DEFAULT '0' COMMENT '修改时间',
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户自定义拦截模板';

-- ----------------------------
-- Table structure for waf_blockade_cities
-- ----------------------------
CREATE TABLE IF NOT EXISTS `waf_blockade_cities` (
  `blockade_id` int unsigned NOT NULL,
  `region_id` int unsigned NOT NULL COMMENT '城市id',
  `type` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '类型  0 国内 1 国外',
  KEY `block_id` (`blockade_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='封禁的城市列表';

-- ----------------------------
-- Table structure for waf_blockade_domains
-- ----------------------------
CREATE TABLE IF NOT EXISTS `waf_blockade_domains` (
  `blockade_domain_id` int unsigned NOT NULL AUTO_INCREMENT,
  `domain` varchar(255) NOT NULL COMMENT '域名',
  `type` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '类型  0 普通域名  1 泛域名',
  `create_time` int unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  PRIMARY KEY (`blockade_domain_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='封禁域名';

-- ----------------------------
-- Table structure for waf_blockades
-- ----------------------------
CREATE TABLE IF NOT EXISTS `waf_blockades` (
  `blockade_id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL DEFAULT '0' COMMENT '用户id',
  `waf_id` int unsigned NOT NULL DEFAULT '0' COMMENT '为0 表示所有',
  `waf_transmit_id` int unsigned NOT NULL DEFAULT '0' COMMENT '转发id',
  `policy_id` varchar(255) NOT NULL DEFAULT '' COMMENT '远程id',
  `create_time` int unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  `update_time` int unsigned NOT NULL DEFAULT '0' COMMENT '修改时间',
  PRIMARY KEY (`blockade_id`) USING BTREE,
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='区域封禁';

-- ----------------------------
-- Table structure for waf_cc_filters
-- ----------------------------
CREATE TABLE IF NOT EXISTS `waf_cc_filters` (
  `waf_cc_filter_id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL DEFAULT '0' COMMENT '用户id',
  `name` varchar(255) NOT NULL COMMENT '名称',
  `remark` varchar(255) NOT NULL COMMENT '备注',
  `type` smallint unsigned NOT NULL COMMENT '类型  0、请求速率  1、5秒盾 2、302跳转 3、浏览器识别',
  `time` int unsigned NOT NULL DEFAULT '0' COMMENT '时间范围  （s）',
  `max_fail_num` int unsigned NOT NULL COMMENT '最大失败次数 | 最大请求数',
  `one_num` int unsigned NOT NULL DEFAULT '0' COMMENT '单个url 最大次数',
  `status` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '状态  0 禁用  1 启用',
  `create_time` int unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  `update_time` int unsigned NOT NULL DEFAULT '0' COMMENT '修改时间',
  PRIMARY KEY (`waf_cc_filter_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='cc规则 过滤器';

-- ----------------------------
-- Table structure for waf_cc_matchers
-- ----------------------------
CREATE TABLE IF NOT EXISTS `waf_cc_matchers` (
  `waf_cc_matcher_id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL DEFAULT '0' COMMENT '用户id',
  `name` varchar(255) NOT NULL COMMENT '名称',
  `remark` varchar(255) NOT NULL COMMENT '备注',
  `status` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '状态  0 禁用  1 启用',
  `rules` json NOT NULL COMMENT '规则值',
  `create_time` int unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  `update_time` int unsigned NOT NULL DEFAULT '0' COMMENT '修改时间',
  PRIMARY KEY (`waf_cc_matcher_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='cc  匹配器规则';

-- ----------------------------
-- Table structure for waf_cc_policies
-- ----------------------------
CREATE TABLE IF NOT EXISTS `waf_cc_policies` (
  `waf_cc_policy_id` int unsigned NOT NULL AUTO_INCREMENT,
  `waf_id` int unsigned NOT NULL COMMENT '应用id',
  `waf_cc_rule_id` int unsigned NOT NULL COMMENT '规则id',
  `more` json DEFAULT NULL,
  PRIMARY KEY (`waf_cc_policy_id`),
  KEY `waf_id` (`waf_id`),
  KEY `waf_cc_rule_id` (`waf_cc_rule_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='cc规则远程id';

-- ----------------------------
-- Table structure for waf_cc_policies_logs
-- ----------------------------
CREATE TABLE IF NOT EXISTS `waf_cc_policies_logs` (
  `waf_cc_policies_log_id` int unsigned NOT NULL AUTO_INCREMENT,
  `policies` varchar(255) NOT NULL DEFAULT '' COMMENT '远程id',
  `waf_cc_rule_group_id` int unsigned NOT NULL DEFAULT '0' COMMENT 'cc分组规则id',
  `group_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '分组名称',
  `waf_cc_matcher_id` int unsigned NOT NULL DEFAULT '0' COMMENT '匹配器id',
  `matcher_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '匹配器 名称',
  `waf_cc_filter_id` int unsigned NOT NULL DEFAULT '0' COMMENT '过滤器id',
  `filter_name_1` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '过滤器名称 1 ',
  `waf_cc_filter_2_id` int unsigned NOT NULL DEFAULT '0' COMMENT '过滤器id2',
  `filter_name_2` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '过滤器名称 2',
  `create_time` int unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  PRIMARY KEY (`waf_cc_policies_log_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用于日志查询ccid 对于的匹配器名称';

-- ----------------------------
-- Table structure for waf_cc_rule_group_users
-- ----------------------------
CREATE TABLE IF NOT EXISTS `waf_cc_rule_group_users` (
  `waf_cc_rule_group_id` int unsigned NOT NULL COMMENT '规则分组id',
  `user_id` int unsigned NOT NULL COMMENT '用户id',
  KEY `waf_cc_rule_group_id` (`waf_cc_rule_group_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='指定哪些用户可以使用';

-- ----------------------------
-- Table structure for waf_cc_rule_groups
-- ----------------------------
CREATE TABLE IF NOT EXISTS `waf_cc_rule_groups` (
  `waf_cc_rule_group_id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL COMMENT '用户id   0 表示系统',
  `name` varchar(255) NOT NULL COMMENT '名称',
  `remark` varchar(255) NOT NULL COMMENT '备注',
  `order` smallint unsigned NOT NULL DEFAULT '0' COMMENT '排序',
  `status` enum('0','1') NOT NULL DEFAULT '1' COMMENT '状态 0 禁用 1 启用',
  `type` enum('0','1') NOT NULL DEFAULT '0' COMMENT '是否指定用户  0 否 1 是',
  `display` enum('0','1') NOT NULL DEFAULT '1' COMMENT '是否显示  0 否 1 是',
  `create_time` int unsigned NOT NULL COMMENT '创建时间',
  `update_time` int unsigned NOT NULL COMMENT '修改时间',
  PRIMARY KEY (`waf_cc_rule_group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='cc  规则 组';

-- ----------------------------
-- Table structure for waf_cc_rules
-- ----------------------------
CREATE TABLE IF NOT EXISTS `waf_cc_rules` (
  `waf_cc_rule_id` int unsigned NOT NULL AUTO_INCREMENT,
  `waf_cc_rule_group_id` int unsigned NOT NULL COMMENT '分组id',
  `waf_cc_matcher_id` int unsigned NOT NULL DEFAULT '0' COMMENT '匹配器id',
  `waf_cc_filter_id` int unsigned NOT NULL DEFAULT '0' COMMENT '过滤器id  1',
  `waf_cc_filter_id2` int unsigned NOT NULL DEFAULT '0' COMMENT '过滤器id  2',
  `action` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '动作',
  `status` enum('0','1') NOT NULL DEFAULT '1' COMMENT '状态  1 启用  0 禁用',
  `time` int unsigned NOT NULL DEFAULT '0' COMMENT '封禁时间 单位 秒  （只存秒数）',
  `time_type` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '时间类型  0 秒 1 分 2 小时 3 天',
  `block_ip_type` tinyint unsigned COMMENT '1 client ip, 2 remote ip',
  PRIMARY KEY (`waf_cc_rule_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='cc 规则';

-- ----------------------------
-- Table structure for waf_cc_toggle_logs
-- ----------------------------
CREATE TABLE IF NOT EXISTS `waf_cc_toggle_logs` (
  `waf_cc_toggle_log_id` int unsigned NOT NULL AUTO_INCREMENT,
  `waf_id` int unsigned NOT NULL DEFAULT '0' COMMENT '应用id',
  `5xxqps` int unsigned NOT NULL DEFAULT '0' COMMENT '5xxqps',
  `qps` int unsigned NOT NULL DEFAULT '0' COMMENT 'qps',
  `waf_cc_rule_group_id` int unsigned NOT NULL DEFAULT '0' COMMENT '规则组id',
  `action` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '动作 1 切换 0 切回',
  `create_time` int unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  PRIMARY KEY (`waf_cc_toggle_log_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='cc切换日志';

-- ----------------------------
-- Table structure for waf_ip_blocks
-- ----------------------------
CREATE TABLE IF NOT EXISTS `waf_ip_blocks` (
  `waf_ip_block_id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL DEFAULT '0',
  `ip` varchar(255) NOT NULL DEFAULT '' COMMENT '封禁ip',
  `group_id` varchar(255) NOT NULL DEFAULT '' COMMENT '分组id',
  `request_ids` json NOT NULL COMMENT '日志的id值',
  `status` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '状态 0 封禁 1 解封',
  `block_type` tinyint unsigned COMMENT '1 四层 2 七层',
  `policy_id` varchar(255) COMMENT '策略id',
  `last_start_time` int unsigned NOT NULL DEFAULT '0' COMMENT '最后开始封禁的时间',
  `last_end_time` int unsigned NOT NULL DEFAULT '0' COMMENT '最后封禁结束时间',
  PRIMARY KEY (`waf_ip_block_id`),
  KEY `ip` (`ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='当前封禁ip列表';

-- ----------------------------
-- Table structure for waf_ip_rule_ips
-- ----------------------------
CREATE TABLE IF NOT EXISTS `waf_ip_rule_ips` (
  `ip_id` int unsigned NOT NULL DEFAULT '0',
  `ip` varchar(255) NOT NULL COMMENT 'ip值',
  KEY `ip_id` (`ip_id`),
  CONSTRAINT `ip` FOREIGN KEY (`ip_id`) REFERENCES `waf_ip_rules` (`ip_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='ip规则对应的ip';

-- ----------------------------
-- Table structure for waf_ip_rules
-- ----------------------------
CREATE TABLE IF NOT EXISTS `waf_ip_rules` (
  `ip_id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL DEFAULT '0' COMMENT '用户id',
  `waf_id` int unsigned NOT NULL DEFAULT '0' COMMENT 'waf',
  `policy_id` varchar(255) NOT NULL DEFAULT '' COMMENT '远程id',
  `type` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '类型  0 黑名单  1 白名单',
  `remark` varchar(255) NOT NULL COMMENT '备注',
  `create_time` int unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  `update_time` int unsigned NOT NULL DEFAULT '0' COMMENT '修改时间',
  PRIMARY KEY (`ip_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='ip策略';

-- ----------------------------
-- Table structure for waf_ip_unseal_logs
-- ----------------------------
CREATE TABLE IF NOT EXISTS `waf_ip_unseal_logs` (
  `waf_ip_unseal_log_id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL DEFAULT '0' COMMENT '用户id',
  `ip` int unsigned NOT NULL COMMENT '解封的ip',
  `create_time` int unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  PRIMARY KEY (`waf_ip_unseal_log_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='解封记录';

-- ----------------------------
-- Table structure for waf_malicious_traffics
-- ----------------------------
CREATE TABLE IF NOT EXISTS `waf_malicious_traffics` (
  `waf_malicious_traffic_id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL DEFAULT '0' COMMENT '用户id',
  `domain_group_id` int unsigned NOT NULL DEFAULT '0' COMMENT '分组id',
  `policy_id` varchar(255) NOT NULL DEFAULT '' COMMENT '远程waf id',
  `cycle` int unsigned NOT NULL DEFAULT '1' COMMENT '监控周期 单位 秒',
  `type` tinyint unsigned NOT NULL COMMENT '类型 0 单ip流量 1 单ip次数 2 404 3 单域名请求',
  `max_value` int unsigned NOT NULL COMMENT '计数值  单位  个| Mb',
  `block_duration` int unsigned NOT NULL DEFAULT '0' COMMENT '封禁时间  单位 秒',
  `is_enabled` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '是否启用  0 停用  1 启用',
  `block_ip_type` tinyint unsigned COMMENT '1 client ip, 2 remote ip',
  `create_time` int unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  `update_time` int unsigned NOT NULL DEFAULT '0' COMMENT '修改时间',
  PRIMARY KEY (`waf_malicious_traffic_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='恶意流量策略';

-- ----------------------------
-- Table structure for waf_node_certs
-- ----------------------------
CREATE TABLE IF NOT EXISTS `waf_node_certs` (
  `waf_node_cert_id` int unsigned NOT NULL AUTO_INCREMENT,
  `waf_node_id` int unsigned NOT NULL,
  `type` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '类型 0 系统签发  1 用户上传',
  `institution` varchar(255) NOT NULL DEFAULT '' COMMENT '机构',
  `status` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '状态  0 待签发 1 已签发',
  `use_status` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '使用状态 0 已禁用  1 启用',
  `waf_cert_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '远程证书id',
  `error` varchar(255) NOT NULL DEFAULT '' COMMENT '报错',
  `from_time` int unsigned NOT NULL DEFAULT '0' COMMENT '开始时间',
  `to_time` int unsigned NOT NULL DEFAULT '0' COMMENT '结束时间',
  PRIMARY KEY (`waf_node_cert_id`) USING BTREE,
  KEY `waf_node_cert_id1` (`waf_node_id`),
  CONSTRAINT `waf_node_cert_key1` FOREIGN KEY (`waf_node_id`) REFERENCES `waf_nodes` (`waf_node_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='证书列表';

-- ----------------------------
-- Table structure for waf_node_groups
-- ----------------------------
CREATE TABLE IF NOT EXISTS `waf_node_groups` (
  `waf_node_group_id` int NOT NULL AUTO_INCREMENT,
  `b_id` bigint NOT NULL DEFAULT '0' COMMENT '备用组 ID',
  `group_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '分组名',
  `cname_type` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '类型 1:cname 3:ip+端口模式 4:四层转发',
  `switch_type` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '是否启用自动切换 0:否 1:是',
  `load` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '负载数据',
  PRIMARY KEY (`waf_node_group_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='WAF节点分组';

-- ----------------------------
-- Table structure for waf_node_lines
-- ----------------------------
CREATE TABLE IF NOT EXISTS `waf_node_lines` (
  `waf_node_line_id` int unsigned NOT NULL AUTO_INCREMENT,
  `waf_node_id` int unsigned NOT NULL DEFAULT '0' COMMENT '节点id',
  `code` varchar(255) NOT NULL DEFAULT '' COMMENT '线路码',
  `name` varchar(255) NOT NULL DEFAULT '' COMMENT '名称',
  PRIMARY KEY (`waf_node_line_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='阿里云节点线路';

-- ----------------------------
-- Table structure for waf_node_logs
-- ----------------------------
CREATE TABLE IF NOT EXISTS `waf_node_logs` (
  `node_log_id` int unsigned NOT NULL AUTO_INCREMENT,
  `waf_node_group_id` int unsigned NOT NULL DEFAULT '0' COMMENT '分组id',
  `admin_id` int unsigned NOT NULL DEFAULT '0' COMMENT '管理员id   0 为 系统',
  `type` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '类型 0 系统切换 1 人工切换',
  `old_ip` int unsigned NOT NULL DEFAULT '0' COMMENT '旧ip',
  `new_ip` int unsigned NOT NULL COMMENT '新ip',
  `load` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '旧机器负载 %',
  `bandwidth` double(10,2) unsigned NOT NULL DEFAULT '0.00' COMMENT '旧机器带宽',
  `remark` varchar(255) NOT NULL DEFAULT '' COMMENT '切换原因',
  `create_time` int unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  PRIMARY KEY (`node_log_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='节点切换日志';

-- ----------------------------
-- Table structure for waf_node_monitor_to_childs
-- ----------------------------
CREATE TABLE IF NOT EXISTS `waf_node_monitor_to_childs` (
  `waf_node_monitor_to_child_id` int unsigned NOT NULL AUTO_INCREMENT,
  `waf_node_monitor_id` int unsigned NOT NULL DEFAULT '0' COMMENT '监控节点id',
  `waf_node_id` int unsigned NOT NULL DEFAULT '0' COMMENT '被监控的主节点id',
  PRIMARY KEY (`waf_node_monitor_to_child_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='监控节点和子节点关系表';

-- ----------------------------
-- Table structure for waf_node_toggles
-- ----------------------------
CREATE TABLE IF NOT EXISTS `waf_node_toggles` (
  `waf_node_toggle_id` int unsigned NOT NULL AUTO_INCREMENT,
  `old_waf_node_id` int unsigned NOT NULL COMMENT '旧节点id',
  `waf_node_group_id` int unsigned NOT NULL DEFAULT '0' COMMENT '旧的分组id',
  `new_waf_node_id` int unsigned NOT NULL COMMENT '新增节点id',
  `create_time` int unsigned NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`waf_node_toggle_id`),
  KEY `old_waf_node_id` (`old_waf_node_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='waf节点自动切换记录';

-- ----------------------------
-- Table structure for waf_nodes
-- ----------------------------
CREATE TABLE IF NOT EXISTS `waf_nodes` (
  `waf_node_id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL COMMENT '区域名称，中文',
  `name_en` varchar(255) NOT NULL COMMENT '区域名称，英文',
  `is_d_monitor` enum('0','1') NOT NULL DEFAULT '0' COMMENT '是否为默认监控 0 否 1 是',
  `region` varchar(255) NOT NULL DEFAULT '' COMMENT '通关ip查询到的地址',
  `type` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '类型  0 域名  1 ip',
  `ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '节点ip 或者 域名',
  `ip_type` tinyint unsigned NOT NULL DEFAULT '1' COMMENT 'IP状态  0 停用  1 启用',
  `waf_node_group_id` int unsigned NOT NULL DEFAULT '1' COMMENT 'WAF节点分组ID，默认1，为默认分组',
  `waf_node_p_id` int unsigned NOT NULL DEFAULT '0' COMMENT '父级id',
  `remote_id` varchar(255) NOT NULL DEFAULT '' COMMENT '远程监控策略id',
  `cname_type` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '类型  1 网站组生成 2 套餐生成 3 ip+端口模式 4 四层转发',
  `waf_apk_id` int unsigned NOT NULL DEFAULT '0' COMMENT '设置安装包',
  `config_status` tinyint unsigned NOT NULL DEFAULT '2' COMMENT '配置状态 0 已提交  1 配置中  2 配置成功',
  `log_adress` varchar(255) NOT NULL DEFAULT '' COMMENT '日志地址',
  `is_scdn` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '是否为SCDN，1是，0否',
  `node_type` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '节点类型  0 边缘节点 1 管理节点  2 监控节点',
  `remark` text COMMENT '备注',
  `version` varchar(50) NOT NULL DEFAULT '1.0.0' COMMENT '版本数据',
  `status` tinyint unsigned NOT NULL COMMENT '状态，1 上线， 0 手动下线  2 系统下线',
  `create_time` int unsigned NOT NULL COMMENT '创建时间',
  `online_time` int unsigned NOT NULL DEFAULT '0' COMMENT '上线时间',
  `update_time` int unsigned NOT NULL COMMENT '修改时间',
  `cpu_percent` decimal(10,2) unsigned NOT NULL DEFAULT '0.00' COMMENT 'cpu_percent',
  `cpu_1` decimal(10,2) unsigned NOT NULL DEFAULT '0.00' COMMENT 'cpu_1',
  `cpu_5` decimal(10,2) unsigned NOT NULL DEFAULT '0.00' COMMENT 'cpu_5',
  `cpu_15` decimal(10,2) unsigned NOT NULL DEFAULT '0.00' COMMENT 'cpu_15',
  `mem_ratio` decimal(10,2) unsigned NOT NULL DEFAULT '0.00' COMMENT '内存',
  `connections` int unsigned NOT NULL DEFAULT '0' COMMENT '连接数',
  `alive` tinyint DEFAULT NULL COMMENT '存活/心跳状态，1 正常 2 异常',
  `last_heartbeat_time` timestamp NULL DEFAULT NULL COMMENT '最后心跳时间',
  `metrics_port` int DEFAULT '0' COMMENT '指标端口',
  `ttyd_url` varchar(255) DEFAULT '' COMMENT '终端URL',
  `version_updated_at` TIMESTAMP NULL DEFAULT NULL COMMENT '版本更新时间',
  `last_config_synced_at` TIMESTAMP NULL DEFAULT NULL COMMENT '最后配置同步时间',
  `git_config_version` VARCHAR(255) COMMENT 'Git 配置版本提交号',
  `device_id` VARCHAR(255) COMMENT '节点设备ID',
  `latest_ip` VARCHAR(255) COMMENT '最新上报的 IP',
  PRIMARY KEY (`waf_node_id`),
  KEY `idx_waf_nodes_device_id` (`device_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='WAF节点区域';

-- ----------------------------
-- Table structure for waf_rule_defaults
-- ----------------------------
CREATE TABLE IF NOT EXISTS `waf_rule_defaults` (
  `waf_default_id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL DEFAULT '0' COMMENT '用户id',
  `app_id` varchar(255) NOT NULL COMMENT '远程id',
  `app_str` varchar(255) NOT NULL COMMENT '阻止保存的id值',
  `status` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '状态 0 关闭 1 开启',
  PRIMARY KEY (`waf_default_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='waf默认阻止规则';

-- ----------------------------
-- Table structure for waf_rule_ids
-- ----------------------------
CREATE TABLE IF NOT EXISTS `waf_rule_ids` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `waf_rule_id` int unsigned NOT NULL COMMENT '规则id',
  `waf_id` int unsigned NOT NULL COMMENT '应用id',
  `rule_string` varchar(255) NOT NULL COMMENT '远程id',
  `custom_string` varchar(255) NOT NULL DEFAULT '' COMMENT '自定义id',
  PRIMARY KEY (`id`),
  KEY `waf_rule_id` (`waf_rule_id`),
  CONSTRAINT `waf_rule_id` FOREIGN KEY (`waf_rule_id`) REFERENCES `waf_rules` (`waf_rule_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='规则对应的远程id值';

-- ----------------------------
-- Table structure for waf_rules
-- ----------------------------
CREATE TABLE IF NOT EXISTS `waf_rules` (
  `waf_rule_id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL COMMENT '用户id',
  `app_type` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '应用类型 0 融合 1 安全  ',
  `waf_id` int unsigned NOT NULL DEFAULT '0' COMMENT '应用 id  0 表示所有',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '名称',
  `vuln_id` smallint unsigned NOT NULL DEFAULT '100' COMMENT '漏洞类型',
  `action` smallint unsigned NOT NULL COMMENT '动作',
  `check_items` json NOT NULL COMMENT '检查点 [{ check_point: 2, operation: 4, regex_policy: "10"}]',
  `status` tinyint unsigned NOT NULL COMMENT '状态  0 停用  1 启用 3 禁用',
  `rule_string` varchar(255) NOT NULL DEFAULT '' COMMENT '远程id',
  `create_time` int unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  `update_time` int unsigned NOT NULL DEFAULT '0' COMMENT '修改时间',
  PRIMARY KEY (`waf_rule_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='waf 规则配置';

-- ----------------------------
-- Table structure for waf_transmit_acls
-- ----------------------------
CREATE TABLE IF NOT EXISTS `waf_transmit_acls` (
  `waf_transmit_acl_id` int unsigned NOT NULL AUTO_INCREMENT,
  `waf_transmit_id` int unsigned NOT NULL DEFAULT '0' COMMENT '四层转发id',
  `val` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '值',
  `type` tinyint unsigned NOT NULL COMMENT '行为 0 放行 1 阻止',
  `policy_id` varchar(255) NOT NULL DEFAULT '' COMMENT '远程id',
  PRIMARY KEY (`waf_transmit_acl_id`),
  KEY `waf_transmit_id` (`waf_transmit_id`),
  CONSTRAINT `waf_transmit_acl_key1` FOREIGN KEY (`waf_transmit_id`) REFERENCES `waf_transmits` (`waf_transmit_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='监听端口';

-- ----------------------------
-- Table structure for waf_transmit_node_ports
-- ----------------------------
CREATE TABLE IF NOT EXISTS `waf_transmit_node_ports` (
  `waf_transmit_node_port_id` int unsigned NOT NULL AUTO_INCREMENT,
  `waf_transmit_id` int unsigned NOT NULL DEFAULT '0' COMMENT '转发id',
  `domain_group_id` int unsigned NOT NULL DEFAULT '0' COMMENT '分组id',
  `waf_node_id` int unsigned NOT NULL DEFAULT '0' COMMENT '节点id',
  `port` smallint unsigned NOT NULL DEFAULT '0' COMMENT '端口',
  PRIMARY KEY (`waf_transmit_node_port_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='记录转发已经使用的端口';

-- ----------------------------
-- Table structure for waf_transmit_origins
-- ----------------------------
CREATE TABLE IF NOT EXISTS `waf_transmit_origins` (
  `waf_transmit_origin_id` int unsigned NOT NULL AUTO_INCREMENT,
  `waf_transmit_id` int unsigned NOT NULL DEFAULT '0' COMMENT '四层转发id',
  `val` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '值',
  `port` smallint unsigned NOT NULL DEFAULT '0' COMMENT '端口',
  `weight` tinyint unsigned NOT NULL DEFAULT '5' COMMENT '权重',
  PRIMARY KEY (`waf_transmit_origin_id`),
  KEY `waf_transmit_origin_key1` (`waf_transmit_id`),
  CONSTRAINT `waf_transmit_origin_key1` FOREIGN KEY (`waf_transmit_id`) REFERENCES `waf_transmits` (`waf_transmit_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='四层转发源站';

-- ----------------------------
-- Table structure for waf_transmit_ports
-- ----------------------------
CREATE TABLE IF NOT EXISTS `waf_transmit_ports` (
  `waf_transmit_port_id` int unsigned NOT NULL AUTO_INCREMENT,
  `waf_transmit_id` int unsigned NOT NULL DEFAULT '0' COMMENT '四层转发id',
  `port` smallint unsigned NOT NULL DEFAULT '0' COMMENT '端口',
  `type` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '类型 0 tcp 1 udp',
  PRIMARY KEY (`waf_transmit_port_id`),
  KEY `waf_transmit_port_key1` (`waf_transmit_id`),
  CONSTRAINT `waf_transmit_port_key1` FOREIGN KEY (`waf_transmit_id`) REFERENCES `waf_transmits` (`waf_transmit_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='监听端口';

-- ----------------------------
-- Table structure for waf_transmits
-- ----------------------------
CREATE TABLE IF NOT EXISTS `waf_transmits` (
  `waf_transmit_id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL DEFAULT '0' COMMENT '用户ID',
  `domain_id` int unsigned NOT NULL DEFAULT '0' COMMENT '域名ID',
  `domain_group_id` int unsigned NOT NULL DEFAULT '0' COMMENT '分组ID',
  `agent_user_id` int unsigned NOT NULL DEFAULT '0' COMMENT '代理商ID',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '组名称',
  `group_id` varchar(255) NOT NULL DEFAULT '' COMMENT 'waf分组ID',
  `status` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '是否启用组CNAME，1启用，0不启用',
  `acl` tinyint unsigned NOT NULL DEFAULT '0' COMMENT 'ACL行为，0放行，1阻止',
  `acl_policy_id` varchar(255) NOT NULL DEFAULT '' COMMENT '默认ACL规则远程ID',
  `blockade` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '区域封禁，0停用，1启用',
  `user_power_traffics_id` int unsigned NOT NULL DEFAULT '0' COMMENT '套餐ID',
  `create_time` int unsigned NOT NULL COMMENT '创建时间',
  `update_time` int unsigned NOT NULL COMMENT '更新时间',
  `weight_enabled` tinyint unsigned DEFAULT '0' COMMENT '启用权重 0 未启用 1 启用',
  PRIMARY KEY (`waf_transmit_id`),
  KEY `waf_transmits_user_power_traffics_id_index` (`user_power_traffics_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='四层转发';

-- ----------------------------
-- Table structure for app_delayed_messages
-- ----------------------------
CREATE TABLE IF NOT EXISTS `app_delayed_messages` (
    `id`          bigint unsigned auto_increment primary key,
    `type`        varchar(50) not null comment '类型: dns, cache, back',
    `message`     json        not null comment '消息内容',
    `executed_at` datetime    not null comment '执行时间',
    `created_at`  datetime    not null comment '创建时间',
    KEY `idx_app_delayed_messages_executed_at` (`executed_at`)
);

-- ----------------------------
-- Table structure for tmp_dns_records
-- ----------------------------
CREATE TABLE IF NOT EXISTS `tmp_dns_records` (
    `id`         int unsigned auto_increment primary key,
    `provider`   tinyint unsigned not null comment '提供商',
    `data`       json             not null comment '数据',
    `created_at` datetime         not null comment '创建时间',
    `expired_at` datetime         null comment '过期时间',
    KEY `idx_tmp_dns_records_expired_at` (`expired_at`)
);

-- ----------------------------
-- Table structure for domain_group_http_headers
-- ----------------------------
CREATE TABLE IF NOT EXISTS `domain_group_http_headers` (
    `id`              int unsigned auto_increment primary key,
    `domain_group_id` int unsigned                                not null comment '网站组ID',
    `operation_type`  enum ('add', 'delete', 'modify', 'replace') not null comment '操作类型：add,delete,modify,replace',
    `key`             varchar(255)                                not null comment 'header键名',
    `value`           text                                        null comment 'header值',
    `is_custom`       tinyint unsigned      default '0'           not null comment '是否自定义：0否 1是',
    `allow_duplicate` tinyint unsigned      default '0'           not null comment '是否允许重复：0否 1是（用于添加操作）',
    `match_regex`     varchar(255)          default ''            not null comment '匹配正则表达式（用于替换操作）',
    `match_rule`      enum ('all', 'first') default 'all'         not null comment '匹配规则：all全部 first第一条（用于替换操作）',
    `created_at`      datetime(3)                                 not null comment '创建时间',
    `updated_at`      datetime(3)                                 not null comment '更新时间',
    `status`          tinyint unsigned      default '0'           not null comment '状态：0配置中 1配置成功 2配置失败 3删除中',
    `error`           text                                        null comment '错误信息'
);

-- ----------------------------
-- Table structure for monitor_nodes
-- ----------------------------
CREATE TABLE IF NOT EXISTS `monitor_nodes` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `ip` varchar(255) NOT NULL COMMENT 'IP地址',
  `region` varchar(255) DEFAULT NULL COMMENT '所在地区',
  `heartbeat` bigint DEFAULT NULL COMMENT '心跳状态',
  `last_heartbeat_time` datetime(3) DEFAULT NULL COMMENT '最后心跳时间',
  `ssh_port` bigint DEFAULT NULL COMMENT 'SSH端口',
  `ssh_username` varchar(500) DEFAULT NULL COMMENT 'SSH用户名(加密)',
  `ssh_password` varchar(500) DEFAULT NULL COMMENT 'SSH密码(加密)',
  `service_status` bigint DEFAULT NULL COMMENT '远程服务状态',
  `service_log` text COMMENT '远程服务日志',
  `created_at` datetime(3) DEFAULT NULL COMMENT '添加时间',
  `updated_at` datetime(3) DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_heartbeat` (`heartbeat`),
  KEY `idx_service_status` (`service_status`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='监控节点表';

-- ----------------------------
-- Table structure for monitor_node_settings
-- ----------------------------
CREATE TABLE IF NOT EXISTS `monitor_node_settings` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `frequency` bigint unsigned DEFAULT NULL COMMENT '监控频次，单位为秒',
  `timeout` bigint unsigned DEFAULT NULL COMMENT '异常定义：响应时间大于 n 秒',
  `alert_condition_node_count` bigint unsigned DEFAULT NULL COMMENT '告警条件：大于 n 个节点监测到',
  `alert_condition_continuous_count` bigint unsigned DEFAULT NULL COMMENT '告警条件：连续 n 次异常',
  `alert_switch` tinyint(1) DEFAULT NULL COMMENT '告警通知开关',
  `task_switch` tinyint(1) DEFAULT NULL COMMENT '任务状态开关',
  `created_at` datetime(3) DEFAULT NULL COMMENT '添加时间',
  `updated_at` datetime(3) DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_task_switch` (`task_switch`),
  KEY `idx_alert_switch` (`alert_switch`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='监控节点设置表';

-- ----------------------------
-- Table structure for monitor_node_setting_groups
-- ----------------------------
CREATE TABLE IF NOT EXISTS `monitor_node_setting_groups` (
  `monitor_node_setting_id` bigint unsigned NOT NULL COMMENT '监控设置id',
  `waf_node_group_id` bigint unsigned NOT NULL COMMENT '集群id',
  PRIMARY KEY (`monitor_node_setting_id`,`waf_node_group_id`),
  KEY `idx_setting_id` (`monitor_node_setting_id`),
  KEY `idx_group_id` (`waf_node_group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='监控节点设置与集群关联表';

-- ----------------------------
-- Table structure for monitor_node_logs
-- ----------------------------
CREATE TABLE IF NOT EXISTS `monitor_node_logs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `monitor_node_ip` varchar(255) DEFAULT NULL COMMENT '监控节点IP',
  `monitor_node_region` varchar(255) DEFAULT NULL COMMENT '监控节点地区',
  `node_ip` varchar(255) NOT NULL COMMENT '被监控节点IP',
  `response_time` bigint unsigned DEFAULT NULL COMMENT '响应时间，单位为毫秒',
  `probe_time` datetime(3) DEFAULT NULL COMMENT '发起探测时间',
  `result` bigint DEFAULT NULL COMMENT '结果',
  `created_at` datetime(3) DEFAULT NULL COMMENT '添加时间',
  `updated_at` datetime(3) DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_monitor_node_ip` (`monitor_node_ip`),
  KEY `idx_node_ip` (`node_ip`),
  KEY `idx_probe_time` (`probe_time`),
  KEY `idx_result` (`result`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='监控节点日志表';

-- ----------------------------
-- Table structure for waf_default_config
-- ----------------------------
CREATE TABLE IF NOT EXISTS `waf_default_config` (
  `key` varchar(100) NOT NULL COMMENT '配置名',
  `value` text COMMENT '配置值，可以是json',
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='waf默认配置表';

-- ----------------------------
-- Table structure for waf_default_rules
-- ----------------------------
CREATE TABLE IF NOT EXISTS `waf_default_rules` (
  `id` bigint NOT NULL,
  `name` varchar(256) NOT NULL DEFAULT '',
  `description` varchar(2048) NOT NULL DEFAULT '',
  `level` varchar(256) NOT NULL DEFAULT '',
  `app_id` bigint DEFAULT NULL,
  `rule_type` bigint DEFAULT '1',
  `vuln_id` bigint DEFAULT NULL,
  `hit_value` bigint DEFAULT NULL,
  `action` bigint DEFAULT NULL,
  `is_enabled` tinyint(1) DEFAULT NULL,
  `user_id` bigint DEFAULT NULL,
  `update_time` bigint DEFAULT NULL,
  `category` int DEFAULT '0',
  `raw` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='默认WAF策略表';

CREATE TABLE IF NOT EXISTS `waf_data_app` (
  `item_id` bigint unsigned NOT NULL,
  `ref_id` bigint unsigned NOT NULL DEFAULT '0',
  `data` longtext COLLATE utf8mb4_unicode_ci,
  `updated_at` datetime(3) NOT NULL,
  PRIMARY KEY (`item_id`,`ref_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `waf_data_caches` (
  `item_id` bigint unsigned NOT NULL,
  `ref_id` bigint unsigned NOT NULL DEFAULT '0',
  `data` longtext COLLATE utf8mb4_unicode_ci,
  `updated_at` datetime(3) NOT NULL,
  PRIMARY KEY (`item_id`,`ref_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `waf_data_cc` (
  `item_id` bigint unsigned NOT NULL,
  `ref_id` bigint unsigned NOT NULL DEFAULT '0',
  `data` longtext COLLATE utf8mb4_unicode_ci,
  `updated_at` datetime(3) NOT NULL,
  PRIMARY KEY (`item_id`,`ref_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `waf_data_certs` (
  `item_id` bigint unsigned NOT NULL,
  `ref_id` bigint unsigned NOT NULL DEFAULT '0',
  `data` longtext COLLATE utf8mb4_unicode_ci,
  `updated_at` datetime(3) NOT NULL,
  PRIMARY KEY (`item_id`,`ref_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `waf_data_domains` (
  `item_id` bigint unsigned NOT NULL,
  `ref_id` bigint unsigned NOT NULL DEFAULT '0',
  `data` longtext COLLATE utf8mb4_unicode_ci,
  `updated_at` datetime(3) NOT NULL,
  PRIMARY KEY (`item_id`,`ref_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `waf_data_groups` (
  `item_id` bigint unsigned NOT NULL,
  `ref_id` bigint unsigned NOT NULL DEFAULT '0',
  `data` longtext COLLATE utf8mb4_unicode_ci,
  `updated_at` datetime(3) NOT NULL,
  PRIMARY KEY (`item_id`,`ref_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `waf_data_headers` (
  `item_id` bigint unsigned NOT NULL,
  `ref_id` bigint unsigned NOT NULL DEFAULT '0',
  `data` longtext COLLATE utf8mb4_unicode_ci,
  `updated_at` datetime(3) NOT NULL,
  PRIMARY KEY (`item_id`,`ref_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `waf_data_ja3_blacklist` (
  `item_id` bigint unsigned NOT NULL,
  `ref_id` bigint unsigned NOT NULL DEFAULT '0',
  `data` longtext COLLATE utf8mb4_unicode_ci,
  `updated_at` datetime(3) NOT NULL,
  PRIMARY KEY (`item_id`,`ref_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `waf_data_l4app` (
  `item_id` bigint unsigned NOT NULL,
  `ref_id` bigint unsigned NOT NULL DEFAULT '0',
  `data` longtext COLLATE utf8mb4_unicode_ci,
  `updated_at` datetime(3) NOT NULL,
  PRIMARY KEY (`item_id`,`ref_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `waf_data_policy` (
  `item_id` bigint unsigned NOT NULL,
  `ref_id` bigint unsigned NOT NULL DEFAULT '0',
  `data` longtext COLLATE utf8mb4_unicode_ci,
  `updated_at` datetime(3) NOT NULL,
  PRIMARY KEY (`item_id`,`ref_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `waf_data_profile` (
  `item_id` bigint unsigned NOT NULL,
  `ref_id` bigint unsigned NOT NULL DEFAULT '0',
  `data` longtext COLLATE utf8mb4_unicode_ci,
  `updated_at` datetime(3) NOT NULL,
  PRIMARY KEY (`item_id`,`ref_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `waf_data_redirects` (
  `item_id` bigint unsigned NOT NULL,
  `ref_id` bigint unsigned NOT NULL DEFAULT '0',
  `data` longtext COLLATE utf8mb4_unicode_ci,
  `updated_at` datetime(3) NOT NULL,
  PRIMARY KEY (`item_id`,`ref_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `waf_data_self_certs` (
  `item_id` bigint unsigned NOT NULL,
  `ref_id` bigint unsigned NOT NULL DEFAULT '0',
  `data` longtext COLLATE utf8mb4_unicode_ci,
  `updated_at` datetime(3) NOT NULL,
  PRIMARY KEY (`item_id`,`ref_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `waf_data_setting` (
  `item_id` bigint unsigned NOT NULL,
  `ref_id` bigint unsigned NOT NULL DEFAULT '0',
  `data` longtext COLLATE utf8mb4_unicode_ci,
  `updated_at` datetime(3) NOT NULL,
  PRIMARY KEY (`item_id`,`ref_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `waf_data_user` (
  `item_id` bigint unsigned NOT NULL,
  `ref_id` bigint unsigned NOT NULL DEFAULT '0',
  `data` longtext COLLATE utf8mb4_unicode_ci,
  `updated_at` datetime(3) NOT NULL,
  PRIMARY KEY (`item_id`,`ref_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `waf_data_vuln_types` (
  `item_id` bigint unsigned NOT NULL,
  `ref_id` bigint unsigned NOT NULL DEFAULT '0',
  `data` longtext COLLATE utf8mb4_unicode_ci,
  `updated_at` datetime(3) NOT NULL,
  PRIMARY KEY (`item_id`,`ref_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `waf_data_waf` (
  `item_id` bigint unsigned NOT NULL,
  `ref_id` bigint unsigned NOT NULL DEFAULT '0',
  `data` longtext COLLATE utf8mb4_unicode_ci,
  `updated_at` datetime(3) NOT NULL,
  PRIMARY KEY (`item_id`,`ref_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
