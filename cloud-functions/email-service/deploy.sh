#!/bin/bash
echo "🚀 Deploying 4 Secrets Wedding Email Service"
echo "============================================="

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_status() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }

# Check if .env file exists
if [ ! -f ".env" ]; then
    print_warning ".env file not found. Creating from example..."
    cp .env.example .env
    print_warning "Please edit .env file with your SMTP credentials before running the service."
fi

# Install dependencies
print_status "Installing dependencies..."
npm install

# Run tests
print_status "Running tests..."
npm test

# Start the service
print_status "Starting email service..."
echo ""
echo "📧 4 Secrets Wedding Email Service"
echo "🔗 Health Check: http://localhost:3001/health"
echo "📋 API Docs: See README.md for endpoints"
echo ""
print_status "Service starting on port 3001..."

npm start
