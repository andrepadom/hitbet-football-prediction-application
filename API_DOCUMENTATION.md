# HitBet Football Prediction - Mobile API Documentation

## Base URL
```
http://your-server-address:5000/api/v1
```

## Authentication
Currently, the API does not require authentication. In production, you should implement API key authentication or OAuth2.

## Response Format
All API responses follow this format:

### Success Response
```json
{
  "status": "success",
  "data": {
    // Response data
  }
}
```

### Error Response
```json
{
  "status": "error",
  "message": "Error description"
}
```

---

## Endpoints

### Health & Dashboard

#### GET /health
Health check endpoint for monitoring.

**Response:**
```json
{
  "status": "ok",
  "version": "1.0.0",
  "service": "HitBet Football Prediction API"
}
```

#### GET /dashboard
Get dashboard statistics and overview.

**Response:**
```json
{
  "status": "success",
  "data": {
    "stats": {
      "total_leagues_available": 50,
      "saved_leagues_count": 5,
      "saved_models_count": 3,
      "countries_available": 25
    },
    "recent_leagues": [...],
    "recent_models": [...]
  }
}
```

---

### Leagues

#### GET /leagues
Get all available and saved leagues.

**Response:**
```json
{
  "status": "success",
  "data": {
    "available": [
      {
        "country": "England",
        "name": "England-Premier League",
        "seasons_count": 32
      }
    ],
    "saved": [...]
  }
}
```

#### GET /leagues/<league_name>
Get details for a specific league.

**Parameters:**
- `league_name` (path): Name of the league (e.g., "England-Premier League")

**Response:**
```json
{
  "status": "success",
  "data": {
    // League details
  }
}
```

#### POST /leagues/download
Download league data from external sources.

**Request Body:**
```json
{
  "league_name": "England-Premier League"
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Successfully downloaded England-Premier League data"
}
```

#### DELETE /leagues/<league_name>
Delete a saved league.

**Parameters:**
- `league_name` (path): Name of the league to delete

**Response:**
```json
{
  "status": "success",
  "message": "Successfully deleted England-Premier League"
}
```

---

### Models

#### GET /models
Get all saved models.

**Response:**
```json
{
  "status": "success",
  "data": [
    {
      "name": "epl_fcnet_2025",
      "type": "fcnet",
      "accuracy": 0.65,
      "created_at": "2025-01-15T10:30:00Z"
    }
  ]
}
```

#### GET /models/<model_name>
Get details for a specific model.

**Parameters:**
- `model_name` (path): Name of the model

**Response:**
```json
{
  "status": "success",
  "data": {
    "name": "epl_fcnet_2025",
    "type": "fcnet",
    "accuracy": 0.65,
    "training_samples": 5000,
    "test_samples": 1000,
    "class_distribution": {...},
    "test_report": {...}
  }
}
```

#### POST /models/train
Train a new machine learning model.

**Request Body:**
```json
{
  "league_name": "England-Premier League",
  "model_type": "fcnet",
  "model_name": "epl_fcnet_2025"
}
```

**Model Types:**
- `fcnet`: Fully Connected Neural Network
- `random_forest`: Random Forest Classifier

**Response:**
```json
{
  "status": "success",
  "message": "Model trained successfully"
}
```

#### DELETE /models/<model_name>
Delete a trained model.

**Parameters:**
- `model_name` (path): Name of the model to delete

**Response:**
```json
{
  "status": "success",
  "message": "Successfully deleted epl_fcnet_2025"
}
```

---

### Predictions

#### POST /predictions/single
Predict the outcome of a single match.

**Request Body:**
```json
{
  "model_name": "epl_fcnet_2025",
  "home_team": "Manchester United",
  "away_team": "Liverpool"
}
```

**Response:**
```json
{
  "status": "success",
  "data": {
    "home_team": "Manchester United",
    "away_team": "Liverpool",
    "prediction": "Home Win",
    "confidence": 0.75,
    "probabilities": {
      "home_win": 0.75,
      "draw": 0.15,
      "away_win": 0.10
    }
  }
}
```

#### POST /predictions/fixtures
Predict outcomes for upcoming fixtures in a league.

**Request Body:**
```json
{
  "model_name": "epl_fcnet_2025",
  "league_name": "England-Premier League"
}
```

**Response:**
```json
{
  "status": "success",
  "data": [
    {
      "home_team": "Arsenal",
      "away_team": "Chelsea",
      "prediction": "Draw",
      "confidence": 0.60,
      "probabilities": {...}
    }
  ]
}
```

---

### Analysis

#### GET /analysis/league/<league_name>
Get statistical analysis for a league.

**Parameters:**
- `league_name` (path): Name of the league

**Response:**
```json
{
  "status": "success",
  "data": {
    "total_matches": 3800,
    "home_wins": 1650,
    "draws": 950,
    "away_wins": 1200,
    "avg_goals_per_match": 2.7,
    // Additional statistics
  }
}
```

#### GET /analysis/model/<model_name>
Get performance analysis for a model.

**Parameters:**
- `model_name` (path): Name of the model

**Response:**
```json
{
  "status": "success",
  "data": {
    "accuracy": 0.65,
    "precision": 0.63,
    "recall": 0.68,
    "f1_score": 0.65,
    "confusion_matrix": [...],
    // Additional metrics
  }
}
```

---

### Metadata

#### GET /countries
Get list of available countries with their leagues.

**Response:**
```json
{
  "status": "success",
  "data": [
    {
      "name": "England",
      "leagues": [
        "England-Premier League",
        "England-Championship"
      ],
      "leagues_count": 5
    }
  ]
}
```

#### GET /model-types
Get available model types for training.

**Response:**
```json
{
  "status": "success",
  "data": [
    {
      "type": "fcnet",
      "name": "Fully Connected Neural Network",
      "description": "Deep learning model with dropout and batch normalization"
    },
    {
      "type": "random_forest",
      "name": "Random Forest Classifier",
      "description": "Ensemble learning method with calibration"
    }
  ]
}
```

---

## Error Codes

| Code | Description |
|------|-------------|
| 200  | Success |
| 400  | Bad Request - Invalid parameters |
| 404  | Not Found - Resource doesn't exist |
| 500  | Internal Server Error |

---

## Example Usage

### Python
```python
import requests

# Health check
response = requests.get('http://localhost:5000/api/v1/health')
print(response.json())

# Get leagues
response = requests.get('http://localhost:5000/api/v1/leagues')
leagues = response.json()['data']

# Predict a match
prediction_data = {
    "model_name": "epl_fcnet_2025",
    "home_team": "Manchester United",
    "away_team": "Liverpool"
}
response = requests.post(
    'http://localhost:5000/api/v1/predictions/single',
    json=prediction_data
)
prediction = response.json()['data']
```

### Swift (iOS)
```swift
// Example in Swift for iOS
import Foundation

struct PredictionRequest: Codable {
    let model_name: String
    let home_team: String
    let away_team: String
}

func predictMatch() {
    let url = URL(string: "http://your-server:5000/api/v1/predictions/single")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let prediction = PredictionRequest(
        model_name: "epl_fcnet_2025",
        home_team: "Manchester United",
        away_team: "Liverpool"
    )
    
    request.httpBody = try? JSONEncoder().encode(prediction)
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        // Handle response
    }.resume()
}
```

---

## Notes

1. **CORS**: The API supports CORS for all `/api/*` endpoints, allowing requests from any origin. In production, restrict this to your iOS app's domain.

2. **Rate Limiting**: Consider implementing rate limiting in production to prevent abuse.

3. **Authentication**: Implement API key authentication or OAuth2 for production use.

4. **Error Handling**: Always check the `status` field in responses and handle errors appropriately.

5. **Long-Running Operations**: Model training and data downloads can take several minutes. Consider implementing webhooks or polling mechanisms for status updates.

6. **Data Formats**: All dates are in ISO 8601 format (YYYY-MM-DDTHH:mm:ssZ).
