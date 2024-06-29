FROM ubuntu:20.04

# 设置环境变量
ENV VNC_LISTEN_ADDRESS=127.0.0.1
ENV VNC_PASSWORD_FILE=/etc/vnc_password
ENV IB_GATEWAY_MAX_MEMORY=1024m
ENV VNC_PORT=5901

# 安装必要的软件包
RUN apt-get update && apt-get install -y \
    x11vnc \
    xvfb \
    fluxbox \
    pwgen \
    expect \
    wget \
    && rm -rf /var/lib/apt/lists/*

# 下载IB Gateway安装文件和复制expect脚本
COPY install_ibgateway.exp /tmp/

# 运行expect脚本来安装IB Gateway
RUN wget -O /tmp/ibgateway-stable-standalone-linux-x64.sh https://download2.interactivebrokers.com/installers/ibgateway/stable-standalone/ibgateway-stable-standalone-linux-x64.sh
RUN chmod +x /tmp/ibgateway-stable-standalone-linux-x64.sh \
    && expect /tmp/install_ibgateway.exp \
    && rm /tmp/ibgateway-stable-standalone-linux-x64.sh /tmp/install_ibgateway.exp

# 生成随机VNC密码并保存到只读文件
RUN pwgen -s 20 1 > $VNC_PASSWORD_FILE \
    && chmod 400 $VNC_PASSWORD_FILE

# 设置VNC密码
RUN mkdir ~/.vnc && x11vnc -storepasswd $(cat $VNC_PASSWORD_FILE) ~/.vnc/passwd

# 复制启动脚本
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]