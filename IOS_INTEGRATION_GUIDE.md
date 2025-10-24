# HitBet Football Prediction - iOS Integration Guide

## Overview

This guide explains how the HitBet Football Prediction Application has been integrated with a native iOS app. The integration maintains clear separation between the Flask backend and the Swift/SwiftUI frontend.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    iOS App (Swift/SwiftUI)              │
│  ┌──────────┬──────────┬──────────┬──────────────────┐ │
│  │Dashboard │ Leagues  │  Models  │  Predictions     │ │
│  │   View   │   View   │   View   │     View         │ │
│  └────┬─────┴────┬─────┴────┬─────┴────┬─────────────┘ │
│       │          │          │          │                │
│  ┌────┴──────────┴──────────┴──────────┴─────────────┐ │
│  │              API Service Layer                     │ │
│  │         (HTTP REST Communication)                  │ │
│  └────────────────────┬───────────────────────────────┘ │
└───────────────────────┼─────────────────────────────────┘
                        │ HTTP/JSON
                        │
┌───────────────────────┼─────────────────────────────────┐
│                Flask Backend                            │
│  ┌────────────────────┴───────────────────────────────┐ │
│  │         Mobile API Blueprint (/api/v1)             │ │
│  │              (CORS Enabled)                        │ │
│  └────────────────────┬───────────────────────────────┘ │
│                       │                                 │
│  ┌────────────────────┴───────────────────────────────┐ │
│  │  Services Layer (Data, Prediction, Scraping)       │ │
│  └────────────────────┬───────────────────────────────┘ │
│                       │                                 │
│  ┌────────────────────┴───────────────────────────────┐ │
│  │        PostgreSQL Database                         │ │
│  │  (Leagues, Teams, Matches, Models, Predictions)    │ │
│  └────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

## Components

### 1. Backend Changes

#### Mobile API Layer (`/api/mobile_api.py`)
- New RESTful API endpoints specifically designed for mobile clients
- All endpoints prefixed with `/api/v1/`
- Standardized JSON response format
- Comprehensive error handling

#### CORS Support
- Flask-CORS added to enable cross-origin requests
- Configured to allow requests from iOS app
- Production-ready for mobile clients

#### API Endpoints

**Dashboard & System:**
- `GET /api/v1/health` - Health check
- `GET /api/v1/dashboard` - Dashboard statistics

**Leagues:**
- `GET /api/v1/leagues` - Get all leagues
- `GET /api/v1/leagues/<name>` - Get league details
- `POST /api/v1/leagues/download` - Download league data
- `DELETE /api/v1/leagues/<name>` - Delete league

**Models:**
- `GET /api/v1/models` - Get all models
- `GET /api/v1/models/<name>` - Get model details
- `POST /api/v1/models/train` - Train new model
- `DELETE /api/v1/models/<name>` - Delete model

**Predictions:**
- `POST /api/v1/predictions/single` - Predict single match
- `POST /api/v1/predictions/fixtures` - Predict fixtures

**Analysis:**
- `GET /api/v1/analysis/league/<name>` - Analyze league
- `GET /api/v1/analysis/model/<name>` - Analyze model

**Metadata:**
- `GET /api/v1/countries` - Get available countries
- `GET /api/v1/model-types` - Get model types

### 2. iOS App Structure

#### Core Files
- `HitBetAppApp.swift` - Main app entry point
- `ContentView.swift` - Tab-based navigation

#### Models (`/Models`)
- `APIModels.swift` - Data models matching API responses

#### Views (`/Views`)
- `DashboardView.swift` - Overview dashboard
- `LeaguesView.swift` - League management
- `ModelsView.swift` - ML model management
- `PredictionsView.swift` - Match predictions
- `AnalysisView.swift` - Statistical analysis

#### ViewModels (`/ViewModels`)
- `DashboardViewModel.swift` - Dashboard logic
- Other ViewModels embedded in views

#### Services (`/Services`)
- `APIService.swift` - Network communication layer

## Setup Instructions

### Backend Setup

1. **Install Dependencies**
```bash
pip install -r requirements.txt
```

2. **Set Environment Variables**
```bash
export DATABASE_URL="postgresql://user:password@localhost/hitbet"
export SECRET_KEY="your-secret-key"
```

3. **Run Database Migrations**
```bash
flask db upgrade
```

4. **Start the Backend**
```bash
python app.py
```

The backend will be available at `http://localhost:5000`

### iOS App Setup

1. **Configure Backend URL**

Edit `ios-app/HitBetApp/HitBetApp/Services/APIService.swift`:
```swift
init(baseURL: String = "http://YOUR_SERVER_IP:5000/api/v1") {
    self.baseURL = baseURL
}
```

2. **Open in Xcode**
```bash
cd ios-app/HitBetApp
open HitBetApp.xcodeproj
```

3. **Build and Run**
- Select target device/simulator
- Press ⌘R to build and run

## API Response Format

All mobile API endpoints return responses in this format:

**Success:**
```json
{
  "status": "success",
  "data": {
    // Response data
  }
}
```

**Error:**
```json
{
  "status": "error",
  "message": "Error description"
}
```

## Features

### Dashboard
- View system statistics
- Recent leagues and models
- Quick overview of available data

### League Management
- Browse available leagues by country
- Download historical data for any league
- View saved leagues
- Delete leagues when no longer needed

### Model Management
- Train new ML models (FCNet, Random Forest)
- View model performance metrics
- Delete trained models
- Monitor training progress

### Predictions
- Predict individual match outcomes
- View prediction probabilities
- Select from available trained models
- Get confidence scores

### Analysis
- Analyze league statistics
- View model performance metrics
- Compare different models
- Statistical insights

## Security Considerations

### Current Implementation (Development)
- No authentication required
- CORS allows all origins
- HTTP communication allowed

### Production Recommendations

1. **Authentication**
   - Implement API key authentication
   - Add OAuth2 support
   - Secure user sessions

2. **CORS**
   - Restrict to specific origins
   - Implement token-based auth

3. **HTTPS**
   - Use SSL/TLS certificates
   - Enforce HTTPS only

4. **Rate Limiting**
   - Implement request rate limiting
   - Prevent API abuse

5. **Input Validation**
   - Validate all input data
   - Sanitize user inputs
   - Prevent injection attacks

## Database Configuration

The application uses PostgreSQL for data storage:

- **Leagues Table**: League information
- **Teams Table**: Team data
- **Matches Table**: Historical match data
- **ML Models Table**: Trained model storage
- **Predictions Table**: Prediction history
- **Scraped Fixtures Table**: Upcoming fixtures

Ensure PostgreSQL is running and accessible with proper credentials.

## Testing

### Backend API Testing

Using curl:
```bash
# Health check
curl http://localhost:5000/api/v1/health

# Get dashboard
curl http://localhost:5000/api/v1/dashboard

# Get leagues
curl http://localhost:5000/api/v1/leagues

# Predict match
curl -X POST http://localhost:5000/api/v1/predictions/single \
  -H "Content-Type: application/json" \
  -d '{
    "model_name": "epl_model",
    "home_team": "Manchester United",
    "away_team": "Liverpool"
  }'
```

### iOS App Testing

1. Run on iOS Simulator (iOS 16+)
2. Test on physical device
3. Verify all API calls work correctly
4. Test error handling
5. Verify UI responsiveness

## Deployment

### Backend Deployment

1. **Choose a hosting platform**
   - Heroku
   - AWS
   - Google Cloud
   - DigitalOcean

2. **Configure production settings**
   - Set `DATABASE_URL`
   - Set `SECRET_KEY`
   - Configure CORS for production domain
   - Enable HTTPS

3. **Deploy**
   ```bash
   # Example for Heroku
   git push heroku main
   ```

### iOS App Deployment

1. **Prepare for App Store**
   - Update bundle identifier
   - Configure signing certificates
   - Add app icons and screenshots
   - Set production API URL

2. **Create Archive**
   - Product > Archive in Xcode

3. **Submit to App Store**
   - Use Xcode or App Store Connect
   - Fill in app information
   - Submit for review

## Maintenance

### Backend Updates
- Monitor server logs
- Update dependencies regularly
- Optimize database queries
- Add new endpoints as needed

### iOS App Updates
- Test on new iOS versions
- Update dependencies
- Fix bugs and add features
- Submit updates to App Store

## Troubleshooting

### Common Issues

1. **Cannot connect to backend**
   - Verify backend is running
   - Check firewall settings
   - Verify API URL is correct

2. **Database connection errors**
   - Check PostgreSQL is running
   - Verify DATABASE_URL is correct
   - Check database credentials

3. **CORS errors**
   - Verify CORS is enabled
   - Check allowed origins
   - Verify request headers

4. **Model training fails**
   - Check league data is downloaded
   - Verify sufficient data available
   - Check server resources

## Additional Resources

- **API Documentation**: See `API_DOCUMENTATION.md`
- **iOS App README**: See `ios-app/README.md`
- **Backend README**: See `README.md`

## Support

For issues or questions:
1. Check the documentation
2. Review server logs
3. Test API endpoints directly
4. Check iOS console for errors

## License

[Add your license information here]
