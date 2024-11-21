#!/bin/bash

# Log the start of the deployment process
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting deployment process..."

sudo apt-get update -y
sudo apt-get upgrade -y


echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing Node Exporter..."

# Install wget if not already installed
sudo apt install wget -y

# Downloading and installing Node Exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz
tar xvfz node_exporter-1.5.0.linux-amd64.tar.gz
sudo mv node_exporter-1.5.0.linux-amd64/node_exporter /usr/local/bin/
rm -rf node_exporter-1.5.0.linux-amd64*

# Create a Node Exporter user
sudo useradd --no-create-home --shell /bin/false node_exporter

# Create a Node Exporter service file
cat << EOF | sudo tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, start and enable Node Exporter service
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

# Print the public IP address and Node Exporter port
echo "Node Exporter installation complete. It's accessible at http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):9100/metrics"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Node Exporter Installed..."


echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing Docker..."

# Installing Docker
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings -y
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER
sudo usermod -aG docker jenkins
sudo usermod -aG docker ubuntu
newgrp docker

# Installing Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo apt  install docker-compose -y
docker-compose --version

# # Start Docker service
# sudo systemctl enable docker
# sudo systemctl start docker

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Docker and Docker Compose installed."

# Log into DockerHub (Assuming credentials are passed via environment variables)
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Logging into DockerHub..."
echo "$DOCKER_PASSWORD" | sudo docker login -u "$DOCKER_USERNAME" --password-stdin

# Create docker-compose.yml

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Creating app directory..."
mkdir -p /app
cd /app

# Creating the docker-compose.yml file
cat > docker-compose.yml <<EOF
${docker_compose}
EOF

echo "[$(date '+%Y-%m-%d %H:%M:%S')] docker-compose.yml started."

sudo docker compose pull
sudo docker compose up -d --force-recreate
sudo docker system prune -f
sudo docker logout
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Logging out of DockerHub..."

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Deployment process complete."

#ecommerce-db.c30smeomyuio.us-east-2.rds.amazonaws.com:5432