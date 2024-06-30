# ib-gateway

docker run -d --name ib-gateway \
  --network host \
  -e VNC_LISTEN_ADDRESS=127.0.0.1 \
  -e VNC_PORT=5902 \
  -e SSH_PORT=2222 \
  -e IB_GATEWAY_MAX_MEMORY=2048m \
  ib-gateway:latest

docker exec ib-gateway cat /etc/vnc_password


Host ibgateway
    HostName your_server_ip_or_domain
    User root
    Port 2222
    LocalForward 5902 localhost:5902
    IdentityFile ~/.ssh/id_rsa_ibgateway

ssh ibgateway

vnc://localhost:5902