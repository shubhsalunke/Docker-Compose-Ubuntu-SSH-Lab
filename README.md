# Ubuntu SSH Containers Using Docker Compose

## Objective

Create 6 Ubuntu containers with:

- SSH enabled
- Password login disabled
- SSH key login only
- Windows PC SSH access
- Container-to-container SSH access
- VS Code / CMS connection commands

Server IP:

```bash
SERVER_IP
````

---

# Step 1 — Windows PC: Copy Keys To Server

Open **PowerShell**:

```powershell
cd $HOME\.ssh
```

Copy public key:

```powershell
scp -i .\YOUR_KEY.pem .\YOUR_KEY.pub azureuser@SERVER_IP:/home/azureuser/YOUR_KEY.pub
```

Copy private key for container-to-container SSH:

```powershell
scp -i .\YOUR_KEY.pem .\YOUR_KEY.pem azureuser@SERVER_IP:/home/azureuser/container_internal_key
```

---

# Step 2 — Connect To Server

```powershell
ssh -i .\YOUR_KEY.pem azureuser@SERVER_IP
```

---

# Step 3 — Install Docker

```bash
sudo apt update
sudo apt install docker.io docker-compose-v2 -y

sudo systemctl enable docker
sudo systemctl start docker

sudo usermod -aG docker $USER
newgrp docker

docker --version
docker compose version
```

---

# Step 4 — Create Project Folder

```bash
mkdir -p ~/ubuntu-users/keys
cd ~/ubuntu-users

cp ~/YOUR_KEY.pub ~/ubuntu-users/keys/
mv ~/container_internal_key ~/ubuntu-users/container_internal_key

chmod 600 container_internal_key
ssh-keygen -y -f container_internal_key > container_internal_key.pub
```

---

# Step 5 — Build And Start Containers

```bash
docker compose up -d --build
docker ps
```

---

# Step 6 — Add Public Key To All Containers

```bash
for i in 1 2 3 4 5 6; do
  docker exec -u 0 ubuntu-user$i bash -c "cat >> /home/user$i/.ssh/authorized_keys" < container_internal_key.pub
  docker exec -u 0 ubuntu-user$i chown user$i:user$i /home/user$i/.ssh/authorized_keys
  docker exec -u 0 ubuntu-user$i chmod 600 /home/user$i/.ssh/authorized_keys
done
```

---

# Step 7 — Copy Private Key To All Containers

```bash
for i in 1 2 3 4 5 6; do
  docker cp container_internal_key ubuntu-user$i:/home/user$i/.ssh/id_rsa
  docker exec -u 0 ubuntu-user$i chown user$i:user$i /home/user$i/.ssh/id_rsa
  docker exec -u 0 ubuntu-user$i chmod 600 /home/user$i/.ssh/id_rsa
done
```

---

# Step 8 — Test SSH From Windows PC

PowerShell:

```powershell
cd $HOME\.ssh

ssh -i .\YOUR_KEY.pem user1@SERVER_IP -p 2201
ssh -i .\YOUR_KEY.pem user2@SERVER_IP -p 2202
ssh -i .\YOUR_KEY.pem user3@SERVER_IP -p 2203
ssh -i .\YOUR_KEY.pem user4@SERVER_IP -p 2204
ssh -i .\YOUR_KEY.pem user5@SERVER_IP -p 2205
ssh -i .\YOUR_KEY.pem user6@SERVER_IP -p 2206
```

---

# Step 9 — Test SSH From Server Host

```bash
cd ~/ubuntu-users

ssh -i container_internal_key user1@localhost -p 2201
ssh -i container_internal_key user2@localhost -p 2202
ssh -i container_internal_key user3@localhost -p 2203
ssh -i container_internal_key user4@localhost -p 2204
ssh -i container_internal_key user5@localhost -p 2205
ssh -i container_internal_key user6@localhost -p 2206
```

---

# Step 10 — Test Container To Container SSH

```bash
docker exec -it ubuntu-user1 bash
su - user1
```

Ping test:

```bash
ping ubuntu-user2
```

SSH test:

```bash
ssh user2@ubuntu-user2
ssh user3@ubuntu-user3
ssh user4@ubuntu-user4
ssh user5@ubuntu-user5
ssh user6@ubuntu-user6
```

---

# VS Code Remote SSH / CMS Connection

## Open SSH Config On Windows

PowerShell:

```powershell
code $HOME\.ssh\config
```

Add this config:

```text
Host user1-container
    HostName SERVER_IP
    User user1
    Port 2201
    IdentityFile C:\Users\YOUR_USERNAME\.ssh\YOUR_KEY.pem

Host user2-container
    HostName SERVER_IP
    User user2
    Port 2202
    IdentityFile C:\Users\YOUR_USERNAME\.ssh\YOUR_KEY.pem

Host user3-container
    HostName SERVER_IP
    User user3
    Port 2203
    IdentityFile C:\Users\YOUR_USERNAME\.ssh\YOUR_KEY.pem

Host user4-container
    HostName SERVER_IP
    User user4
    Port 2204
    IdentityFile C:\Users\YOUR_USERNAME\.ssh\YOUR_KEY.pem

Host user5-container
    HostName SERVER_IP
    User user5
    Port 2205
    IdentityFile C:\Users\YOUR_USERNAME\.ssh\YOUR_KEY.pem

Host user6-container
    HostName SERVER_IP
    User user6
    Port 2206
    IdentityFile C:\Users\YOUR_USERNAME\.ssh\YOUR_KEY.pem
```

---

# Useful Commands

## Check containers

```bash
docker ps
```

## Stop containers

```bash
cd ~/ubuntu-users
docker compose down
```

## Start containers

```bash
cd ~/ubuntu-users
docker compose up -d
```

## Restart containers

```bash
docker compose restart
```

## Enter container

```bash
docker exec -it ubuntu-user1 bash
```

## Check logs

```bash
docker logs ubuntu-user1
```

---

# Important Notes

Container name works only inside Docker network:

```bash
ssh user2@ubuntu-user2
```

From server host use localhost and port:

```bash
ssh -i container_internal_key user2@localhost -p 2202
```

From Windows PC use server IP and port:

```powershell
ssh -i .\YOUR_KEY.pem user2@SERVER_IP -p 2202
```
