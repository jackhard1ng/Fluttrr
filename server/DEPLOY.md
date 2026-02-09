# Fluttrr Backend - Deployment Guide for Hostinger VPS

Your VPS: `srv783688.hstgr.cloud` (82.180.139.134)
Domain: `api.fluttrr.com` -> points to 82.180.139.134 (configured in GoDaddy)

## Step 1: SSH into your VPS

Open the Hostinger VPS terminal (or SSH from your computer):
```bash
ssh root@82.180.139.134
```

## Step 2: Install MongoDB

```bash
# Import MongoDB public key
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor

# Add MongoDB repository
echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

# Install MongoDB
sudo apt-get update
sudo apt-get install -y mongodb-org

# Start MongoDB and enable on boot
sudo systemctl start mongod
sudo systemctl enable mongod

# Verify it's running
sudo systemctl status mongod
```

## Step 3: Upload the server code

Option A - Using Git (recommended):
```bash
cd /home/ubuntu
git clone https://github.com/jackhard1ng/Fluttrr.git
cd Fluttrr/server
```

Option B - Upload files manually via SCP:
```bash
# From your local machine:
scp -r server/ root@82.180.139.134:/home/ubuntu/fluttrr-api/
```

## Step 4: Install dependencies

```bash
cd /home/ubuntu/Fluttrr/server   # or wherever you put it
npm install
```

## Step 5: Create .env file

```bash
cp .env.example .env
nano .env
```

Edit the `.env` file with your values:
```
PORT=3000
NODE_ENV=production
MONGODB_URI=mongodb://localhost:27017/fluttrr
JWT_SECRET=generate-a-long-random-string-here
JWT_REFRESH_SECRET=generate-another-long-random-string-here
JWT_EXPIRES_IN=7d
JWT_REFRESH_EXPIRES_IN=30d

# Email - for sending OTPs (optional for now, will log to console if not set)
# SMTP_HOST=smtp.gmail.com
# SMTP_PORT=587
# SMTP_USER=your-email@gmail.com
# SMTP_PASS=your-app-password
# EMAIL_FROM=noreply@fluttrr.com
```

Generate random secrets:
```bash
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
```

## Step 6: Test the server

```bash
node server.js
```

You should see:
```
Fluttrr API server running on port 3000
MongoDB connected: localhost
```

Test it: Visit `http://82.180.139.134:3000/` in your browser - you should see:
```json
{"status":"ok","message":"Fluttrr API is running","version":"1.0.0"}
```

Press Ctrl+C to stop.

## Step 7: Install PM2 (keeps server running)

```bash
npm install -g pm2
pm2 start server.js --name fluttrr-api
pm2 save
pm2 startup   # Follow the instructions it prints
```

## Step 8: Set up SSL with Let's Encrypt (REQUIRED for the app to work)

The Flutter app uses HTTPS, so you need SSL.

```bash
# Install certbot
sudo apt-get install -y certbot

# Get SSL certificate for api.fluttrr.com
sudo certbot certonly --standalone -d api.fluttrr.com --email your-email@gmail.com --agree-tos

# The certificates will be at:
# /etc/letsencrypt/live/api.fluttrr.com/fullchain.pem
# /etc/letsencrypt/live/api.fluttrr.com/privkey.pem
```

## Step 9: Set up Nginx as reverse proxy

```bash
sudo apt-get install -y nginx

# Create Nginx config
sudo nano /etc/nginx/sites-available/fluttrr-api
```

Paste this configuration:
```nginx
server {
    listen 80;
    server_name api.fluttrr.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name api.fluttrr.com;

    ssl_certificate /etc/letsencrypt/live/api.fluttrr.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.fluttrr.com/privkey.pem;

    # SSL settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;

    # Max upload size
    client_max_body_size 10M;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Serve uploaded files
    location /uploads {
        alias /home/ubuntu/Fluttrr/server/uploads;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
```

Enable it:
```bash
sudo ln -s /etc/nginx/sites-available/fluttrr-api /etc/nginx/sites-enabled/
sudo nginx -t          # Test config
sudo systemctl restart nginx
sudo systemctl enable nginx
```

**IMPORTANT:** If OpenLiteSpeed is running and using port 80/443, stop it first:
```bash
sudo systemctl stop lsws
sudo systemctl disable lsws
```

## Step 10: Open firewall ports (if needed)

Your VPS already has ports 22, 80, 443 open. If you need port 3000 directly:
```bash
sudo ufw allow 3000
```

## Step 11: Set up auto-renewal for SSL

```bash
sudo certbot renew --dry-run  # Test renewal
```

Certbot auto-renewal should already be set up. Verify:
```bash
sudo systemctl status certbot.timer
```

## Step 12: Verify everything works

1. Visit `https://api.fluttrr.com/` - should show the API status
2. Visit `https://api.fluttrr.com/api/health` - should show health check
3. Open your Flutter app and try to log in

## Troubleshooting

### Check if server is running:
```bash
pm2 status
pm2 logs fluttrr-api
```

### Check MongoDB:
```bash
sudo systemctl status mongod
mongosh   # Open MongoDB shell
```

### Check Nginx:
```bash
sudo nginx -t
sudo systemctl status nginx
sudo tail -f /var/log/nginx/error.log
```

### Restart everything:
```bash
sudo systemctl restart mongod
pm2 restart fluttrr-api
sudo systemctl restart nginx
```
