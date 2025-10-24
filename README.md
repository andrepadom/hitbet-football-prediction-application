# HitBet Football Prediction Application

## Overview

HitBet is a sophisticated Flask-based web application designed to predict football match outcomes using machine learning. The application combines historical data analysis with advanced machine learning models to provide accurate predictions for various football leagues worldwide. The system uses PostgreSQL database for scalable data storage and management.

**NEW**: Now includes a native iOS app! See the [iOS Integration Guide](IOS_INTEGRATION_GUIDE.md) for details.

## Platforms

### Web Application (Flask)
- Full-featured web interface
- Dashboard, league management, model training, predictions, and analysis
- Access via browser at http://localhost:5000

### iOS Application (Swift/SwiftUI) 🆕
- Native iOS app with modern SwiftUI interface
- All features available on iPhone and iPad
- RESTful API integration
- See [ios-app/README.md](ios-app/README.md) for setup

## Quick Start

### Option 1: Automated Setup
```bash
./setup.sh
```

### Option 2: Manual Setup

**Backend:**
```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Set environment variables
export DATABASE_URL='postgresql://user:password@localhost/hitbet'
export SECRET_KEY='your-secret-key'

# Run migrations
flask db upgrade

# Start server
python app.py
```

**iOS App:**
```bash
# Open in Xcode
cd ios-app/HitBetApp
open HitBetApp.xcodeproj

# Configure API URL in APIService.swift
# Build and run (⌘R)
```

## Documentation

- **[API Documentation](API_DOCUMENTATION.md)** - Complete REST API reference
- **[iOS Integration Guide](IOS_INTEGRATION_GUIDE.md)** - iOS app integration details
- **[iOS App README](ios-app/README.md)** - iOS app setup and features
- **[Implementation Summary](IMPLEMENTATION_SUMMARY.md)** - Technical implementation details
- **[Security Guide](SECURITY.md)** - Security analysis and best practices

## User Preferences

Preferred communication style: Simple, everyday language.

## System Architecture

### Web Framework
- **Flask**: Python web framework serving as the main application backend
- **Template Engine**: Jinja2 templates for HTML rendering
- **Static Assets**: CSS and JavaScript for frontend functionality
- **File Upload Support**: 16MB maximum file size limit with secure filename handling

### Data Architecture
- **PostgreSQL Database**: Relational database for scalable data storage and management
- **SQLAlchemy ORM**: Object-relational mapping for database operations
- **Repository Pattern**: Database-based repositories with separation of data access logic
- **Service Layer**: Business logic encapsulation for data operations, predictions, and web scraping

### Machine Learning Pipeline
- **Dual Model Support**: FCNet (neural network) and Random Forest classifiers
- **Feature Engineering**: 16 team statistics including wins, losses, goals, and performance percentages
- **Hyperparameter Optimization**: Optuna-based automatic tuning
- **Class Imbalance Handling**: SMOTE oversampling for balanced training

## Key Components

### Backend Services
1. **DataService**: Manages historical data download from football-data.co.uk (1993-2025 seasons)
2. **PredictionService**: Handles model training, evaluation, and prediction generation
3. **ScrapingService**: Web scraping for upcoming fixtures using Selenium and BeautifulSoup
4. **DatabaseLeagueRepository**: Database-based persistence for league data, teams, and matches
5. **DatabaseModelRepository**: Database-based storage for trained models with serialized data and metadata

### Machine Learning Models
1. **FCNet**: Fully connected neural network using TensorFlow/Keras
   - Features: Dropout, batch normalization, gaussian noise
   - Optimizers: Adam/AdamW with learning rate scheduling
   - Regularization: L1/L2 penalties and early stopping
2. **RandomForestModel**: Ensemble classifier with calibration
   - Class weight balancing for imbalanced datasets
   - Feature importance analysis capabilities

### Frontend Components

#### Web Interface
1. **Dashboard**: Overview of system status and quick actions
2. **League Management**: Interface for downloading and managing league data
3. **Model Management**: Training, evaluation, and model lifecycle management
4. **Prediction Interface**: Single match, CSV batch, and fixture-based predictions
5. **Analysis Tools**: Data visualization and model performance metrics

#### iOS Application (Native Mobile App) 🆕
1. **Dashboard View**: Statistics overview, recent leagues and models
2. **Leagues View**: Browse and download leagues, manage saved data
3. **Models View**: Train new models, view performance metrics
4. **Predictions View**: Predict match outcomes with visual probability bars
5. **Analysis View**: League and model performance analytics

### Mobile API Layer 🆕
- RESTful API endpoints at `/api/v1/`
- JSON-based request/response format
- CORS enabled for mobile clients
- Secure error handling
- 20+ endpoints covering all functionality

## Data Flow

### Data Ingestion
1. Historical data downloaded from football-data.co.uk via HTTP requests
2. Multiple seasons (1993-2025) aggregated per league
3. Data cleaning and standardization applied
4. Storage in PostgreSQL database with relational structure (leagues, teams, matches)

### Feature Engineering
1. Team statistics computed from historical matches
2. 16-dimensional feature vectors created per team
3. Recent form analysis (configurable match window)
4. Home/away performance differentiation

### Model Training
1. Data preparation with train/validation/test splits
2. SMOTE oversampling for class balance
3. Hyperparameter optimization using Optuna
4. Model evaluation with multiple metrics (accuracy, F1, precision, recall)
5. Model persistence in database with serialized model data and metadata tracking

### Prediction Generation
1. Input validation and team name mapping
2. Feature extraction for prediction inputs
3. Model inference with probability outputs
4. Result formatting and confidence scoring

## External Dependencies

### Data Sources
- **football-data.co.uk**: Historical match data (1993-2025)
- **footystats.org**: Upcoming fixture information (web scraping)

### Python Libraries
- **Web Framework**: Flask, Werkzeug
- **Database**: SQLAlchemy, psycopg2-binary, alembic
- **Data Processing**: pandas, numpy
- **Machine Learning**: scikit-learn, TensorFlow/Keras, imblearn
- **Optimization**: Optuna
- **Web Scraping**: Selenium, BeautifulSoup4, requests
- **Visualization**: matplotlib, seaborn
- **Text Processing**: fuzzywuzzy for team name matching

### Browser Automation
- **Chrome WebDriver**: Required for Selenium-based web scraping
- **Undetected Chrome Driver**: Enhanced scraping capabilities with anti-detection

## Deployment Strategy

### Database Structure
- **PostgreSQL Database**: Relational database with normalized schema
- **Model Storage**: Serialized model data stored as base64-encoded blobs
- **Directory Organization**: Structured folders for cache and uploads
- **Logging**: Comprehensive logging to files and console output

### Configuration Management
- **Environment Variables**: SECRET_KEY and other sensitive configurations
- **Config Module**: Centralized configuration for URLs, paths, and constants
- **Chrome Options**: Headless browser configuration for server deployment

### Scalability Considerations
- **Database Architecture**: PostgreSQL provides ACID compliance and horizontal scaling capabilities
- **Repository Pattern**: Database-based repositories with optimized queries
- **Service Layer**: Modular design for component replacement
- **Connection Pooling**: Efficient database connection management
- **Model Versioning**: Comprehensive metadata tracking and soft deletion for model lifecycle management

### Production Readiness
- **Error Handling**: Comprehensive exception handling and logging
- **Input Validation**: Secure file upload and data validation
- **Session Management**: Flask session handling with secret key
- **Resource Limits**: File size restrictions and timeout configurations
- 
# HitBet-Football-Prediction-Application Folder

app.py as the main Flask entry point — clean and obvious.

Config and environment-related files (config.py, requirements, dependencies.md) grouped at root — easy to find.

models.py for core model definitions, plus a separate models/ folder with different ML models and DB models, keeps things logically separated.

repositories/ directory fully organized by type — keeps your data access layer modular and easy to manage.

services/ folder dedicated to business logic, ML prediction, data services — great separation.

templates/ and static/ folders in the standard Flask way, which will be familiar to other devs.

utils/ folder for helpers and feature engineering — good place for reusable code.

database/ folder clearly organized for persistent storage and checkpoints, with .gitkeep files ensuring folder presence in git.

cache/ folder for caching — nice for performance optimization.

