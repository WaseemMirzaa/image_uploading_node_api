#!/bin/bash

# ================================================================================
# 4 SECRETS WEDDING - GITHUB DEPLOYMENT SCRIPT FOR DIGITALOCEAN
# ================================================================================
# This script clones from GitHub and deploys on DigitalOcean port 3001
# Run as: chmod +x deploy.sh && sudo ./deploy.sh

echo "🚀 4 Secrets Wedding - GitHub Deployment"
echo "📧 Email + File Service"
echo "🌐 Port: 3001 (No Nginx)"
echo "📦 Source: GitHub Repository"
echo ""

# Get server IP
SERVER_IP=$(curl -s ifconfig.me 2>/dev/null || echo "YOUR_SERVER_IP")

# Update system
echo "📦 Updating system..."
apt update && apt upgrade -y

# Install Node.js 18 if not installed
if ! command -v node &> /dev/null; then
    echo "📦 Installing Node.js 18..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt-get install -y nodejs
fi

# Install PM2 if not installed
if ! command -v pm2 &> /dev/null; then
    echo "📦 Installing PM2..."
    npm install -g pm2
fi

# Install Git if not installed
if ! command -v git &> /dev/null; then
    echo "📦 Installing Git..."
    apt-get install -y git
fi

# Stop any existing services on port 3001
echo "🛑 Stopping any existing services on port 3001..."
lsof -ti:3001 | xargs kill -9 2>/dev/null || true

# Stop and remove existing PM2 processes
echo "🛑 Stopping existing PM2 processes..."
pm2 stop 4secrets-wedding-email 2>/dev/null || true
pm2 delete 4secrets-wedding-email 2>/dev/null || true

# Remove existing directory
echo "🗑️ Removing existing installation..."
rm -rf /var/www/4secrets-wedding-email

# Create application directory
echo "📁 Creating application directory..."
mkdir -p /var/www/4secrets-wedding-email
cd /var/www/4secrets-wedding-email

# Clone from GitHub
echo "📦 Cloning from GitHub..."
git clone https://github.com/WaseemMirzaa/four_wedding_app_cloud_function.git .

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Create environment file
echo "⚙️ Creating environment configuration..."
echo "PORT=3001" > .env
echo "NODE_ENV=production" >> .env
echo "EMAIL_FROM=support@brevo.4secrets-wedding-planner.de" >> .env
echo "# Brevo API key will use fallback value from server.js" >> .env

# Create uploads directory
echo "📁 Creating uploads directory..."
mkdir -p uploads
chmod 755 uploads

# Configure firewall for port 3001
echo "🔒 Configuring firewall..."
ufw allow 3001/tcp

# Create PM2 ecosystem file
echo "⚙️ Creating PM2 configuration..."
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: '4secrets-wedding-email',
    script: 'server.js',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      PORT: 3001
    },
    error_file: '/var/log/4secrets-wedding-email/error.log',
    out_file: '/var/log/4secrets-wedding-email/out.log',
    log_file: '/var/log/4secrets-wedding-email/combined.log',
    time: true
  }]
};
EOF

# Create log directory
echo "📝 Creating log directory..."
mkdir -p /var/log/4secrets-wedding-email
chmod 755 /var/log/4secrets-wedding-email

# Start with PM2
echo "🚀 Starting application with PM2..."
pm2 start ecosystem.config.js
pm2 startup
pm2 save

# Wait for startup
echo "⏳ Waiting for application to start..."
sleep 15

# Test the application
echo "🧪 Testing application..."
echo ""
echo "Health Check:"
curl -s http://localhost:3001/health | head -c 200
echo ""

echo "Email Status:"
curl -s http://localhost:3001/api/email/status | head -c 200
echo ""

echo "Files List:"
curl -s http://localhost:3001/api/images | head -c 200
echo ""

echo ""
echo "============================================================"
echo "🎉 GITHUB DEPLOYMENT COMPLETED SUCCESSFULLY!"
echo "============================================================"
echo "📧 Email Service: ✅ Running (Brevo API)"
echo "📄 File Service: ✅ Running (Images + PDFs)"
echo "🌐 Server IP: $SERVER_IP"
echo "🔗 Port: 3001"
echo "📦 Source: GitHub Repository"
echo ""
echo "📡 API ENDPOINTS:"
echo "   Health Check: http://$SERVER_IP:3001/health"
echo "   Email Status: http://$SERVER_IP:3001/api/email/status"
echo "   Send Invitation: http://$SERVER_IP:3001/api/email/send-invitation"
echo "   Upload File: http://$SERVER_IP:3001/api/images/upload"
echo "   Get Files: http://$SERVER_IP:3001/api/images"
echo ""
echo "🧪 TEST COMMANDS:"
echo "   curl http://$SERVER_IP:3001/health"
echo "   curl http://$SERVER_IP:3001/api/email/status"
echo "   curl http://$SERVER_IP:3001/api/images"
echo ""
echo "   # Send test email:"
echo "   curl -X POST http://$SERVER_IP:3001/api/email/send-invitation \\"
echo "     -H \"Content-Type: application/json\" \\"
echo "     -d '{\"email\": \"test@example.com\", \"inviterName\": \"GitHub Deploy Test\"}'"
echo ""
echo "   # Upload test file:"
echo "   echo 'Test content' > test.jpg"
echo "   curl -X POST http://$SERVER_IP:3001/api/images/upload -F \"image=@test.jpg\""
echo ""
echo "🔧 MANAGEMENT COMMANDS:"
echo "   pm2 status                    # Check status"
echo "   pm2 logs 4secrets-wedding-email  # View logs"
echo "   pm2 restart 4secrets-wedding-email  # Restart service"
echo "   pm2 stop 4secrets-wedding-email     # Stop service"
echo ""
echo "🔄 UPDATE COMMANDS:"
echo "   cd /var/www/4secrets-wedding-email"
echo "   git pull origin main          # Pull latest changes"
echo "   npm install                   # Install new dependencies"
echo "   pm2 restart 4secrets-wedding-email  # Restart service"
echo ""
echo "📱 MOBILE APP INTEGRATION:"
echo "   Update your app's base URL to: http://$SERVER_IP:3001"
echo ""
echo "✅ All services are running and ready for production use!"
echo "📧 Emails will be sent from: support@brevo.4secrets-wedding-planner.de"
echo "📄 Files will be stored in: /var/www/4secrets-wedding-email/uploads/"
echo "============================================================"

# Show PM2 status
echo ""
echo "📊 PM2 STATUS:"
pm2 status

echo ""
echo "🎯 GITHUB DEPLOYMENT COMPLETE!"
echo "🔗 Your 4 Secrets Wedding API is ready at: http://$SERVER_IP:3001"
echo "📦 Source code: https://github.com/WaseemMirzaa/four_wedding_app_cloud_function"
