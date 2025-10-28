#!/bin/bash

# Firebase Security Rules Test Script
# This script runs security tests using Firebase Emulator Suite

set -e

echo "🔒 Firebase Security Rules Testing"
echo "=================================="
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js >= 18.0.0"
    exit 1
fi

# Check Node.js version
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo "❌ Node.js version must be >= 18.0.0 (current: $(node -v))"
    exit 1
fi

echo "✓ Node.js version: $(node -v)"

# Check if dependencies are installed
if [ ! -d "node_modules" ]; then
    echo ""
    echo "📦 Installing dependencies..."
    if command -v yarn &> /dev/null; then
        yarn install
    else
        npm install
    fi
fi

echo ""
echo "🚀 Starting Firebase Emulators and running tests..."
echo ""

# Run the tests
if command -v yarn &> /dev/null; then
    yarn test:security
else
    npm run test:security
fi

echo ""
echo "✅ Security tests completed successfully!"
