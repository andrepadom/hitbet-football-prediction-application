# HitBet iOS App

## Overview

This is the native iOS application for HitBet Football Prediction. It provides a mobile interface to access all features of the HitBet backend, including league management, model training, and match predictions.

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

## Project Structure

```
HitBetApp/
├── HitBetApp/
│   ├── HitBetAppApp.swift          # App entry point
│   ├── ContentView.swift           # Main navigation view
│   ├── Models/
│   │   └── APIModels.swift         # Data models
│   ├── Views/
│   │   ├── DashboardView.swift     # Dashboard view
│   │   ├── LeaguesView.swift       # Leagues management
│   │   ├── ModelsView.swift        # ML models management
│   │   ├── PredictionsView.swift   # Predictions interface
│   │   └── AnalysisView.swift      # Analysis tools
│   ├── ViewModels/
│   │   └── DashboardViewModel.swift # ViewModels
│   ├── Services/
│   │   └── APIService.swift        # API communication layer
│   └── Utilities/
│       └── (Helper files)
```

## Features

### 1. Dashboard
- Overview statistics (leagues, models, countries)
- Recent leagues and models
- Quick access to main features

### 2. Leagues Management
- View available leagues from multiple countries
- Download league data
- Manage saved leagues
- Delete leagues with swipe gestures

### 3. Models Management
- View trained ML models
- Train new models (FCNet, Random Forest)
- View model performance metrics
- Delete models with swipe gestures

### 4. Predictions
- Predict single match outcomes
- Select from trained models
- View prediction probabilities
- Visual probability bars

### 5. Analysis
- Analyze league statistics
- View model performance metrics
- Detailed analytics for both leagues and models

## Setup Instructions

### 1. Configure Backend URL

Before running the app, configure the backend API URL in `HitBetAppApp.swift`:

```swift
class AppState: ObservableObject {
    @Published var apiBaseURL: String = "http://your-server-address:5000/api/v1"
}
```

Or update the `APIService` initialization in `APIService.swift`:

```swift
init(baseURL: String = "http://your-server-address:5000/api/v1") {
    self.baseURL = baseURL
}
```

### 2. Open in Xcode

1. Open `HitBetApp.xcodeproj` in Xcode
2. Select your target device or simulator
3. Build and run (⌘R)

### 3. Configure Backend Server

Ensure your Flask backend is running and accessible:

```bash
# Start the Flask backend
cd /path/to/hitbet-backend
python app.py
```

The backend should be running on `http://localhost:5000` (or your configured address).

### 4. Network Permissions

For local development with the iOS Simulator:
- The app uses HTTP (not HTTPS) for localhost
- No additional configuration needed for simulator

For testing on physical devices or production:
1. Update `Info.plist` to allow HTTP connections (development only):

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

2. For production, use HTTPS with a valid SSL certificate

## API Integration

The app communicates with the Flask backend using the Mobile API (`/api/v1/*` endpoints).

See `API_DOCUMENTATION.md` in the root directory for complete API documentation.

### Key API Endpoints Used:

- `GET /api/v1/health` - Health check
- `GET /api/v1/dashboard` - Dashboard data
- `GET /api/v1/leagues` - Get leagues
- `POST /api/v1/leagues/download` - Download league data
- `GET /api/v1/models` - Get models
- `POST /api/v1/models/train` - Train new model
- `POST /api/v1/predictions/single` - Predict single match
- `GET /api/v1/analysis/league/:name` - Analyze league
- `GET /api/v1/analysis/model/:name` - Analyze model

## Architecture

The app follows the MVVM (Model-View-ViewModel) architecture pattern:

- **Models**: Data structures that match the API responses
- **Views**: SwiftUI views for the user interface
- **ViewModels**: Business logic and state management
- **Services**: API communication layer

### Data Flow:

1. Views display UI and handle user interactions
2. ViewModels manage state and business logic
3. APIService handles all network communication
4. Models define data structures

## Development

### Adding New Features

1. **Add Model** (if needed): Create data structure in `Models/APIModels.swift`
2. **Add API Method**: Extend `Services/APIService.swift`
3. **Create ViewModel**: Add to `ViewModels/`
4. **Create View**: Add to `Views/`
5. **Update Navigation**: Modify `ContentView.swift` if adding new tab

### Error Handling

The app includes comprehensive error handling:
- Network errors are caught and displayed
- API errors are shown with user-friendly messages
- Loading states provide feedback during operations

### Testing

Run tests in Xcode:
```bash
⌘U (Command+U)
```

## Deployment

### App Store Preparation

1. **Update Bundle Identifier**: Change to your own identifier
2. **Configure Signing**: Set up your development team and provisioning profile
3. **Update App Icons**: Add your app icons in Assets.xcassets
4. **Set Version**: Update version and build number
5. **Configure Backend URL**: Set production backend URL
6. **Enable HTTPS**: Ensure backend uses HTTPS in production
7. **Test Thoroughly**: Test all features on physical devices
8. **Create Archive**: Product > Archive in Xcode
9. **Submit to App Store**: Use Xcode or App Store Connect

### Production Considerations

- Use HTTPS for backend communication
- Implement proper authentication/authorization
- Add analytics and crash reporting
- Implement proper error tracking
- Add offline capability if needed
- Optimize network requests
- Add proper caching mechanisms

## Troubleshooting

### Cannot Connect to Backend

1. Verify backend is running: `http://localhost:5000/api/v1/health`
2. Check firewall settings
3. Verify correct API URL in app configuration
4. For physical device testing, ensure device can reach server

### Build Errors

1. Clean build folder: Product > Clean Build Folder (⇧⌘K)
2. Delete derived data
3. Restart Xcode

### Network Errors

1. Check Info.plist for App Transport Security settings
2. Verify API endpoints are correct
3. Check server logs for errors

## Contributing

When contributing to the iOS app:

1. Follow Swift naming conventions
2. Use SwiftUI best practices
3. Maintain MVVM architecture
4. Add comments for complex logic
5. Test on multiple iOS versions
6. Ensure compatibility with both iPhone and iPad

## Support

For issues or questions:
- Check API documentation: `API_DOCUMENTATION.md`
- Review backend logs
- Check iOS console for errors
- Test API endpoints directly with curl or Postman

## License

[Add your license information here]
