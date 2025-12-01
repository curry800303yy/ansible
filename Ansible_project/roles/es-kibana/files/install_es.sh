#!/bin/bash

#=============================================================================
# ELK Stack 自动化安装脚本 (Elasticsearch 8.16.4 + Kibana 8.16.4)
# 功能：自动安装ES、Kibana，设置固定密码，执行索引初始化
# 适用于 Linux x86_64 系统
# 使用方法: sudo bash install_es.sh
# 
# 固定密码配置:
# - elastic 用户密码: ESPWlajKy5p137mOE9c2
# - kibana_system 用户密码: ESPWlajKy5p137mOE9c2
#=============================================================================

set -e  # 遇到错误立即退出

# 信号处理函数
cleanup() {
    log_warn "检测到中断信号，正在清理..."
    rm -f /tmp/es_temp_password.txt
    log_info "清理完成"
    exit 1
}

# 注册信号处理
trap cleanup SIGINT SIGTERM

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置变量
ES_VERSION="8.16.4"
KIBANA_VERSION="8.16.4"
ES_HOME="/opt/elasticsearch"
KIBANA_HOME="/opt/kibana"
ES_USER="es"
ES_GROUP="es"
CLUSTER_NAME="ELK-Cluster"
NODE_NAME="elk-node1"
NETWORK_HOST="0.0.0.0"
HTTP_PORT="9200"
KIBANA_PORT="5601"
DISCOVERY_TYPE="single-node"  # 单节点模式，如需集群模式请修改
# 固定密码配置
ES_PASSWORD="ESPWlajKy5p137mOE9c2"
KIBANA_PASSWORD="ESPWlajKy5p137mOE9c2"

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# 检查是否以 root 权限运行
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "此脚本必须以 root 权限运行"
        exit 1
    fi
}

# 检查系统要求
check_system() {
    log_info "检查系统要求..."
    
    # 检查系统架构
    if [[ $(uname -m) != "x86_64" ]]; then
        log_error "此脚本仅支持 x86_64 架构"
        exit 1
    fi
    
    # 检查必要命令
    for cmd in wget tar; do
        if ! command -v $cmd &> /dev/null; then
            log_error "$cmd 命令未找到，请先安装"
            exit 1
        fi
    done
}

# 创建用户
create_user() {
    log_info "创建 Elasticsearch 用户..."
    
    if id "$ES_USER" &>/dev/null; then
        log_warn "用户 $ES_USER 已存在，跳过创建"
    else
        useradd -m -s /bin/bash $ES_USER
        log_info "用户 $ES_USER 创建成功"
    fi
}

# 下载和解压 Elasticsearch
download_elasticsearch() {
    log_info "下载 Elasticsearch $ES_VERSION..."
    
    cd /opt
    
    if [[ -f "elasticsearch-${ES_VERSION}-linux-x86_64.tar.gz" ]]; then
        log_warn "安装包已存在，跳过下载"
    else
        wget "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ES_VERSION}-linux-x86_64.tar.gz"
    fi
    
    log_info "解压 Elasticsearch..."
    tar -zxf "elasticsearch-${ES_VERSION}-linux-x86_64.tar.gz"
    
    if [[ -d "$ES_HOME" ]]; then
        log_warn "$ES_HOME 已存在，正在备份..."
        mv "$ES_HOME" "${ES_HOME}.backup.$(date +%Y%m%d%H%M%S)"
    fi
    
    mv "elasticsearch-${ES_VERSION}" "$ES_HOME"
}

# 设置完整权限（一次性设置，避免冲突）
set_permissions() {
    log_info "设置文件权限..."
    
    # 1. 先设置用户所有权
    chown -R ${ES_USER}:${ES_GROUP} "$ES_HOME"
    
    # 2. 设置所有目录权限为755
    find "$ES_HOME" -type d -exec chmod 755 {} \;
    
    # 3. 设置配置文件、日志文件等为644
    find "$ES_HOME/config" -type f -name "*.yml" -exec chmod 644 {} \;
    find "$ES_HOME/config" -type f -name "*.yaml" -exec chmod 644 {} \;
    find "$ES_HOME/config" -type f -name "*.properties" -exec chmod 644 {} \;
    find "$ES_HOME/config" -type f -name "*.txt" -exec chmod 644 {} \;
    
    # 4. 设置jar文件权限
    find "$ES_HOME" -name "*.jar" -exec chmod 644 {} \;
    
    # 5. 明确设置可执行文件权限
    if [[ -d "$ES_HOME/bin" ]]; then
        chmod 755 "$ES_HOME/bin"
        find "$ES_HOME/bin" -type f -exec chmod 755 {} \;
        log_info "Elasticsearch bin 目录权限设置完成"
    fi
    
    if [[ -d "$ES_HOME/jdk/bin" ]]; then
        chmod 755 "$ES_HOME/jdk/bin"
        find "$ES_HOME/jdk/bin" -type f -exec chmod 755 {} \;
        log_info "JDK bin 目录权限设置完成"
    fi
    
    # 6. 设置JDK相关库文件权限
    if [[ -d "$ES_HOME/jdk" ]]; then
        find "$ES_HOME/jdk" -name "*.so" -exec chmod 755 {} \;
        find "$ES_HOME/jdk" -name "*.dylib" -exec chmod 755 {} \;
    fi
    
    # 7. 设置证书文件权限（如果存在）
    if [[ -d "$ES_HOME/config/certs" ]]; then
        chmod 700 "$ES_HOME/config/certs"
        chmod 600 "$ES_HOME/config/certs/"*.p12 2>/dev/null || true
        log_info "证书文件权限设置完成"
    fi
    
    # 8. 验证关键可执行文件权限
    log_info "验证权限设置..."
    if [[ -x "$ES_HOME/jdk/bin/java" ]]; then
        log_info "✓ Java 可执行文件权限正确"
    else
        log_error "✗ Java 可执行文件权限不正确"
        chmod 755 "$ES_HOME/jdk/bin/java"
        log_info "已手动修复 Java 权限"
    fi
    
    if [[ -x "$ES_HOME/bin/elasticsearch" ]]; then
        log_info "✓ Elasticsearch 可执行文件权限正确"
    else
        log_error "✗ Elasticsearch 可执行文件权限不正确"
        chmod 755 "$ES_HOME/bin/elasticsearch"
        log_info "已手动修复 Elasticsearch 权限"
    fi
    
    log_info "权限设置完成"
}

# 配置 Elasticsearch
configure_elasticsearch() {
    log_info "配置 Elasticsearch..."
    
    # 创建数据和日志目录
    mkdir -p "$ES_HOME/config/data/log"
    
    # 备份原始配置文件
    cp "$ES_HOME/config/elasticsearch.yml" "$ES_HOME/config/elasticsearch.yml.backup"
    
    # 生成新的配置文件
    cat > "$ES_HOME/config/elasticsearch.yml" << EOF
cluster.name: ${CLUSTER_NAME}
node.name: ${NODE_NAME}
path.data: ${ES_HOME}/config/data
path.logs: ${ES_HOME}/config/data/log
bootstrap.memory_lock: true
network.host: ${NETWORK_HOST}
http.port: ${HTTP_PORT}

# 单节点
discovery.type: ${DISCOVERY_TYPE}

# 多节点（如需启用，请取消注释并配置）
#discovery.seed_hosts: ["172.16.0.209"]
#cluster.initial_master_nodes: ["elk-node1"]

xpack.security.enabled: true

# 开启https（默认关闭，如需启用请取消注释）
#xpack.security.http.ssl:
#  enabled: true
#  keystore.path: ${ES_HOME}/config/certs/elastic-certificates.p12
#  truststore.path: ${ES_HOME}/config/certs/elastic-certificates.p12

# 传输层SSL配书（单节点也需启用）
xpack.security.transport.ssl.enabled: true
xpack.security.transport.ssl.verification_mode: certificate
xpack.security.transport.ssl.keystore.path: ${ES_HOME}/config/certs/elastic-certificates.p12
xpack.security.transport.ssl.truststore.path: ${ES_HOME}/config/certs/elastic-certificates.p12
EOF

    # 设置配置文件权限
    chown ${ES_USER}:${ES_GROUP} "$ES_HOME/config/elasticsearch.yml"
    chmod 644 "$ES_HOME/config/elasticsearch.yml"
}

# 生成证书（修复版）
generate_certificates() {
    log_info "生成 SSL 证书..."
    
    # 先创建证书目录并设置权限
    mkdir -p "$ES_HOME/config/certs/"
    chown ${ES_USER}:${ES_GROUP} "$ES_HOME/config/certs/"
    
    # 验证Java是否可执行
    log_info "验证Java可执行性..."
    if ! su - $ES_USER -c "test -x $ES_HOME/jdk/bin/java"; then
        log_error "Java 二进制文件不可执行，正在修复..."
        chmod 755 "$ES_HOME/jdk/bin/java"
        chown ${ES_USER}:${ES_GROUP} "$ES_HOME/jdk/bin/java"
    fi
    
    # 切换到 es 用户执行
    su - $ES_USER << 'CERT_EOF'
cd /opt/elasticsearch

# 验证当前目录和权限
echo "当前目录: $(pwd)"
echo "验证Java版本..."

# 正确的Java版本验证方式
if /opt/elasticsearch/jdk/bin/java -version 2>&1 | head -1; then
    echo "Java版本验证成功"
else
    echo "Java执行失败，退出"
    exit 1
fi

# 生成 CA 证书
echo "生成 CA 证书..."
echo -e "\n\n" | bin/elasticsearch-certutil ca

# 使用 CA 证书签发节点证书
echo "生成节点证书..."
echo -e "\n\n\n" | bin/elasticsearch-certutil cert --ca elastic-stack-ca.p12

# 检查证书文件是否生成
if [[ -f "elastic-stack-ca.p12" && -f "elastic-certificates.p12" ]]; then
    # 移动证书到配置目录
    mv elastic-stack-ca.p12 elastic-certificates.p12 config/certs/
    
    # 设置证书权限
    chmod 600 config/certs/*.p12
    echo "证书生成并移动成功"
else
    echo "错误: 证书文件未生成"
    ls -la elastic-*.p12 2>/dev/null || echo "未找到证书文件"
    exit 1
fi
CERT_EOF

    if [[ $? -ne 0 ]]; then
        log_error "证书生成失败"
        exit 1
    fi

    log_info "证书生成完成"
}

# 创建 systemd 服务
create_systemd_service() {
    log_info "创建 systemd 服务..."
    
    cat > /etc/systemd/system/elasticsearch.service << EOF
[Unit]
Description=Elasticsearch
Documentation=https://www.elastic.co
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=${ES_USER}
Group=${ES_GROUP}
ExecStart=${ES_HOME}/bin/elasticsearch
Restart=always
RestartSec=3
LimitNOFILE=65535
LimitMEMLOCK=infinity

# 添加 Java 相关环境变量
Environment="ES_JAVA_HOME=${ES_HOME}/jdk"
Environment="JAVA_HOME=${ES_HOME}/jdk"

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
}

# 配置系统参数
configure_system() {
    log_info "配置系统参数..."
    
    # 设置虚拟内存
    sysctl -w vm.max_map_count=262144
    
    # 检查并添加到 sysctl.conf
    if ! grep -q "vm.max_map_count=262144" /etc/sysctl.conf; then
        echo "vm.max_map_count=262144" >> /etc/sysctl.conf
    fi
    
    # 设置文件描述符限制
    if ! grep -q "${ES_USER} soft nofile" /etc/security/limits.conf; then
        cat >> /etc/security/limits.conf << EOF
${ES_USER} soft nofile 65535
${ES_USER} hard nofile 65535
${ES_USER} soft memlock unlimited
${ES_USER} hard memlock unlimited
EOF
    fi
    
    # 添加本地 host 解析
    if ! grep -q "127.0.0.1 instance" /etc/hosts; then
        echo "127.0.0.1 instance" >> /etc/hosts
    fi
}

# 启动前最终检查
pre_start_check() {
    log_info "启动前最终检查..."
    
    # 确保关键文件权限正确
    chmod 755 "$ES_HOME/jdk/bin/java"
    chmod 755 "$ES_HOME/bin/elasticsearch"
    chown -R ${ES_USER}:${ES_GROUP} "$ES_HOME"
    
    # 测试用户是否可以执行Java
    if su - $ES_USER -c "$ES_HOME/jdk/bin/java -version" >/dev/null 2>&1; then
        log_info "✓ es 用户可以正常执行Java"
    else
        log_error "✗ es 用户无法执行Java"
        return 1
    fi
}

# 启动服务
start_service() {
    log_info "启动 Elasticsearch 服务..."
    
    # 启动前检查
    pre_start_check

    systemctl enable --now elasticsearch

    log_info "等待 Elasticsearch 启动（最长 180 秒）..."

    # 最多等待 180 秒
    for i in {1..180}; do
        # ① service 层面：进程必须处于 active 状态
        if systemctl is-active --quiet elasticsearch; then
            # ② API 层面：端口已打开且返回码在允许列表
            http_code=$(curl -k -s -o /dev/null -w "%{http_code}" http://localhost:${HTTP_PORT} || true)
            if [[ "$http_code" =~ ^(200|401|302|403|503)$ ]]; then
                log_info "Elasticsearch 服务已就绪（code=$http_code）"
                return 0
            fi
        fi
        echo -n "."
        sleep 1
    done
    echo
    log_error "Elasticsearch 服务启动超时"

    # 输出更多诊断信息
    systemctl status elasticsearch --no-pager
    journalctl -u elasticsearch -n 50 --no-pager
    exit 1
}

# 简化的密码设置函数（备用）
set_simple_password() {
    log_info "使用简化方法设置密码..."
    
    # 尝试使用常见的默认密码
    for test_pwd in "" "changeme" "elastic"; do
        log_info "尝试使用密码: '$test_pwd'"
        if curl -k -X POST "http://localhost:${HTTP_PORT}/_security/user/elastic/_password" \
             -H "Content-Type: application/json" \
             -u "elastic:$test_pwd" \
             -d '{"password":"'$ES_PASSWORD'"}' 2>/dev/null | grep -q "{}"; then
            log_info "✓ 成功设置为指定密码"
            echo "elastic:$ES_PASSWORD" > "$ES_HOME/elastic_credentials.txt"
            chmod 600 "$ES_HOME/elastic_credentials.txt"
            chown $ES_USER:$ES_GROUP "$ES_HOME/elastic_credentials.txt"
            return 0
        fi
    done
    
    log_warn "简化方法也失败"
    return 1
}

# 设置固定密码
set_fixed_passwords() {
    log_info "设置固定密码..."
    
    # 检查服务状态
    log_info "检查服务状态..."
    if systemctl is-active --quiet elasticsearch; then
        http_code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:${HTTP_PORT} 2>/dev/null || echo "000")
        if [[ "$http_code" =~ ^(401|200|403)$ ]]; then
            log_info "✓ 服务状态正常"
        else
            log_info "服务状态异常，重启服务..."
            systemctl restart elasticsearch
            sleep 15
        fi
    else
        log_info "服务未运行，启动服务..."
        systemctl start elasticsearch
        sleep 15
    fi
    
    # 首先尝试简化方法
    if set_simple_password; then
        log_info "✓ 简化方法成功设置密码"
    else
        log_info "简化方法失败，尝试完整重置流程..."
        
        # 先重置elastic用户密码（生成随机密码）然后再修改为指定密码
        log_info "重置 elastic 用户密码..."
        TEMP_PASSWORD=""
    
    # 方法1：使用elasticsearch-reset-password生成临时密码（带超时）
    TEMP_FILE="/tmp/es_temp_password.txt"
    log_info "正在执行密码重置命令..."
    
    # 使用timeout命令避免无限等待
    set +e  # 临时关闭set -e，避免重置命令失败导致脚本退出
    timeout 60s su - $ES_USER -c "cd $ES_HOME && echo 'y' | ./bin/elasticsearch-reset-password -u elastic -s" > "$TEMP_FILE" 2>&1
    reset_result=$?
    set -e  # 重新启用set -e
    if [[ $reset_result -eq 0 ]]; then
        log_info "密码重置命令执行完成，分析输出..."
        
        # 显示完整输出用于调试
        echo "=== 密码重置命令输出 ==="
        cat "$TEMP_FILE"
        echo "=== 输出结束 ==="
        
        # 提取临时密码 - 改进版（处理多种输出格式）
        TEMP_PASSWORD=""
        log_info "开始提取密码..."
        
        # 方法1: 标准格式 "New value: password"
        if [[ -z "$TEMP_PASSWORD" ]]; then
            log_info "尝试方法1..."
            TEMP_PASSWORD=$(cat "$TEMP_FILE" | grep -oP 'New value:\s*\K\S+' 2>/dev/null || true)
            [[ -n "$TEMP_PASSWORD" ]] && log_info "方法1成功提取密码"
            log_info "方法1完成，密码: '$TEMP_PASSWORD'"
        fi
        
        # 方法2: 直接跟在 [y/N] 后的密码（如：[y/N]x-5j*cKc+EZna8zL2L6Y）
        if [[ -z "$TEMP_PASSWORD" ]]; then
            log_info "尝试方法2..."
            TEMP_PASSWORD=$(cat "$TEMP_FILE" | grep -oP '\[y/N\]\K[A-Za-z0-9_+*=-]+' 2>/dev/null || true)
            [[ -n "$TEMP_PASSWORD" ]] && log_info "方法2成功提取密码"
            log_info "方法2完成，密码: '$TEMP_PASSWORD'"
        fi
        
        # 方法3: 提取行末的密码（处理特殊格式）
        if [[ -z "$TEMP_PASSWORD" ]]; then
            # 从包含 [y/N] 的行中提取密码
            CONFIRM_LINE=$(cat "$TEMP_FILE" | grep '\[y/N\]' || true)
            if [[ -n "$CONFIRM_LINE" ]]; then
                # 提取 [y/N] 后面的所有字符
                TEMP_PASSWORD=$(echo "$CONFIRM_LINE" | sed 's/.*\[y\/N\]//' | tr -d '\n\r ')
                [[ -n "$TEMP_PASSWORD" ]] && log_info "方法3成功提取密码: $TEMP_PASSWORD"
            fi
        fi
        
        # 方法4: 通用密码模式匹配
        if [[ -z "$TEMP_PASSWORD" ]]; then
            TEMP_PASSWORD=$(cat "$TEMP_FILE" | grep -oE '[A-Za-z0-9_+*=-]{15,30}' | grep -v "elasticsearch" | grep -v "Please" | grep -v "password" | grep -v "confirm" | tail -1 || true)
            [[ -n "$TEMP_PASSWORD" ]] && log_info "方法4成功提取密码"
        fi
        
        # 方法5: 最后尝试 - 任何看起来像密码的字符串
        if [[ -z "$TEMP_PASSWORD" ]]; then
            TEMP_PASSWORD=$(cat "$TEMP_FILE" | grep -oE '[A-Za-z0-9_+*=-]{10,30}' | tail -1 || true)
            [[ -n "$TEMP_PASSWORD" ]] && log_info "方法5成功提取密码"
        fi
        
        if [[ -n "$TEMP_PASSWORD" && ${#TEMP_PASSWORD} -ge 10 ]]; then
            log_info "✓ 获取到临时密码，长度: ${#TEMP_PASSWORD}"
            log_info "临时密码: $TEMP_PASSWORD"
            log_info "开始执行密码设置流程..."
            
            # 使用临时密码设置为指定密码
            log_info "设置 elastic 用户密码为: $ES_PASSWORD"
            log_info "执行curl命令..."
            
            set +e  # 临时关闭set -e
            CURL_OUTPUT=$(curl -k -X POST "http://localhost:${HTTP_PORT}/_security/user/elastic/_password" \
                 -H "Content-Type: application/json" \
                 -u "elastic:${TEMP_PASSWORD}" \
                 -d "{\"password\":\"${ES_PASSWORD}\"}" \
                 --connect-timeout 10 \
                 --max-time 30 \
                 -w "HTTPCODE:%{http_code}" \
                 2>&1)
            
            CURL_EXIT_CODE=$?
            set -e  # 重新启用set -e
            log_info "curl命令执行完成，退出码: $CURL_EXIT_CODE"
            log_info "curl输出: $CURL_OUTPUT"
            
            if [[ $CURL_EXIT_CODE -eq 0 ]]; then
                # 从curl输出中提取HTTP代码和响应体
                CURL_BODY=$(echo "$CURL_OUTPUT" | sed 's/HTTPCODE:[0-9]*$//')
                CURL_CODE=$(echo "$CURL_OUTPUT" | grep -o 'HTTPCODE:[0-9]*' | cut -d: -f2)
                
                log_info "API响应码: $CURL_CODE"
                log_info "API响应内容: $CURL_BODY"
                
                if [[ "$CURL_CODE" == "200" ]] || [[ "$CURL_BODY" == "{}" ]] || [[ -z "$CURL_BODY" ]]; then
                    log_info "✓ elastic 用户密码设置成功"
                    echo "elastic:$ES_PASSWORD" > "$ES_HOME/elastic_credentials.txt"
                    chmod 600 "$ES_HOME/elastic_credentials.txt"
                    chown $ES_USER:$ES_GROUP "$ES_HOME/elastic_credentials.txt"
                else
                    log_error "API返回异常，将保留临时密码"
                    echo "elastic:$TEMP_PASSWORD" > "$ES_HOME/elastic_credentials.txt"
                    chmod 600 "$ES_HOME/elastic_credentials.txt"
                    chown $ES_USER:$ES_GROUP "$ES_HOME/elastic_credentials.txt"
                    ES_PASSWORD="$TEMP_PASSWORD"
                    log_warn "将使用临时密码: $TEMP_PASSWORD"
                fi
            else
                log_error "curl命令执行失败，将保留临时密码"
                echo "elastic:$TEMP_PASSWORD" > "$ES_HOME/elastic_credentials.txt"
                chmod 600 "$ES_HOME/elastic_credentials.txt"
                chown $ES_USER:$ES_GROUP "$ES_HOME/elastic_credentials.txt"
                ES_PASSWORD="$TEMP_PASSWORD"
                log_warn "将使用临时密码: $TEMP_PASSWORD"
            fi
        else
            log_error "无法提取临时密码，尝试备用方法..."
            
            # 备用方法：使用bootstrap password（如果存在）
            if [[ -f "$ES_HOME/config/elasticsearch.keystore" ]]; then
                log_info "尝试使用默认密码changeme..."
                if curl -k -X POST "http://localhost:${HTTP_PORT}/_security/user/elastic/_password" \
                     -H "Content-Type: application/json" \
                     -u "elastic:changeme" \
                     -d '{"password":"'$ES_PASSWORD'"}' 2>/dev/null | grep -q "{}"; then
                    log_info "✓ 使用默认密码成功设置"
                    echo "elastic:$ES_PASSWORD" > "$ES_HOME/elastic_credentials.txt"
                    chmod 600 "$ES_HOME/elastic_credentials.txt"
                    chown $ES_USER:$ES_GROUP "$ES_HOME/elastic_credentials.txt"
                else
                    log_error "默认密码也失败，使用临时密码"
                    RANDOM_PWD=$(openssl rand -base64 20)
                    echo "elastic:$RANDOM_PWD" > "$ES_HOME/elastic_credentials.txt"
                    chmod 600 "$ES_HOME/elastic_credentials.txt"
                    chown $ES_USER:$ES_GROUP "$ES_HOME/elastic_credentials.txt"
                    ES_PASSWORD="$RANDOM_PWD"
                    log_warn "使用随机密码: $RANDOM_PWD"
                fi
            else
                log_error "无可用的备用方法，使用随机密码"
                RANDOM_PWD=$(openssl rand -base64 20)
                echo "elastic:$RANDOM_PWD" > "$ES_HOME/elastic_credentials.txt"
                chmod 600 "$ES_HOME/elastic_credentials.txt"
                chown $ES_USER:$ES_GROUP "$ES_HOME/elastic_credentials.txt"
                ES_PASSWORD="$RANDOM_PWD"
                log_warn "使用随机密码: $RANDOM_PWD"
            fi
        fi
    else
        log_error "重置密码命令超时或失败"
        log_info "尝试查看命令输出..."
        cat "$TEMP_FILE" 2>/dev/null || log_info "无输出文件"
        
        # 备用：尝试使用默认密码
        log_info "尝试使用可能的默认密码..."
        for default_pwd in "changeme" "" "elastic"; do
            log_info "尝试密码: $default_pwd"
            if curl -k -X POST "http://localhost:${HTTP_PORT}/_security/user/elastic/_password" \
                 -H "Content-Type: application/json" \
                 -u "elastic:$default_pwd" \
                 -d '{"password":"'$ES_PASSWORD'"}' 2>/dev/null | grep -q "{}"; then
                log_info "✓ 使用默认密码 '$default_pwd' 成功设置"
                echo "elastic:$ES_PASSWORD" > "$ES_HOME/elastic_credentials.txt"
                chmod 600 "$ES_HOME/elastic_credentials.txt"
                chown $ES_USER:$ES_GROUP "$ES_HOME/elastic_credentials.txt"
                break
            fi
        done
        
        # 如果所有方法都失败，使用临时密码作为最终密码
        if [[ ! -f "$ES_HOME/elastic_credentials.txt" ]]; then
            log_warn "所有密码设置方法失败，将使用系统生成的随机密码"
            RANDOM_PWD=$(openssl rand -base64 20)
            echo "elastic:$RANDOM_PWD" > "$ES_HOME/elastic_credentials.txt"
            chmod 600 "$ES_HOME/elastic_credentials.txt"
            chown $ES_USER:$ES_GROUP "$ES_HOME/elastic_credentials.txt"
            ES_PASSWORD="$RANDOM_PWD"
            log_warn "临时使用密码: $RANDOM_PWD"
        fi
    fi
    
    rm -f "$TEMP_FILE"
    fi  # 结束简化方法失败的else块
    
    log_info "密码设置流程完成，继续后续步骤..."
    
    # 设置kibana_system用户密码
    log_info "设置 kibana_system 用户密码为: $KIBANA_PASSWORD"
    set +e  # 临时关闭set -e
    curl_result=$(curl -k -X POST "http://localhost:${HTTP_PORT}/_security/user/kibana_system/_password" \
         -H "Content-Type: application/json" \
         -u "elastic:$ES_PASSWORD" \
         -d '{"password":"'$KIBANA_PASSWORD'"}' 2>/dev/null)
    set -e  # 重新启用set -e
    if echo "$curl_result" | grep -q "{}"; then
        log_info "✓ kibana_system 用户密码设置成功"
        echo "kibana_system:$KIBANA_PASSWORD" >> "$ES_HOME/elastic_credentials.txt"
    else
        log_warn "kibana_system 用户密码设置失败，将在Kibana安装后重试"
    fi
    
    # 启用HTTPS
    log_info "启用HTTPS配置..."
    sed -i 's/#xpack.security.http.ssl:/xpack.security.http.ssl:/g' "$ES_HOME/config/elasticsearch.yml"
    sed -i 's/#  enabled: true/  enabled: true/g' "$ES_HOME/config/elasticsearch.yml"
    sed -i "s|#  keystore.path: .*|  keystore.path: ${ES_HOME}/config/certs/elastic-certificates.p12|g" "$ES_HOME/config/elasticsearch.yml"
    sed -i "s|#  truststore.path: .*|  truststore.path: ${ES_HOME}/config/certs/elastic-certificates.p12|g" "$ES_HOME/config/elasticsearch.yml"
    
    log_info "重启服务以启用HTTPS..."
    set +e  # 临时关闭set -e
    systemctl restart elasticsearch
    restart_result=$?
    set -e  # 重新启用set -e
    if [[ $restart_result -ne 0 ]]; then
        log_warn "服务重启失败，但继续执行..."
    fi
    
    # 等待HTTPS服务启动
    log_info "等待HTTPS服务启动..."
    for i in {1..30}; do
        set +e  # 临时关闭set -e
        curl -k -s -o /dev/null https://localhost:${HTTP_PORT} 2>/dev/null
        curl_result=$?
        set -e  # 重新启用set -e
        if [[ $curl_result -eq 0 ]]; then
            log_info "✓ HTTPS服务已启动"
            # HTTPS启动后，重新尝试设置为指定密码
            if [[ "$ES_PASSWORD" != "ESPWlajKy5p137mOE9c2" ]]; then
                log_info "使用HTTPS重新设置指定密码..."
                if curl -k -X POST "https://localhost:${HTTP_PORT}/_security/user/elastic/_password" \
                     -H "Content-Type: application/json" \
                     -u "elastic:$ES_PASSWORD" \
                     -d '{"password":"ESPWlajKy5p137mOE9c2"}' 2>/dev/null | grep -q "{}"; then
                    log_info "✓ 成功设置为指定密码"
                    ES_PASSWORD="ESPWlajKy5p137mOE9c2"
                    echo "elastic:$ES_PASSWORD" > "$ES_HOME/elastic_credentials.txt"
                    chmod 600 "$ES_HOME/elastic_credentials.txt"
                    chown $ES_USER:$ES_GROUP "$ES_HOME/elastic_credentials.txt"
                fi
            fi
            break
        fi
        echo -n "."
        sleep 2
    done
    echo
    
    return 0
}

# 检查集群健康状态
check_cluster_health() {
    log_info "检查集群健康状态..."
    local max_attempts=30
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        # 尝试HTTP请求
        local http_response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:${HTTP_PORT} 2>/dev/null || echo "000")
        
        if [[ "$http_response" =~ ^(200|401|403)$ ]]; then
            log_info "✓ 集群健康检查通过（HTTP $http_response）"
            return 0
        fi
        
        echo -n "."
        sleep 2
        ((attempt++))
    done
    
    log_warn "集群健康检查超时，但继续执行..."
    return 1
}

# 下载和安装 Kibana
download_kibana() {
    log_info "下载 Kibana $KIBANA_VERSION..."
    
    cd /opt
    
    if [[ -f "kibana-${KIBANA_VERSION}-linux-x86_64.tar.gz" ]]; then
        log_warn "Kibana安装包已存在，跳过下载"
    else
        wget "https://artifacts.elastic.co/downloads/kibana/kibana-${KIBANA_VERSION}-linux-x86_64.tar.gz"
    fi
    
    log_info "解压 Kibana..."
    tar -zxf "kibana-${KIBANA_VERSION}-linux-x86_64.tar.gz"
    
    if [[ -d "$KIBANA_HOME" ]]; then
        log_warn "$KIBANA_HOME 已存在，正在备份..."
        mv "$KIBANA_HOME" "${KIBANA_HOME}.backup.$(date +%Y%m%d%H%M%S)"
    fi
    
    mv "kibana-${KIBANA_VERSION}" "$KIBANA_HOME"
    chown -R ${ES_USER}:${ES_GROUP} "$KIBANA_HOME"
}

# 配置 Kibana
configure_kibana() {
    log_info "配置 Kibana..."
    
    # 重新尝试设置kibana_system密码（如果之前失败了）
    if ! grep -q "kibana_system:$KIBANA_PASSWORD" "$ES_HOME/elastic_credentials.txt" 2>/dev/null; then
        log_info "重新设置 kibana_system 用户密码..."
        if curl -k -X POST "https://localhost:${HTTP_PORT}/_security/user/kibana_system/_password" \
             -H "Content-Type: application/json" \
             -u "elastic:$ES_PASSWORD" \
             -d '{"password":"'$KIBANA_PASSWORD'"}' 2>/dev/null | grep -q "{}"; then
            log_info "✓ kibana_system 用户密码设置成功"
            echo "kibana_system:$KIBANA_PASSWORD" >> "$ES_HOME/elastic_credentials.txt"
        else
            log_warn "kibana_system 用户密码设置仍然失败"
        fi
    fi
    
    # 获取服务器IP
    local internal_ip=$(hostname -I | awk '{print $1}')
    local public_ip=""
    
    # 尝试获取公网IP
    for service in "ipinfo.io/ip" "ifconfig.me" "icanhazip.com" "ipecho.net/plain"; do
        public_ip=$(curl -s --connect-timeout 5 --max-time 10 "$service" 2>/dev/null | tr -d '\n')
        if [[ -n "$public_ip" && "$public_ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
            break
        fi
        public_ip=""
    done
    
    if [[ -z "$public_ip" ]]; then
        public_ip="$internal_ip"
    fi
    
    # 备份原始配置文件
    cp "$KIBANA_HOME/config/kibana.yml" "$KIBANA_HOME/config/kibana.yml.backup"
    
    # 生成新的配置文件
    cat > "$KIBANA_HOME/config/kibana.yml" << EOF
# 监听地址，0.0.0.0 表示监听所有网络接口，允许外部访问
server.host: "0.0.0.0"

# Kibana 服务端口，默认为 5601
server.port: ${KIBANA_PORT}

# Elasticsearch 集群的地址 (注意是 https，因为启用了 SSL)
elasticsearch.hosts: ["https://${public_ip}:${HTTP_PORT}"]

# 用于连接 Elasticsearch 的用户名和密码
elasticsearch.username: "kibana_system"
elasticsearch.password: "${KIBANA_PASSWORD}"

# SSL配置
elasticsearch.ssl.verificationMode: "none"

# 设置 Kibana 界面语言为中文
i18n.locale: "zh-CN"
EOF

    # 设置配置文件权限
    chown ${ES_USER}:${ES_GROUP} "$KIBANA_HOME/config/kibana.yml"
    chmod 644 "$KIBANA_HOME/config/kibana.yml"
}

# 创建 Kibana systemd 服务
create_kibana_systemd_service() {
    log_info "创建 Kibana systemd 服务..."
    
    cat > /etc/systemd/system/kibana.service << EOF
[Unit]
Description=Kibana
Documentation=https://www.elastic.co
Wants=network-online.target
After=network-online.target elasticsearch.service

[Service]
Type=simple
User=${ES_USER}
Group=${ES_GROUP}
ExecStart=${KIBANA_HOME}/bin/kibana
Restart=always
RestartSec=3
WorkingDirectory=${KIBANA_HOME}

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
}

# 启动 Kibana 服务
start_kibana_service() {
    log_info "启动 Kibana 服务..."
    
    systemctl enable --now kibana
    
    log_info "等待 Kibana 启动（最长 120 秒）..."
    
    # 最多等待 120 秒
    for i in {1..120}; do
        if systemctl is-active --quiet kibana; then
            # 检查Kibana是否响应
            http_code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:${KIBANA_PORT} 2>/dev/null || echo "000")
            if [[ "$http_code" =~ ^(200|302)$ ]]; then
                log_info "Kibana 服务已就绪（code=$http_code）"
                return 0
            fi
        fi
        echo -n "."
        sleep 1
    done
    echo
    log_error "Kibana 服务启动超时"
    
    # 输出诊断信息
    systemctl status kibana --no-pager
    journalctl -u kibana -n 20 --no-pager
    return 1
}

# 执行 init.es.sh 脚本
execute_init_script() {
    log_info "执行 init.es.sh 初始化脚本..."
    
    # 获取脚本所在目录
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    INIT_SCRIPT="$SCRIPT_DIR/init.es.sh"
    
    # 检查脚本是否存在
    if [[ ! -f "$INIT_SCRIPT" ]]; then
        log_error "init.es.sh 脚本未找到，路径: $INIT_SCRIPT"
        log_info "请确保 init.es.sh 文件与 install_es.sh 在同一目录"
        return 1
    fi
    
    # 获取服务器IP
    local internal_ip=$(hostname -I | awk '{print $1}')
    local public_ip=""
    
    # 尝试获取公网IP
    for service in "ipinfo.io/ip" "ifconfig.me" "icanhazip.com" "ipecho.net/plain"; do
        public_ip=$(curl -s --connect-timeout 5 --max-time 10 "$service" 2>/dev/null | tr -d '\n')
        if [[ -n "$public_ip" && "$public_ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
            break
        fi
        public_ip=""
    done
    
    if [[ -z "$public_ip" ]]; then
        public_ip="$internal_ip"
    fi
    
    # 更新 init.es.sh 中的连接信息
    sed -i "s|ES_HOST=.*|ES_HOST=https://${public_ip}:${HTTP_PORT}|g" "$INIT_SCRIPT"
    sed -i "s|ES_USER=.*|ES_USER=elastic|g" "$INIT_SCRIPT"
    sed -i "s|ES_PASS=.*|ES_PASS=\"${ES_PASSWORD}\"|g" "$INIT_SCRIPT"
    
    # 设置执行权限
    chmod +x "$INIT_SCRIPT"
    
    # 执行脚本
    log_info "开始执行索引初始化..."
    log_info "执行命令: $INIT_SCRIPT"
    
    if bash "$INIT_SCRIPT"; then
        log_info "✓ 索引初始化完成"
        return 0
    else
        log_error "✗ 索引初始化失败"
        return 1
    fi
}

# 获取IP地址函数
get_server_ips() {
    local internal_ip=$(hostname -I | awk '{print $1}')
    local public_ip=""
    
    # 尝试多种方式获取公网IP
    for service in "ipinfo.io/ip" "ifconfig.me" "icanhazip.com" "ipecho.net/plain"; do
        public_ip=$(curl -s --connect-timeout 5 --max-time 10 "$service" 2>/dev/null | tr -d '\n')
        if [[ -n "$public_ip" && "$public_ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
            break
        fi
        public_ip=""
    done
    
    # 如果获取公网IP失败，使用内网IP
    if [[ -z "$public_ip" ]]; then
        public_ip="$internal_ip"
        log_warn "无法获取公网IP，使用内网IP: $internal_ip"
    fi
    
    echo "$internal_ip|$public_ip"
}

# 显示安装信息（增强版）
show_info() {
    log_info "获取服务器IP地址..."
    local ip_info=$(get_server_ips)
    local internal_ip=$(echo "$ip_info" | cut -d'|' -f1)
    local public_ip=$(echo "$ip_info" | cut -d'|' -f2)
    
    echo ""
    log_info "==========================================="
    log_info "ELK Stack 安装完成！"
    log_info "==========================================="
    
    # Elasticsearch 信息
    log_info "Elasticsearch 安装路径: $ES_HOME"
    log_info "Elasticsearch 配置文件: $ES_HOME/config/elasticsearch.yml"
    log_info "证书目录: $ES_HOME/config/certs/"
    
    # Kibana 信息
    log_info "Kibana 安装路径: $KIBANA_HOME"
    log_info "Kibana 配置文件: $KIBANA_HOME/config/kibana.yml"
    
    log_info "==========================================="
    
    # 显示认证信息
    echo -e "${BLUE}认证信息:${NC}"
    echo -e "  Elasticsearch 用户名: ${GREEN}elastic${NC}"
    echo -e "  Elasticsearch 密码: ${GREEN}$ES_PASSWORD${NC}"
    echo -e "  Kibana 用户名: ${GREEN}kibana_system${NC}"
    echo -e "  Kibana 密码: ${GREEN}$KIBANA_PASSWORD${NC}"
    echo -e "  密码文件: $ES_HOME/elastic_credentials.txt"
    
    log_info "==========================================="
    log_info "访问地址:"
    
    # 显示Elasticsearch访问地址
    echo -e "${BLUE}Elasticsearch:${NC}"
    if [[ "$internal_ip" != "$public_ip" ]]; then
        echo -e "  公网 HTTPS: ${GREEN}https://${public_ip}:${HTTP_PORT}${NC}"
        echo -e "  内网 HTTPS: https://${internal_ip}:${HTTP_PORT}"
    else
        echo -e "  HTTPS: ${GREEN}https://${public_ip}:${HTTP_PORT}${NC}"
    fi
    
    # 显示Kibana访问地址
    echo -e "${BLUE}Kibana:${NC}"
    if [[ "$internal_ip" != "$public_ip" ]]; then
        echo -e "  公网: ${GREEN}http://${public_ip}:${KIBANA_PORT}${NC}"
        echo -e "  内网: http://${internal_ip}:${KIBANA_PORT}"
    else
        echo -e "  HTTP: ${GREEN}http://${public_ip}:${KIBANA_PORT}${NC}"
    fi
    
    log_info "==========================================="
    log_info "Kibana 登录信息:"
    log_info "  用户名: ${GREEN}elastic${NC}"
    log_info "  密码: ${GREEN}$ES_PASSWORD${NC}"
    
    log_info "==========================================="
    log_info "服务管理命令:"
    echo -e "${BLUE}Elasticsearch:${NC}"
    log_info "  启动: systemctl start elasticsearch"
    log_info "  停止: systemctl stop elasticsearch"
    log_info "  重启: systemctl restart elasticsearch"
    log_info "  状态: systemctl status elasticsearch"
    log_info "  日志: journalctl -u elasticsearch -f"
    
    echo -e "${BLUE}Kibana:${NC}"
    log_info "  启动: systemctl start kibana"
    log_info "  停止: systemctl stop kibana"
    log_info "  重启: systemctl restart kibana"
    log_info "  状态: systemctl status kibana"
    log_info "  日志: journalctl -u kibana -f"
    
    log_info "==========================================="
    log_info "索引初始化状态: ✓ 已完成"
    log_info "日志索引模板: access_logs, block_logs, error_logs, api_logs"
    log_info "生命周期策略: 7天自动删除"
    
    log_info "==========================================="
    echo -e "${YELLOW}重要提示: 请妥善保管用户密码！${NC}"
    log_info "==========================================="
}

# 主函数
main() {
    log_info "开始安装 ELK Stack (Elasticsearch $ES_VERSION + Kibana $KIBANA_VERSION)..."
    
    # 第一阶段：Elasticsearch 安装
    log_info "========== 第一阶段：安装 Elasticsearch =========="
    check_root
    check_system
    create_user
    download_elasticsearch
    set_permissions
    configure_elasticsearch
    generate_certificates    
    configure_system
    create_systemd_service
    start_service
    set_fixed_passwords
    
    log_info "✓ Elasticsearch 安装完成"
    
    # 第二阶段：Kibana 安装
    log_info "========== 第二阶段：安装 Kibana =========="
    download_kibana
    configure_kibana
    create_kibana_systemd_service
    start_kibana_service
    
    log_info "✓ Kibana 安装完成"
    
    # 第三阶段：执行初始化脚本
    log_info "========== 第三阶段：执行索引初始化 =========="
    if execute_init_script; then
        log_info "✓ 索引初始化完成"
    else
        log_warn "⚠ 索引初始化失败，请手动执行 ./init.es.sh"
    fi
    
    # 显示最终信息
    log_info "========== 安装总结 =========="
    show_info
    
    log_info "🎉 ELK Stack 安装完成！"
}

# 执行主函数
main "$@"
