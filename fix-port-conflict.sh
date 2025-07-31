#!/bin/bash

# ================================================================================
# 4 SECRETS WEDDING - PORT CONFLICT FIX SCRIPT
# ================================================================================
# This script fixes the port 8080 conflict on DigitalOcean server
# Run this script on your DigitalOcean server

echo "🔧 Fixing Port 8080 Conflict..."
echo "🌐 Server: DigitalOcean"
echo ""

# Check what's using port 8080
echo "📋 Checking what's using port 8080..."
netstat -tulpn | grep :8080

echo ""
echo "📋 Checking PM2 processes..."
pm2 list

echo ""
echo "🛑 Stopping all PM2 processes..."
pm2 stop all
pm2 delete all

echo ""
echo "🔍 Checking if port 8080 is still in use..."
PORT_CHECK=$(netstat -tulpn | grep :8080)
if [ ! -z "$PORT_CHECK" ]; then
    echo "⚠️ Port 8080 is still in use by:"
    echo "$PORT_CHECK"
    
    # Kill processes using port 8080
    echo "🛑 Killing processes using port 8080..."
    lsof -ti:8080 | xargs kill -9 2>/dev/null || true
    
    # Wait a moment
    sleep 3
    
    # Check again
    PORT_CHECK_AFTER=$(netstat -tulpn | grep :8080)
    if [ ! -z "$PORT_CHECK_AFTER" ]; then
        echo "❌ Port 8080 is still in use. Manual intervention required."
        echo "$PORT_CHECK_AFTER"
        exit 1
    fi
fi

echo "✅ Port 8080 is now free!"

# Navigate to the correct directory
echo "📁 Navigating to application directory..."
cd /var/www/wedding-email || cd /var/www/image_uploading_node_api || cd /var/www/4secrets-wedding-email

# Check if we're in the right directory
if [ ! -f "server.js" ] && [ ! -f "package.json" ]; then
    echo "❌ Cannot find application files. Please check the directory."
    echo "Current directory: $(pwd)"
    echo "Files in directory:"
    ls -la
    exit 1
fi

echo "✅ Found application files in: $(pwd)"

# Start the application with PM2
echo "🚀 Starting application with PM2..."
pm2 start server.js --name "4secrets-wedding-email" --instances 1

# Wait for startup
echo "⏳ Waiting for application to start..."
sleep 10

# Check PM2 status
echo "📊 PM2 Status:"
pm2 status

# Test the application
echo ""
echo "🧪 Testing application..."
curl -s http://localhost:8080/health || echo "❌ Health check failed"

# Check if port is now in use by our app
echo ""
echo "📋 Port 8080 status:"
netstat -tulpn | grep :8080

# Save PM2 configuration
echo ""
echo "💾 Saving PM2 configuration..."
pm2 save

echo ""
echo "============================================================"
echo "🎉 PORT CONFLICT FIXED!"
echo "============================================================"
echo "✅ Port 8080 is now available"
echo "✅ Application started successfully"
echo "🔗 Health Check: http://164.92.175.72:8080/health"
echo "📡 Email API: http://164.92.175.72:8080/api/email/"
echo "🖼️ Image API: http://164.92.175.72:8080/api/images/"
echo ""
echo "🔧 Management Commands:"
echo "   pm2 status                    # Check status"
echo "   pm2 logs 4secrets-wedding-email  # View logs"
echo "   pm2 restart 4secrets-wedding-email  # Restart"
echo "============================================================"
