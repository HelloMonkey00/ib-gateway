#!/bin/bash
export DISPLAY=:99
Xvfb :99 -screen 0 1024x768x16 &
sleep 1
fluxbox &
x11vnc -forever -usepw -listen $VNC_LISTEN_ADDRESS -rfbport $VNC_PORT -listenv6 ::1 -rfbportv6 $VNC_PORT -create &

echo "Port ${SSH_PORT}" >> /etc/ssh/sshd_config

# 修改启动脚本
VMOPTIONS_FILE=$(find /root/Jts/ibgateway/ -name ibgateway.vmoptions)
sed -i "s/Xmx768m/Xmx$IB_GATEWAY_MAX_MEMORY/" "$VMOPTIONS_FILE"

# 启动SSH服务
/usr/sbin/sshd -D