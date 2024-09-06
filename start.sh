#!/bin/bash

# 设置 USER 环境变量
export USER=root

# 设置 HOME 环境变量（以防万一）
export HOME=/root

# 设置VNC密码
mkdir -p ~/.vnc
echo $(cat $VNC_PASSWORD_FILE) | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

# 确保 .Xauthority 文件存在并有正确的权限
touch ~/.Xauthority
chown root:root ~/.Xauthority
chmod 600 ~/.Xauthority

# 启动VNC服务器
tightvncserver :3 -geometry 1920x1080 -depth 24 -rfbport $VNC_PORT -localhost

# 修改IB TWS的启动配置
sed -i "s/Xmx768m/Xmx$IB_MAX_MEMORY/" /root/Jts/ibgateway/1019/ibgateway.vmoptions

# 配置SSH
echo "Port ${SSH_PORT}" >> /etc/ssh/sshd_config

# 启动SSH服务并保持容器运行
exec /usr/sbin/sshd -D