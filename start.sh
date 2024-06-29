#!/bin/bash
export DISPLAY=:99
Xvfb :99 -screen 0 1024x768x16 &
sleep 1
fluxbox &
x11vnc -forever -usepw -listen $VNC_LISTEN_ADDRESS -rfbport 5901 -create &

# 保持脚本运行，即使IB Gateway退出
while true; do
    sleep 1000
done