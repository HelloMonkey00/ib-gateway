FROM ubuntu:22.04

# 预设时区为纽约
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York

# 设置其他环境变量
ENV VNC_PASSWORD_FILE=/etc/vnc_password
ENV VNC_PORT=5902
ENV SSH_PORT=2222
ENV IB_MAX_MEMORY=2048m

# 设置默认语言为英文，但支持中文
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# 安装必要的软件包，包括中文支持
RUN apt-get update && apt-get install -y \
    tightvncserver \
    xfce4 \
    xfce4-goodies \
    expect \
    wget \
    openssh-server \
    locales \
    fonts-noto-cjk \
    language-pack-zh-hans \
    tzdata \
    && ln -fs /usr/share/zoneinfo/$TZ /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
    && rm -rf /var/lib/apt/lists/*

# 生成本地化文件
RUN locale-gen en_US.UTF-8 && \
    locale-gen zh_CN.UTF-8 && \
    update-locale LANG=en_US.UTF-8

# 安装SSH服务
RUN mkdir /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# 创建SSH密钥目录
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh

# 复制公钥（这一步在构建时执行）
COPY id_rsa.pub /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys

# 下载IB Gateway安装文件和复制expect脚本
COPY install_ibgateway.exp /tmp/

# 运行expect脚本来安装IB Gateway
RUN wget -O /tmp/ibgateway-stable-standalone-linux-x64.sh https://download2.interactivebrokers.com/installers/ibgateway/stable-standalone/ibgateway-stable-standalone-linux-x64.sh
RUN chmod +x /tmp/ibgateway-stable-standalone-linux-x64.sh \
    && expect /tmp/install_ibgateway.exp \
    && rm /tmp/ibgateway-stable-standalone-linux-x64.sh /tmp/install_ibgateway.exp

# 复制本地VNC密码文件
COPY vnc_password.txt ${VNC_PASSWORD_FILE}
RUN chmod 400 ${VNC_PASSWORD_FILE}

# 设置VNC密码
RUN mkdir -p ~/.vnc && echo $(cat $VNC_PASSWORD_FILE) | vncpasswd -f > ~/.vnc/passwd && chmod 600 ~/.vnc/passwd

# 创建VNC启动脚本
RUN echo '#!/bin/bash\nxrdb $HOME/.Xresources\nstartxfce4 &' > ~/.vnc/xstartup && \
    chmod +x ~/.vnc/xstartup

# 复制启动脚本
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]