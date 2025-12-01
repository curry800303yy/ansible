#!/bin/bash

# 监控及夜莺自动化安装脚本
# 系统要求: Ubuntu 24.04 LTS
# 版本: 1.1
# 作者: 自动化部署脚本
# 
# 使用方法: 
#   sudo ./install.sh              # 交互模式
#   sudo ./install.sh --auto       # 自动模式（自动处理锁占用）

set -euo pipefail  # 严格模式：遇到错误立即退出

# 全局变量
AUTO_MODE=false

# 解析命令行参数
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --auto)
                AUTO_MODE=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# 显示帮助信息
show_help() {
    cat << EOF
监控及夜莺自动化安装脚本

使用方法:
    sudo $0 [选项]

选项:
    --auto      自动模式，遇到包管理器锁占用时自动处理
    -h, --help  显示此帮助信息

示例:
    sudo $0              # 交互模式安装
    sudo $0 --auto       # 自动模式安装
EOF
}

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# 错误处理函数
error_exit() {
    log_error "$1"
    exit 1
}

# 检查是否为root用户
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error_exit "此脚本需要root权限运行，请使用sudo执行"
    fi
}

# 检查系统版本
check_system() {
    log_step "检查系统环境..."
    
    if ! grep -q "Ubuntu" /etc/os-release; then
        error_exit "此脚本仅支持Ubuntu系统"
    fi
    
    local version=$(grep VERSION_ID /etc/os-release | cut -d'"' -f2)
    if [[ "$version" != "24.04" ]]; then
        log_warn "检测到Ubuntu版本为$version，推荐使用Ubuntu 24.04 LTS"
    fi
    
    log_info "系统检查完成"
}

# 检查网络连接
check_network() {
    log_step "检查网络连接..."
    
    if ! ping -c 1 -W 5 github.com >/dev/null 2>&1; then
        error_exit "无法连接到Github，请检查网络连接"
    fi
    
    log_info "网络连接正常"
}

# 安装Prometheus监控服务器
install_prometheus() {
    log_step "开始安装Prometheus监控服务器..."
    
    # 1、下载解压二进制程序
    log_info "创建应用目录并下载Prometheus..."
    mkdir -p /apps
    cd /apps
    
    # 检查是否已存在
    if [[ -d "/apps/prometheus-3.1.0.linux-amd64" ]]; then
        log_warn "检测到Prometheus已存在，跳过下载"
    else
        log_info "下载Prometheus v3.1.0..."
        if ! wget -t 3 -T 30 https://github.com/prometheus/prometheus/releases/download/v3.1.0/prometheus-3.1.0.linux-amd64.tar.gz; then
            error_exit "下载Prometheus失败"
        fi
        
        log_info "解压Prometheus安装包..."
        tar xf prometheus-3.1.0.linux-amd64.tar.gz || error_exit "解压Prometheus失败"
        rm -f prometheus-3.1.0.linux-amd64.tar.gz
    fi
    
    # 创建软连接
    log_info "创建软连接..."
    ln -sfv prometheus-3.1.0.linux-amd64 /apps/prometheus
    
    # 检查配置文件
    log_info "检查Prometheus配置文件..."
    cd /apps/prometheus
    if ! ./promtool check config prometheus.yml; then
        error_exit "Prometheus配置文件检查失败"
    fi
    
    # 添加账号密码鉴权文件
    if [[ -f "/apps/prometheus/web.yml" ]]; then
        log_info "Prometheus认证配置文件已存在，跳过创建"
    else
        log_info "创建基础认证配置文件..."
        cat > /apps/prometheus/web.yml << 'EOF'
basic_auth_users:
  admin: '$2b$12$DzrmE0ALTRJcKN5WqJ3WxuBV2OWZ0PVfexU3xZLuVIYrUFxzbk3N2'
EOF
    fi
    
    log_info "Prometheus文件准备完成，默认账号: admin，默认密码: prometheus098"
    
    # 2、创建 prometheus service 启动脚本
    if [[ -f "/etc/systemd/system/prometheus.service" ]]; then
        log_info "Prometheus systemd服务文件已存在，跳过创建"
    else
        log_info "创建Prometheus systemd服务文件..."
        cat > /etc/systemd/system/prometheus.service << 'EOF'
[Unit]
Description=Prometheus Server
Documentation=https://prometheus.io/docs/introduction/overview/
After=network.target

[Service]
Restart=on-failure
WorkingDirectory=/apps/prometheus/
ExecStart=/apps/prometheus/prometheus --config.file=/apps/prometheus/prometheus.yml --web.config.file=/apps/prometheus/web.yml

[Install]
WantedBy=multi-user.target
EOF
    fi
    
    # 3、启动 prometheus 服务
    systemctl daemon-reload || error_exit "重新加载systemd配置失败"
    
    # 检查并设置开机自启
    if systemctl is-enabled --quiet prometheus; then
        log_info "Prometheus服务已设置开机自启"
    else
        log_info "设置Prometheus开机自启..."
        systemctl enable prometheus || error_exit "设置Prometheus开机自启失败"
    fi
    
    # 启动或重启Prometheus服务
    if systemctl is-active --quiet prometheus; then
        log_info "Prometheus服务已在运行，重启以应用配置..."
        systemctl restart prometheus || error_exit "重启Prometheus服务失败"
    else
        log_info "启动Prometheus服务..."
        systemctl start prometheus || error_exit "启动Prometheus服务失败"
    fi
    
    # 验证服务状态
    if systemctl is-active --quiet prometheus; then
        log_info "Prometheus服务启动成功"
        log_info "访问地址: http://$(hostname -I | awk '{print $1}'):9090"
        log_info "默认账号: admin，默认密码: prometheus098"
    else
        error_exit "Prometheus服务启动失败"
    fi
}

# 安装夜莺部署环境
install_nightingale_prep() {
    log_step "开始夜莺部署准备工作..."
    
    # 1.1、下载夜莺包
    log_info "下载夜莺(N9E)安装包..."
    cd /opt
    
    # 检查是否已存在
    if [[ -f "n9e-v7.7.2-linux-amd64.tar.gz" ]] || [[ -d "/opt/n9e" ]]; then
        log_warn "检测到夜莺安装包已存在，跳过下载"
    else
        log_info "下载夜莺 v7.7.2..."
        if ! wget -t 3 -T 30 https://github.com/ccfos/nightingale/releases/download/v7.7.2/n9e-v7.7.2-linux-amd64.tar.gz; then
            error_exit "下载夜莺安装包失败"
        fi
        
        log_info "解压夜莺安装包..."
        tar xf n9e-v7.7.2-linux-amd64.tar.gz || error_exit "解压夜莺安装包失败"
        rm -f n9e-v7.7.2-linux-amd64.tar.gz
    fi
    
    # 修改数据库连接密码
    log_info "配置数据库连接密码..."
    if [[ -f "/opt/etc/config.toml" ]]; then
        sed -i 's/1234/asfhieghsid232/g' /opt/etc/config.toml || error_exit "修改数据库密码失败"
        log_info "数据库连接密码已更新"
    else
        log_warn "配置文件 /opt/etc/config.toml 不存在，请手动配置"
    fi
    
    log_info "夜莺部署准备工作完成"
}

# 等待并处理包管理器锁
wait_for_apt_lock() {
    local max_wait=300  # 最大等待5分钟
    local wait_time=0
    local check_interval=10
    
    log_info "检查包管理器状态..."
    
    while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 || \
          fuser /var/lib/dpkg/lock >/dev/null 2>&1 || \
          fuser /var/cache/apt/archives/lock >/dev/null 2>&1; do
        
        if [[ $wait_time -ge $max_wait ]]; then
            log_error "等待包管理器锁释放超时（${max_wait}秒）"
            log_info "正在尝试强制解决..."
            
            # 检查是否是unattended-upgrade进程
            local unattended_pid=$(pgrep -f unattended-upgrade)
            if [[ -n "$unattended_pid" ]]; then
                log_warn "检测到unattended-upgrade进程正在运行，PID: $unattended_pid"
                
                local force_stop="n"
                if [[ "$AUTO_MODE" == "true" ]]; then
                    log_info "自动模式：将自动停止unattended-upgrade进程"
                    force_stop="y"
                else
                    read -p "是否强制停止自动更新进程？(y/N): " -r force_stop
                fi
                
                if [[ $force_stop =~ ^[Yy]$ ]]; then
                    log_info "正在停止unattended-upgrade进程..."
                    systemctl stop unattended-upgrades.service 2>/dev/null || true
                    systemctl disable unattended-upgrades.service 2>/dev/null || true
                    kill -9 $unattended_pid 2>/dev/null || true
                    sleep 5
                    
                    # 清理可能的锁文件
                    rm -f /var/lib/dpkg/lock-frontend 2>/dev/null || true
                    rm -f /var/lib/dpkg/lock 2>/dev/null || true
                    rm -f /var/cache/apt/archives/lock 2>/dev/null || true
                    
                    log_info "已停止自动更新服务，继续安装..."
                    break
                else
                    error_exit "用户选择不强制停止，请等待自动更新完成后重新运行脚本"
                fi
            else
                error_exit "包管理器被其他进程占用，请手动检查并解决"
            fi
        fi
        
        log_warn "包管理器被占用，等待 $check_interval 秒后重试... (已等待: ${wait_time}s/${max_wait}s)"
        sleep $check_interval
        wait_time=$((wait_time + check_interval))
    done
    
    log_info "包管理器锁已释放，继续安装..."
}

# 安全的apt操作函数
safe_apt_update() {
    local retry_count=3
    local retry_delay=5
    
    for ((i=1; i<=retry_count; i++)); do
        log_info "尝试更新包管理器... (第 $i/$retry_count 次)"
        
        wait_for_apt_lock
        
        if apt update; then
            log_info "包管理器更新成功"
            return 0
        else
            log_warn "包管理器更新失败，${retry_delay}秒后重试..."
            sleep $retry_delay
        fi
    done
    
    error_exit "包管理器更新失败，已重试 $retry_count 次"
}

# 安全的apt安装函数
safe_apt_install() {
    local packages="$1"
    local retry_count=3
    local retry_delay=5
    
    for ((i=1; i<=retry_count; i++)); do
        log_info "尝试安装 $packages... (第 $i/$retry_count 次)"
        
        wait_for_apt_lock
        
        if DEBIAN_FRONTEND=noninteractive apt install -y $packages; then
            log_info "$packages 安装成功"
            return 0
        else
            log_warn "$packages 安装失败，${retry_delay}秒后重试..."
            sleep $retry_delay
        fi
    done
    
    error_exit "$packages 安装失败，已重试 $retry_count 次"
}

# 安装基础环境依赖
install_dependencies() {
    log_step "安装基础环境依赖..."
    
    # 安全更新包管理器
    safe_apt_update
    
    # 安装MariaDB
    log_info "检查MariaDB安装状态..."
    if ! dpkg -l | grep -q mariadb-server; then
        safe_apt_install "mariadb-server mariadb-client"
    else
        log_info "MariaDB已安装，跳过"
    fi
    
    systemctl enable mariadb || error_exit "设置MariaDB开机自启失败"
    systemctl restart mariadb || error_exit "启动MariaDB服务失败"
    
    # 设置MariaDB root密码
    log_info "检查MariaDB root密码..."
    # 先尝试用新密码连接，如果成功说明密码已设置
    if mysql -uroot -pasfhieghsid232 -e "SELECT 1;" >/dev/null 2>&1; then
        log_info "MariaDB root密码已正确设置"
    else
        log_info "设置MariaDB root密码..."
        # 使用直接mysql连接（适用于unix_socket认证）
        if mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'asfhieghsid232'; FLUSH PRIVILEGES;" 2>/dev/null; then
            log_info "MariaDB root密码设置成功"
        else
            log_warn "设置MariaDB密码失败，密码可能需要手动设置"
        fi
    fi
    
    # 为127.0.0.1连接创建用户（N9E需要）
    log_info "设置127.0.0.1连接权限..."
    if mysql -e "CREATE USER IF NOT EXISTS 'root'@'127.0.0.1' IDENTIFIED BY 'asfhieghsid232'; GRANT ALL PRIVILEGES ON *.* TO 'root'@'127.0.0.1' WITH GRANT OPTION; FLUSH PRIVILEGES;" 2>/dev/null; then
        log_info "127.0.0.1连接权限设置成功"
    else
        log_warn "127.0.0.1连接权限设置失败"
    fi
    
    # 验证127.0.0.1连接
    if mysql -h 127.0.0.1 -u root -pasfhieghsid232 -e "SELECT 1;" >/dev/null 2>&1; then
        log_info "127.0.0.1连接验证成功"
    else
        log_warn "127.0.0.1连接验证失败，N9E可能无法连接数据库"
    fi
    
    # 安装Redis
    log_info "检查Redis安装状态..."
    if ! dpkg -l | grep -q redis-server; then
        safe_apt_install "redis-server"
    else
        log_info "Redis已安装，跳过"
    fi
    
    systemctl enable redis-server || error_exit "设置Redis开机自启失败"
    systemctl restart redis-server || error_exit "启动Redis服务失败"
    
    # 导入数据库表结构
    log_info "检查夜莺数据库状态..."
    
    # 检查数据库是否已存在
    if mysql -uroot -pasfhieghsid232 -e "USE n9e_v6;" 2>/dev/null; then
        log_info "夜莺数据库已存在，跳过导入"
    else
        if [[ -f "/opt/n9e.sql" ]]; then
            log_info "导入夜莺数据库表结构..."
            if mysql -uroot -pasfhieghsid232 < /opt/n9e.sql; then
                log_info "数据库表结构导入成功"
            else
                log_error "数据库导入失败，尝试单独创建数据库..."
                # 如果导入失败，可能是因为数据库部分存在，尝试强制创建
                mysql -uroot -pasfhieghsid232 -e "CREATE DATABASE IF NOT EXISTS n9e_v6;" 2>/dev/null || true
                mysql -uroot -pasfhieghsid232 < /opt/n9e.sql || error_exit "数据库表结构导入失败"
                log_info "数据库表结构导入成功"
            fi
        else
            log_warn "未找到数据库文件 /opt/n9e.sql，请手动导入"
        fi
    fi
    
    log_info "基础环境依赖安装完成"
}

# 配置并启动夜莺服务
install_nightingale_service() {
    log_step "配置夜莺(N9E)监控服务..."
    
    # 检查夜莺服务是否已经在运行
    if systemctl is-active --quiet n9e; then
        local service_status=$(systemctl is-active n9e)
        log_info "夜莺服务已在运行，状态: $service_status"
        log_info "访问地址: http://$(hostname -I | awk '{print $1}'):17000"
        log_info "默认账号: root，默认密码: root.2020"
        return 0
    fi
    
    # 检查夜莺二进制文件是否存在
    if [[ ! -f "/opt/n9e" ]]; then
        error_exit "夜莺二进制文件不存在，请检查安装过程"
    fi
    
    # 设置夜莺二进制文件执行权限
    log_info "设置夜莺二进制文件权限..."
    chmod +x /opt/n9e || error_exit "设置夜莺执行权限失败"
    
    # 检查systemd服务文件是否已存在
    if [[ -f "/etc/systemd/system/n9e.service" ]]; then
        log_info "夜莺systemd服务文件已存在，跳过创建"
    else
        log_info "创建夜莺systemd服务文件..."
        cat > /etc/systemd/system/n9e.service << 'EOF'
[Unit]
Description=N9E Monitoring System
After=network.target
After=mysql.service
After=postgresql.service

[Service]
Type=simple
User=root
Group=root
WorkingDirectory=/opt
ExecStart=/opt/n9e
Restart=always
RestartSec=3
LimitNOFILE=65535
LimitNPROC=65535

[Install]
WantedBy=multi-user.target
EOF
    fi
    
    # 重新加载systemd配置
    log_info "重新加载systemd配置..."
    systemctl daemon-reload || error_exit "重新加载systemd配置失败"
    
    # 检查并启动夜莺服务
    if systemctl is-enabled --quiet n9e; then
        log_info "夜莺服务已设置开机自启"
    else
        log_info "设置夜莺开机自启..."
        systemctl enable n9e || error_exit "设置夜莺开机自启失败"
    fi
    
    # 启动夜莺服务（如果未运行）
    if systemctl is-active --quiet n9e; then
        log_info "夜莺服务已在运行"
    else
        log_info "启动夜莺服务..."
        systemctl start n9e || error_exit "启动夜莺服务失败"
    fi
    
    # 等待服务启动完成
    log_info "等待夜莺服务启动完成..."
    sleep 5
    
    # 检查夜莺服务状态
    if systemctl is-active --quiet n9e; then
        log_info "夜莺服务启动成功"
        log_info "访问地址: http://$(hostname -I | awk '{print $1}'):17000"
        log_info "默认账号: root，默认密码: root.2020"
        log_warn "⚠️  请务必登录后修改默认密码！"
    else
        log_error "夜莺服务启动失败，请检查日志: journalctl -u n9e -f"
        systemctl status n9e --no-pager
        error_exit "夜莺服务启动失败"
    fi
    
    log_info "夜莺监控服务配置完成"
}

# 验证安装结果
verify_installation() {
    log_step "验证安装结果..."
    
    local errors=0
    
    # 检查Prometheus
    if systemctl is-active --quiet prometheus; then
        log_info "✓ Prometheus服务运行正常"
    else
        log_error "✗ Prometheus服务未运行"
        ((errors++))
    fi
    
    # 检查MariaDB
    if systemctl is-active --quiet mariadb; then
        log_info "✓ MariaDB服务运行正常"
    else
        log_error "✗ MariaDB服务未运行"
        ((errors++))
    fi
    
    # 检查Redis
    if systemctl is-active --quiet redis-server; then
        log_info "✓ Redis服务运行正常"
    else
        log_error "✗ Redis服务未运行"
        ((errors++))
    fi
    
    # 检查夜莺服务
    if systemctl is-active --quiet n9e; then
        log_info "✓ 夜莺(N9E)服务运行正常"
    else
        log_error "✗ 夜莺(N9E)服务未运行"
        ((errors++))
    fi
    
    # 检查文件是否存在
    if [[ -f "/apps/prometheus/prometheus" ]]; then
        log_info "✓ Prometheus二进制文件存在"
    else
        log_error "✗ Prometheus二进制文件不存在"
        ((errors++))
    fi
    
    if [[ -f "/opt/n9e" ]]; then
        log_info "✓ 夜莺二进制文件存在"
    else
        log_error "✗ 夜莺二进制文件不存在"
        ((errors++))
    fi
    
    if [[ $errors -eq 0 ]]; then
        log_info "所有组件安装验证通过"
        return 0
    else
        log_error "发现 $errors 个问题，请检查日志"
        return 1
    fi
}

# 显示安装摘要
show_summary() {
    log_step "安装完成摘要"
    echo
    echo "==============================================="
    echo "           监控系统安装完成"
    echo "==============================================="
    echo
    echo "🔧 已安装组件:"
    echo "  • Prometheus v3.1.0 监控服务器"
    echo "  • MariaDB 数据库服务"
    echo "  • Redis 缓存服务"
    echo "  • 夜莺(N9E) v7.7.2 监控系统"
    echo
    echo "🌐 访问信息:"
    echo "  • Prometheus: http://$(hostname -I | awk '{print $1}'):9090"
    echo "    - 用户名: admin"
    echo "    - 密码: prometheus098"
    echo "  • 夜莺(N9E): http://$(hostname -I | awk '{print $1}'):17000"
    echo "    - 用户名: root"
    echo "    - 密码: root.2020"
    echo
    echo "🔑 数据库信息:"
    echo "  • MariaDB root密码: asfhieghsid232"
    echo
    echo "📝 下一步操作:"
    echo "  1. 根据文档步骤4获取正确的Prometheus配置文件"
    echo "  2. 配置夜莺监控面板和告警规则"
    echo "  3. 设置Telegram告警通知"
    echo
    echo "⚠️  安全提醒:"
    echo "  • 请及时修改默认密码"
    echo "  • 建议配置防火墙规则"
    echo "  • 定期备份配置文件"
    echo
    echo "==============================================="
}

# 主函数
main() {
    # 解析命令行参数
    parse_args "$@"
    
    log_info "开始执行监控及夜莺自动化安装脚本"
    if [[ "$AUTO_MODE" == "true" ]]; then
        log_info "运行模式：自动模式（遇到包管理器锁占用将自动处理）"
    else
        log_info "运行模式：交互模式"
    fi
    
    # 系统检查
    check_root
    check_system
    check_network
    
    # 执行安装
    install_prometheus
    install_nightingale_prep
    install_dependencies
    install_nightingale_service
    
    # 验证安装
    if verify_installation; then
        show_summary
        log_info "安装脚本执行完成！"
        exit 0
    else
        error_exit "安装过程中发现问题，请检查错误信息"
    fi
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi