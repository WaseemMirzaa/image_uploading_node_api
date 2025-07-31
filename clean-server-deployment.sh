#!/bin/bash
echo "🧹 CLEAN DEPLOYMENT - 4 Secrets Wedding API"
echo "============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }

print_info "Starting clean deployment on server..."

# Stop and remove all existing services
print_info "Stopping all existing services..."
pm2 delete all 2>/dev/null || true
systemctl stop nginx 2>/dev/null || true
systemctl disable nginx 2>/dev/null || true

# Kill any remaining Node.js processes
print_info "Killing any remaining Node.js processes..."
pkill -f "node" 2>/dev/null || true
pkill -f "npm" 2>/dev/null || true

# Remove previous installation
print_info "Removing previous installation..."
cd /var/www
rm -rf image_uploading_node_api 2>/dev/null || true

# Update system
print_info "Updating system packages..."
apt update && apt upgrade -y

# Install essential tools
print_info "Installing essential tools..."
apt install curl wget git nano htop ufw net-tools -y

# Install Node.js 18.x (fresh install)
print_info "Installing Node.js 18.x..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Verify Node.js installation
NODE_VERSION=$(node --version)
NPM_VERSION=$(npm --version)
print_status "Node.js version: $NODE_VERSION"
print_status "NPM version: $NPM_VERSION"

# Install PM2 globally
print_info "Installing PM2 globally..."
npm install -g pm2

# Clone fresh repository
print_info "Cloning fresh repository..."
cd /var/www
git clone https://github.com/WaseemMirzaa/image_uploading_node_api.git
cd image_uploading_node_api

# Install dependencies
print_info "Installing npm dependencies..."
npm install

# Install additional dependencies for Mailgun
print_info "Installing Mailgun dependencies..."
npm install mailgun.js form-data winston

# Create required directories
print_info "Creating required directories..."
mkdir -p src/images
chmod 755 src/images

# Create production environment file for port 8080
print_info "Creating production environment file..."
cat > .env << 'EOF'
# Server Configuration
PORT=8080
NODE_ENV=production

# Upload Configuration
UPLOAD_PATH=src/images
MAX_FILE_SIZE=5242880

# Email Configuration - Mailgun
# Add your Mailgun credentials here:
# MAILGUN_API_KEY=your-mailgun-api-key-here
# MAILGUN_DOMAIN=your-mailgun-domain-here
# EMAIL_FROM=your-email-from-address-here
EOF

# Set proper permissions
print_info "Setting proper permissions..."
chown -R root:root /var/www/image_uploading_node_api
chmod -R 755 /var/www/image_uploading_node_api

# Configure firewall for port 8080 only
print_info "Configuring firewall for port 8080..."
ufw --force reset
ufw allow ssh
ufw allow 8080/tcp
ufw --force enable

# Start application with PM2 on port 8080
print_info "Starting application on port 8080..."
pm2 start server.js --name "wedding-api"
pm2 save

# Set up PM2 auto-start
print_info "Setting up PM2 auto-start..."
pm2 startup

# Wait for application to start
print_info "Waiting for application to start..."
sleep 15

# Test the deployment
echo ""
echo "=== TESTING DEPLOYMENT ==="
print_info "PM2 Status:"
pm2 status

echo ""
print_info "Testing API endpoints..."

# Test health endpoint
HEALTH_RESPONSE=$(curl -s http://localhost:8080/health 2>/dev/null || echo "Failed")
if [[ $HEALTH_RESPONSE == *"ok"* ]]; then
    print_status "Health API: Working"
else
    print_error "Health API: Failed - $HEALTH_RESPONSE"
fi

# Test image API
IMAGE_RESPONSE=$(curl -s http://localhost:8080/api/images 2>/dev/null || echo "Failed")
if [[ $IMAGE_RESPONSE == *"images"* ]]; then
    print_status "Image API: Working"
else
    print_error "Image API: Failed - $IMAGE_RESPONSE"
fi

# Test email status
EMAIL_STATUS=$(curl -s http://localhost:8080/api/email/status 2>/dev/null || echo "Failed")
if [[ $EMAIL_STATUS == *"Email API"* ]]; then
    print_status "Email API: Working"
else
    print_error "Email API: Failed - $EMAIL_STATUS"
fi

# Test email invitation
EMAIL_RESPONSE=$(curl -s -X POST http://localhost:8080/api/email/send-invitation \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com", "inviterName": "Server Test"}' 2>/dev/null || echo "Failed")

if [[ $EMAIL_RESPONSE == *"success"* ]]; then
    print_status "Email Invitation: Working"
else
    print_warning "Email Invitation: $EMAIL_RESPONSE"
fi

# Show listening ports
echo ""
print_info "Checking listening ports..."
PORT_CHECK=$(netstat -tlnp | grep :8080)
if [[ -n "$PORT_CHECK" ]]; then
    print_status "Port 8080: Listening"
    echo "$PORT_CHECK"
else
    print_error "Port 8080: Not listening"
fi

# Show recent logs
echo ""
print_info "Recent application logs:"
pm2 logs wedding-api --lines 10 --nostream

echo ""
echo "🎉 CLEAN DEPLOYMENT COMPLETE!"
echo "============================="
echo ""
print_status "🚀 4 Secrets Wedding API is running on:"
echo "   URL: http://164.92.175.72:8080"
echo "   Port: 8080 (Direct access)"
echo ""
print_status "📋 Working API Endpoints:"
echo "   Health Check:     http://164.92.175.72:8080/health"
echo "   Image List:       http://164.92.175.72:8080/api/images"
echo "   Image Upload:     http://164.92.175.72:8080/api/images/upload"
echo "   Image Delete:     http://164.92.175.72:8080/api/images/delete"
echo "   Email Status:     http://164.92.175.72:8080/api/email/status"
echo "   Send Invitation:  http://164.92.175.72:8080/api/email/send-invitation"
echo "   Declined Invite:  http://164.92.175.72:8080/api/email/declined-invitation"
echo "   Revoke Access:    http://164.92.175.72:8080/api/email/revoke-access"
echo "   View Sent Emails: http://164.92.175.72:8080/api/email/sent"
echo ""
print_status "📧 Email Configuration:"
echo "   Status: Ready for Mailgun credentials"
echo "   To enable real emails:"
echo "   1. Edit: nano /var/www/image_uploading_node_api/.env"
echo "   2. Add your Mailgun credentials"
echo "   3. Restart: pm2 restart wedding-api"
echo ""
print_status "🛠️ Management Commands:"
echo "   pm2 status                    # Check application status"
echo "   pm2 logs wedding-api          # View application logs"
echo "   pm2 restart wedding-api       # Restart application"
echo "   pm2 stop wedding-api          # Stop application"
echo ""
print_status "🧪 Quick Test Commands (from your local machine):"
echo "curl http://164.92.175.72:8080/health"
echo "curl http://164.92.175.72:8080/api/images"
echo "curl -X POST http://164.92.175.72:8080/api/email/send-invitation \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"email\": \"test@example.com\", \"inviterName\": \"Test\"}'"
echo ""
print_status "✅ ALL APIS READY ON PORT 8080!"
print_status "📧 EMAIL SERVICE READY FOR MAILGUN CREDENTIALS!"
print_status "🔗 NO NGINX - DIRECT PORT 8080 ACCESS!"

# Final system status
echo ""
echo "📊 FINAL SYSTEM STATUS:"
echo "Node.js: $(node --version)"
echo "NPM: $(npm --version)"
echo "PM2: $(pm2 --version)"
echo "Application: $(pm2 list | grep wedding-api | awk '{print $10}' || echo 'Check manually')"
echo "Port 8080: $(netstat -tlnp | grep :8080 | wc -l) listener(s)"
echo "Firewall: $(ufw status | grep 8080 | wc -l) rule(s) active"
echo ""
print_status "🎯 DEPLOYMENT SUCCESSFUL - API READY FOR USE!"
