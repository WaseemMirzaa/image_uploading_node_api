#!/bin/bash

# Diagnostic Script for DigitalOcean Server Issues
# Run this on your DigitalOcean server to diagnose problems

echo "🔍 4 Secrets Wedding - Server Diagnostics"
echo "========================================="
echo "Server: $(hostname -I | awk '{print $1}')"
echo "Date: $(date)"
echo ""

echo "📋 STEP 1: Basic System Check"
echo "============================="

# Check if Node.js is installed
echo "Node.js version:"
node --version 2>/dev/null || echo "❌ Node.js not installed"

# Check if PM2 is installed
echo "PM2 version:"
pm2 --version 2>/dev/null || echo "❌ PM2 not installed"

# Check if application directory exists
echo "Application directory:"
if [ -d "/var/www/4secrets-wedding-api" ]; then
    echo "✅ /var/www/4secrets-wedding-api exists"
    ls -la /var/www/4secrets-wedding-api/ | head -10
else
    echo "❌ Application directory not found"
fi

echo ""
echo "📦 STEP 2: Application Status"
echo "============================="

# Check PM2 processes
echo "PM2 processes:"
pm2 list 2>/dev/null || echo "❌ No PM2 processes or PM2 not running"

# Check if application is running
echo "Application process:"
ps aux | grep "4secrets-wedding" | grep -v grep || echo "❌ Application not running"

# Check port 3000
echo "Port 3000 status:"
netstat -tlnp | grep 3000 || echo "❌ Nothing listening on port 3000"

echo ""
echo "🔧 STEP 3: Application Files Check"
echo "=================================="

cd /var/www/4secrets-wedding-api 2>/dev/null || {
    echo "❌ Cannot access application directory"
    exit 1
}

# Check if package.json exists
echo "Package.json:"
if [ -f "package.json" ]; then
    echo "✅ package.json exists"
    echo "Main script: $(cat package.json | grep '"main"' || echo 'Not specified')"
else
    echo "❌ package.json not found"
fi

# Check if server.js exists
echo "Server file:"
if [ -f "server.js" ]; then
    echo "✅ server.js exists"
else
    echo "❌ server.js not found"
fi

# Check if .env exists
echo "Environment file:"
if [ -f ".env" ]; then
    echo "✅ .env exists"
    echo "Environment variables count: $(wc -l < .env)"
    echo "Firebase project ID: $(grep FIREBASE_PROJECT_ID .env | cut -d'=' -f2 || echo 'Not found')"
    echo "Firebase service account: $(grep -c FIREBASE_SERVICE_ACCOUNT_KEY .env || echo 'Not found')"
else
    echo "❌ .env file not found"
fi

# Check node_modules
echo "Dependencies:"
if [ -d "node_modules" ]; then
    echo "✅ node_modules exists"
    echo "Firebase admin: $(ls node_modules/ | grep firebase-admin || echo 'Not installed')"
else
    echo "❌ node_modules not found"
fi

echo ""
echo "📝 STEP 4: Application Logs"
echo "==========================="

# Check PM2 logs
echo "PM2 logs (last 20 lines):"
pm2 logs 4secrets-wedding-api --lines 20 2>/dev/null || echo "❌ No PM2 logs available"

# Check system logs for the application
echo "System logs for Node.js:"
journalctl -u pm2-root --lines 10 2>/dev/null || echo "❌ No system logs available"

echo ""
echo "🔥 STEP 5: Firebase Configuration Test"
echo "======================================"

# Test Firebase configuration
echo "Testing Firebase configuration:"
if [ -f ".env" ]; then
    source .env
    node -e "
    try {
        const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_KEY || '{}');
        if (serviceAccount.project_id) {
            console.log('✅ Firebase service account loaded');
            console.log('Project ID:', serviceAccount.project_id);
            console.log('Client Email:', serviceAccount.client_email);
        } else {
            console.log('❌ Firebase service account not found in environment');
        }
    } catch (error) {
        console.log('❌ Firebase configuration error:', error.message);
    }
    " 2>/dev/null || echo "❌ Cannot test Firebase configuration"
else
    echo "❌ No .env file to test"
fi

# Test if firebase-admin module can be loaded
echo "Testing Firebase Admin SDK:"
node -e "
try {
    require('firebase-admin');
    console.log('✅ Firebase Admin SDK can be loaded');
} catch (error) {
    console.log('❌ Firebase Admin SDK error:', error.message);
}
" 2>/dev/null || echo "❌ Cannot test Firebase Admin SDK"

echo ""
echo "🌐 STEP 6: Network & Firewall"
echo "============================="

# Check firewall status
echo "Firewall status:"
ufw status 2>/dev/null || echo "❌ UFW not available"

# Check if port 3000 is allowed
echo "Port 3000 firewall rule:"
ufw status | grep 3000 || echo "❌ Port 3000 not explicitly allowed"

# Test local connectivity
echo "Local connectivity test:"
curl -s -m 5 http://localhost:3000/health 2>/dev/null && echo "✅ Local health check passed" || echo "❌ Local health check failed"

echo ""
echo "🔧 STEP 7: Quick Fixes"
echo "======================"

echo "Suggested fixes:"
echo "1. If application not running:"
echo "   cd /var/www/4secrets-wedding-api"
echo "   pm2 start ecosystem.config.js"
echo ""
echo "2. If dependencies missing:"
echo "   cd /var/www/4secrets-wedding-api"
echo "   npm install"
echo ""
echo "3. If Firebase errors:"
echo "   Check .env file has correct FIREBASE_SERVICE_ACCOUNT_KEY"
echo ""
echo "4. If port issues:"
echo "   ufw allow 3000/tcp"
echo "   pm2 restart 4secrets-wedding-api"
echo ""
echo "5. View detailed logs:"
echo "   pm2 logs 4secrets-wedding-api --lines 50"
echo ""
echo "6. Restart everything:"
echo "   pm2 restart all"
echo "   pm2 save"
echo ""

echo "🎯 DIAGNOSIS COMPLETE"
echo "===================="
echo "Review the output above to identify issues."
echo "Run the suggested fixes and test again."
echo ""
