# ib-gateway

docker run -d --name ib-gateway \
  --network host \
  -e VNC_LISTEN_ADDRESS=0.0.0.0 \
  -e IB_GATEWAY_MAX_MEMORY=2048m \
  ib-gateway:latest

docker exec ib-gateway cat /etc/vnc_password