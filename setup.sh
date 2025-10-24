#!/bin/bash
# Setup script for HitBet iOS integration

echo "========================================="
echo "HitBet iOS Integration Setup"
echo "========================================="
echo ""

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is not installed"
    exit 1
fi

# Check if PostgreSQL is running
if ! command -v psql &> /dev/null; then
    echo "Warning: PostgreSQL command-line tool not found"
    echo "Please ensure PostgreSQL is installed and running"
fi

# Backend Setup
echo "1. Setting up Backend..."
echo ""

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo "Installing Python dependencies..."
pip install -r requirements.txt

# Check for database configuration
if [ -z "$DATABASE_URL" ]; then
    echo ""
    echo "Warning: DATABASE_URL environment variable not set"
    echo "Please set it before running the app:"
    echo "  export DATABASE_URL='postgresql://user:password@localhost/hitbet'"
    echo ""
fi

# Check for secret key
if [ -z "$SECRET_KEY" ]; then
    echo "Warning: SECRET_KEY environment variable not set"
    echo "A default key will be used (not suitable for production)"
    echo ""
fi

echo ""
echo "========================================="
echo "Backend setup complete!"
echo "========================================="
echo ""
echo "To start the backend server:"
echo "  1. Activate the virtual environment: source venv/bin/activate"
echo "  2. Set environment variables (if not already set):"
echo "     export DATABASE_URL='postgresql://user:password@localhost/hitbet'"
echo "     export SECRET_KEY='your-secret-key'"
echo "  3. Run migrations: flask db upgrade"
echo "  4. Start the server: python app.py"
echo ""
echo "The backend will be available at: http://localhost:5000"
echo "Mobile API endpoints at: http://localhost:5000/api/v1/"
echo ""
echo "========================================="
echo "iOS App Setup"
echo "========================================="
echo ""
echo "To set up the iOS app:"
echo "  1. Open ios-app/HitBetApp in Xcode"
echo "  2. Configure the API base URL in Services/APIService.swift"
echo "  3. Select your target device/simulator"
echo "  4. Build and run (⌘R)"
echo ""
echo "For more information, see:"
echo "  - API_DOCUMENTATION.md"
echo "  - IOS_INTEGRATION_GUIDE.md"
echo "  - ios-app/README.md"
echo ""
echo "========================================="
echo "Setup complete!"
echo "========================================="
