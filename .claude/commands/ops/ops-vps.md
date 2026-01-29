# Agent VPS

Deploiement sur serveur VPS (OVH, Hetzner, DigitalOcean, Scaleway, etc.).

## Cible
$ARGUMENTS

## Modes d'utilisation

### Mode 1 : Deploiement initial
Configure un nouveau serveur et deploie l'application.

### Mode 2 : Mise a jour
Deploie une nouvelle version de l'application.

### Mode 3 : Configuration Nginx/Caddy
Configure le reverse proxy avec SSL.

### Mode 4 : Automatisation avec Ansible
Configure le deploiement automatise.

---

## Configuration Initiale du Serveur

### 1. Securisation de base
```bash
# Connexion initiale
ssh root@your-server-ip

# Mise a jour du systeme
apt update && apt upgrade -y

# Creer un utilisateur non-root
adduser deploy
usermod -aG sudo deploy

# Configurer SSH
mkdir -p /home/deploy/.ssh
cp ~/.ssh/authorized_keys /home/deploy/.ssh/
chown -R deploy:deploy /home/deploy/.ssh
chmod 700 /home/deploy/.ssh
chmod 600 /home/deploy/.ssh/authorized_keys

# Desactiver connexion root et mot de passe
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd
```

### 2. Firewall
```bash
# UFW (Ubuntu/Debian)
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow http
ufw allow https
ufw enable

# Verifier
ufw status
```

### 3. Fail2ban
```bash
apt install fail2ban -y

# Configuration
cat > /etc/fail2ban/jail.local << EOF
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
EOF

systemctl enable fail2ban
systemctl start fail2ban
```

---

## Deploiement avec Docker

### Installation Docker

> **Securite**: Le pattern `curl | sh` execute du code distant sans verification.
> En production, preferez telecharger le script, verifier son contenu/checksum, puis executer:
> ```bash
> curl -fsSL https://get.docker.com -o install-docker.sh
> # Verifier le contenu du script avant execution
> sh install-docker.sh
> rm -f install-docker.sh
> ```

```bash
# Installation
curl -fsSL https://get.docker.com | sh
usermod -aG docker deploy

# Docker Compose
apt install docker-compose-plugin -y
```

### docker-compose.yml (Production)
```yaml
version: '3.8'

services:
  app:
    image: ghcr.io/username/app:latest
    restart: unless-stopped
    environment:
      - NODE_ENV=production
      - DATABASE_URL=${DATABASE_URL}
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  db:
    image: postgres:16-alpine
    restart: unless-stopped
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_DB=${POSTGRES_DB}
    networks:
      - app-network

  caddy:
    image: caddy:2-alpine
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
      - caddy_config:/config
    networks:
      - app-network

volumes:
  postgres_data:
  caddy_data:
  caddy_config:

networks:
  app-network:
    driver: bridge
```

### Caddyfile (SSL automatique)
```
app.example.com {
    reverse_proxy app:3000
    encode gzip

    header {
        # Security headers
        Strict-Transport-Security "max-age=31536000; includeSubDomains"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "DENY"
        Referrer-Policy "strict-origin-when-cross-origin"
    }
}
```

---

## Deploiement sans Docker

### Node.js avec PM2
```bash
# Installation Node.js
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
apt install nodejs -y

# Installation PM2
npm install -g pm2

# Deployer l'application
cd /var/www/app
npm ci --production
npm run build

# Lancer avec PM2
pm2 start dist/index.js --name app
pm2 save
pm2 startup
```

### ecosystem.config.js (PM2)
```javascript
module.exports = {
  apps: [{
    name: 'app',
    script: 'dist/index.js',
    instances: 'max',
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    error_file: '/var/log/pm2/app-error.log',
    out_file: '/var/log/pm2/app-out.log',
    time: true
  }]
};
```

### Python avec Gunicorn
```bash
# Installation
apt install python3-pip python3-venv -y

# Setup
cd /var/www/app
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# Gunicorn
pip install gunicorn
gunicorn app:app -w 4 -b 127.0.0.1:8000 --daemon

# Systemd service
cat > /etc/systemd/system/app.service << EOF
[Unit]
Description=App
After=network.target

[Service]
User=deploy
Group=deploy
WorkingDirectory=/var/www/app
Environment="PATH=/var/www/app/.venv/bin"
ExecStart=/var/www/app/.venv/bin/gunicorn app:app -w 4 -b 127.0.0.1:8000

[Install]
WantedBy=multi-user.target
EOF

systemctl enable app
systemctl start app
```

### Go
```bash
# Build sur la machine de dev
GOOS=linux GOARCH=amd64 go build -o app

# Deployer le binaire
scp app deploy@server:/var/www/app/

# Systemd service
cat > /etc/systemd/system/app.service << EOF
[Unit]
Description=Go App
After=network.target

[Service]
User=deploy
Group=deploy
WorkingDirectory=/var/www/app
ExecStart=/var/www/app/app
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl enable app
systemctl start app
```

---

## Nginx Configuration

### Installation
```bash
apt install nginx -y
systemctl enable nginx
```

### Configuration site
```nginx
# /etc/nginx/sites-available/app
server {
    listen 80;
    server_name app.example.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name app.example.com;

    # SSL (Let's Encrypt)
    ssl_certificate /etc/letsencrypt/live/app.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/app.example.com/privkey.pem;

    # SSL Configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;
    ssl_prefer_server_ciphers off;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "DENY" always;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### SSL avec Certbot
```bash
# Installation
apt install certbot python3-certbot-nginx -y

# Obtenir le certificat
certbot --nginx -d app.example.com

# Renouvellement automatique (deja configure)
certbot renew --dry-run
```

---

## Automatisation CI/CD

### Script de deploiement
```bash
#!/bin/bash
# deploy.sh

set -e

APP_DIR="/var/www/app"
REPO="git@github.com:username/app.git"

echo "==> Pulling latest changes..."
cd $APP_DIR
git pull origin main

echo "==> Installing dependencies..."
npm ci --production

echo "==> Building..."
npm run build

echo "==> Restarting app..."
pm2 restart app

echo "==> Done!"
```

### GitHub Actions
```yaml
# .github/workflows/deploy.yml
name: Deploy to VPS

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy via SSH
        uses: appleboy/ssh-action@v1.0.3
        with:
          host: ${{ secrets.VPS_HOST }}
          username: ${{ secrets.VPS_USER }}
          key: ${{ secrets.VPS_SSH_KEY }}
          script: |
            cd /var/www/app
            git pull origin main
            npm ci --production
            npm run build
            pm2 restart app
```

### Deploiement Docker via SSH
```yaml
# .github/workflows/deploy-docker.yml
name: Deploy Docker to VPS

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Login to GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ghcr.io/${{ github.repository }}:latest

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Deploy via SSH
        uses: appleboy/ssh-action@v1.0.3
        with:
          host: ${{ secrets.VPS_HOST }}
          username: ${{ secrets.VPS_USER }}
          key: ${{ secrets.VPS_SSH_KEY }}
          script: |
            cd /var/www/app
            docker compose pull
            docker compose up -d --remove-orphans
            docker image prune -f
```

---

## Ansible (Automatisation complete)

### Inventaire
```ini
# inventory.ini
[webservers]
app1 ansible_host=1.2.3.4 ansible_user=deploy

[all:vars]
ansible_python_interpreter=/usr/bin/python3
```

### Playbook de deploiement
```yaml
# deploy.yml
---
- hosts: webservers
  become: yes
  vars:
    app_dir: /var/www/app
    app_repo: git@github.com:username/app.git

  tasks:
    - name: Pull latest code
      git:
        repo: "{{ app_repo }}"
        dest: "{{ app_dir }}"
        version: main
        force: yes

    - name: Install dependencies
      npm:
        path: "{{ app_dir }}"
        production: yes

    - name: Build application
      command: npm run build
      args:
        chdir: "{{ app_dir }}"

    - name: Restart PM2
      command: pm2 restart app
      become_user: deploy
```

### Execution
```bash
# Deployer
ansible-playbook -i inventory.ini deploy.yml

# Ping tous les serveurs
ansible all -i inventory.ini -m ping
```

---

## Monitoring

### Commandes utiles
```bash
# Logs systemd
journalctl -u app -f

# Logs PM2
pm2 logs app

# Logs Docker
docker compose logs -f

# Ressources
htop
df -h
free -m
```

### Uptime monitoring
```bash
# Installation simple avec cron
(crontab -l 2>/dev/null; echo "*/5 * * * * curl -s https://uptime.example.com/ping/abc123") | crontab -
```

---

## Checklist Deploiement

### Securite
- [ ] Connexion SSH par cle uniquement
- [ ] Root login desactive
- [ ] Firewall configure (UFW)
- [ ] Fail2ban installe
- [ ] SSL/TLS configure
- [ ] Headers de securite

### Application
- [ ] Variables d'environnement configurees
- [ ] Process manager configure (PM2, systemd)
- [ ] Logs centralises
- [ ] Health check endpoint

### Backup
- [ ] Backup base de donnees automatise
- [ ] Backup fichiers uploades
- [ ] Test de restauration effectue

---

## Providers VPS populaires

| Provider | Prix minimal | Avantages |
|----------|--------------|-----------|
| **OVH** | ~3.50/mois | Datacenters EU, bon support FR |
| **Hetzner** | ~4/mois | Excellent rapport qualite/prix |
| **DigitalOcean** | $6/mois | Interface simple, bonne doc |
| **Scaleway** | ~2/mois | Datacenters FR, Kubernetes facile |
| **Vultr** | $5/mois | Beaucoup de locations |
| **Linode** | $5/mois | Support 24/7 |

---

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/docker` | Containeriser l'application |
| `/ci` | Pipeline CI/CD |
| `/monitoring` | Monitoring et alertes |
| `/backup` | Strategie de sauvegarde |
| `/secrets-management` | Gestion des credentials |

---

IMPORTANT: Toujours sauvegarder avant une mise a jour majeure.

IMPORTANT: Tester les deploiements sur un environnement de staging d'abord.

YOU MUST configurer des backups automatiques pour les donnees.

NEVER exposer des services sans authentification ou firewall.
