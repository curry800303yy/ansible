#!/bin/bash

version=1.0.0
service_name=mcdn-agent-py
current_dir=`pwd`

echo "Version: $version"
echo "Service dir: $current_dir"

step=0

((step++))
echo "Step $step. Stopping $service_name services..."
systemctl disable $service_name 2>/dev/null || true
systemctl stop $service_name 2>/dev/null || true
rm -f /lib/systemd/system/$service_name.service
systemctl daemon-reload
echo "  Stopped $service_name.service successfully"

((step++))
echo "Step $step. Installing $service_name services..."
chmod +x startup.sh
sed "s|{service_dir}|$current_dir|g" $service_name.service > /lib/systemd/system/$service_name.service
systemctl daemon-reload
echo "  Updated $current_dir/ successfully."

((step++))
echo "Step $step. Starting $service_name services..."
systemctl enable $service_name
systemctl start $service_name
echo "  Started $service_name.service successfully"
