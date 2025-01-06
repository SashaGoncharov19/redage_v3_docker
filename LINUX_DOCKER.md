# Instruction
This instruction for installing RedAge V3 with Docker.

Tested on Ubuntu 24.04 / 4 CPU / 8 RAM / 80GB.

Minimum RAM requirement is 4GB.

## Installing Docker

```bash
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt install docker-ce
```

## Installing Docker Compose

```bash
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

## Installing git

```bash
apt install -y git
```

## Installing server

```bash
cd /media
git clone https://github.com/SashaGoncharov19/redage_v3_docker.git
cd redage_v3_docker
```

## How to start/stop server

#### Run server build with detached terminal (recommended)

```bash
docker compose up -d
```

#### Stop server (run this command inside project folder) (recommended)

```bash
docker compose down
```

#### Run server build without detached terminal

```bash
docker compose up
```