#!/bin/bash

# Log the start of the deployment process
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting deployment process..."

sudo apt-get update -y
sudo apt-get upgrade -y

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing Docker..."

# Installing Docker
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
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
newgrp docker

# Installing Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo apt  install docker-compose
docker-compose --version

# # Start Docker service
# sudo systemctl enable docker
# sudo systemctl start docker

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Docker and Docker Compose installed."

# Step 2: Log into DockerHub (Assuming credentials are passed via environment variables)
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Logging into DockerHub..."
echo "$DOCKER_PASSWORD" | sudo docker login -u "$DOCKER_USERNAME" --password-stdin

# Step 3: Create docker-compose.yml

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Creating app directory..."
mkdir -p /app
cd /app
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Created and moved to /app"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Creating docker-compose.yml..."

# Creating the docker-compose.yml file
cat > docker-compose.yml <<EOF
${docker_compose}
EOF

echo "[$(date '+%Y-%m-%d %H:%M:%S')] docker-compose.yml started."

sudo docker-compose pull
sudo docker-compose up -d --force-recreate
sudo docker system prune -f
sudo docker logout
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Logging out of DockerHub..."

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Deployment process complete."

