"""
Mobile API Blueprint for iOS Application
Provides RESTful endpoints optimized for mobile clients
"""

import logging
from flask import Blueprint, request, jsonify, current_app
from werkzeug.utils import secure_filename
import os

# Import services and repositories
from repositories.database_league_repository import DatabaseLeagueRepository
from repositories.database_model_repository import DatabaseModelRepository
from services.data_service import DataService
from services.prediction_service import PredictionService
from services.scraping_service import ScrapingService
from config import LEAGUE_URLS, FIXTURE_URLS

logger = logging.getLogger(__name__)

# Create Blueprint
mobile_api = Blueprint('mobile_api', __name__, url_prefix='/api/v1')

# Global instances (will be initialized in app.py)
league_repo = None
model_repo = None
data_service = None
prediction_service = None
scraping_service = None


def init_mobile_api(league_repository, model_repository, data_svc, prediction_svc, scraping_svc):
    """Initialize the mobile API with service instances"""
    global league_repo, model_repo, data_service, prediction_service, scraping_service
    league_repo = league_repository
    model_repo = model_repository
    data_service = data_svc
    prediction_service = prediction_svc
    scraping_service = scraping_svc


def _get_safe_error_message(error):
    """
    Get a safe error message for the client.
    In production, this returns a generic message and logs the actual error.
    In debug mode, it returns the actual error message.
    """
    error_message = str(error)
    logger.error(f"API Error: {error_message}", exc_info=True)
    
    # In production, return generic message. In debug, return actual error.
    if current_app.debug:
        return error_message
    else:
        return "An error occurred processing your request. Please try again later."


# ============================================================================
# DASHBOARD & SYSTEM INFO ENDPOINTS
# ============================================================================

@mobile_api.route('/dashboard', methods=['GET'])
def get_dashboard():
    """
    Get dashboard statistics and overview
    
    Returns:
        {
            "status": "success",
            "data": {
                "stats": {...},
                "recent_leagues": [...],
                "recent_models": [...]
            }
        }
    """
    try:
        saved_leagues = league_repo.get_saved_leagues()
        saved_models = model_repo.get_saved_models()
        
        stats = {
            'total_leagues_available': sum(len(leagues) for leagues in LEAGUE_URLS.values()),
            'saved_leagues_count': len(saved_leagues),
            'saved_models_count': len(saved_models),
            'countries_available': len(LEAGUE_URLS)
        }
        
        # Get recent leagues (top 5)
        recent_leagues = saved_leagues[:5] if saved_leagues else []
        
        # Get recent models (top 5)
        recent_models = saved_models[:5] if saved_models else []
        
        return jsonify({
            'status': 'success',
            'data': {
                'stats': stats,
                'recent_leagues': recent_leagues,
                'recent_models': recent_models
            }
        }), 200
        
    except Exception as e:
        logger.error(f"Dashboard error: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': _get_safe_error_message(e)
        }), 500


@mobile_api.route('/health', methods=['GET'])
def health_check():
    """
    Health check endpoint for monitoring
    
    Returns:
        {
            "status": "ok",
            "version": "1.0.0"
        }
    """
    return jsonify({
        'status': 'ok',
        'version': '1.0.0',
        'service': 'HitBet Football Prediction API'
    }), 200


# ============================================================================
# LEAGUES ENDPOINTS
# ============================================================================

@mobile_api.route('/leagues', methods=['GET'])
def get_leagues():
    """
    Get all available and saved leagues
    
    Returns:
        {
            "status": "success",
            "data": {
                "available": [...],
                "saved": [...]
            }
        }
    """
    try:
        available_leagues = [
            {
                'country': country,
                'name': name,
                'seasons_count': len(urls)
            }
            for country, leagues in LEAGUE_URLS.items()
            for name, urls in leagues.items()
        ]
        
        saved_leagues = league_repo.get_saved_leagues()
        
        return jsonify({
            'status': 'success',
            'data': {
                'available': available_leagues,
                'saved': saved_leagues
            }
        }), 200
        
    except Exception as e:
        logger.error(f"Get leagues error: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': _get_safe_error_message(e)
        }), 500


@mobile_api.route('/leagues/<league_name>', methods=['GET'])
def get_league_details(league_name):
    """
    Get details for a specific league
    
    Args:
        league_name: Name of the league
        
    Returns:
        {
            "status": "success",
            "data": {...}
        }
    """
    try:
        if not league_repo.league_exists(league_name):
            return jsonify({
                'status': 'error',
                'message': f'League {league_name} not found'
            }), 404
            
        league_data = league_repo.get_league_data(league_name)
        
        return jsonify({
            'status': 'success',
            'data': league_data
        }), 200
        
    except Exception as e:
        logger.error(f"Get league details error: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': _get_safe_error_message(e)
        }), 500


@mobile_api.route('/leagues/download', methods=['POST'])
def download_league():
    """
    Download league data
    
    Request Body:
        {
            "league_name": "England-Premier League"
        }
        
    Returns:
        {
            "status": "success",
            "message": "League data downloaded successfully"
        }
    """
    try:
        data = request.get_json()
        if not data or 'league_name' not in data:
            return jsonify({
                'status': 'error',
                'message': 'league_name is required'
            }), 400
            
        league_name = data['league_name']
        
        # Verify league exists in available leagues
        league_found = any(league_name in leagues for leagues in LEAGUE_URLS.values())
        if not league_found:
            return jsonify({
                'status': 'error',
                'message': f'League {league_name} not found in available leagues'
            }), 404
            
        success = data_service.download_league_data(league_name)
        
        if success:
            return jsonify({
                'status': 'success',
                'message': f'Successfully downloaded {league_name} data'
            }), 200
        else:
            return jsonify({
                'status': 'error',
                'message': f'Failed to download {league_name} data'
            }), 500
            
    except Exception as e:
        logger.error(f"Download league error: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': _get_safe_error_message(e)
        }), 500


@mobile_api.route('/leagues/<league_name>', methods=['DELETE'])
def delete_league(league_name):
    """
    Delete a league
    
    Args:
        league_name: Name of the league to delete
        
    Returns:
        {
            "status": "success",
            "message": "League deleted successfully"
        }
    """
    try:
        success = league_repo.delete_league(league_name)
        
        if success:
            return jsonify({
                'status': 'success',
                'message': f'Successfully deleted {league_name}'
            }), 200
        else:
            return jsonify({
                'status': 'error',
                'message': f'Failed to delete {league_name}'
            }), 500
            
    except Exception as e:
        logger.error(f"Delete league error: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': _get_safe_error_message(e)
        }), 500


# ============================================================================
# MODELS ENDPOINTS
# ============================================================================

@mobile_api.route('/models', methods=['GET'])
def get_models():
    """
    Get all saved models
    
    Returns:
        {
            "status": "success",
            "data": [...]
        }
    """
    try:
        saved_models = model_repo.get_saved_models()
        
        return jsonify({
            'status': 'success',
            'data': saved_models
        }), 200
        
    except Exception as e:
        logger.error(f"Get models error: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': _get_safe_error_message(e)
        }), 500


@mobile_api.route('/models/<model_name>', methods=['GET'])
def get_model_details(model_name):
    """
    Get details for a specific model
    
    Args:
        model_name: Name of the model
        
    Returns:
        {
            "status": "success",
            "data": {...}
        }
    """
    try:
        if not model_repo.model_exists(model_name):
            return jsonify({
                'status': 'error',
                'message': f'Model {model_name} not found'
            }), 404
            
        model_data = model_repo.load_model_metadata(model_name)
        
        return jsonify({
            'status': 'success',
            'data': model_data
        }), 200
        
    except Exception as e:
        logger.error(f"Get model details error: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': _get_safe_error_message(e)
        }), 500


@mobile_api.route('/models/train', methods=['POST'])
def train_model():
    """
    Train a new model
    
    Request Body:
        {
            "league_name": "England-Premier League",
            "model_type": "fcnet",
            "model_name": "epl_fcnet_2025"
        }
        
    Returns:
        {
            "status": "success",
            "message": "Model trained successfully"
        }
    """
    try:
        data = request.get_json()
        
        required_fields = ['league_name', 'model_type', 'model_name']
        if not data or not all(field in data for field in required_fields):
            return jsonify({
                'status': 'error',
                'message': f'All fields required: {", ".join(required_fields)}'
            }), 400
            
        league_name = data['league_name']
        model_type = data['model_type']
        model_name = data['model_name']
        
        # Check if league exists
        if not league_repo.league_exists(league_name):
            return jsonify({
                'status': 'error',
                'message': f'{league_name} data not found. Please download league data first.'
            }), 404
            
        # Train model
        success, message = prediction_service.train_model(league_name, model_type, model_name)
        
        if success:
            return jsonify({
                'status': 'success',
                'message': message
            }), 200
        else:
            return jsonify({
                'status': 'error',
                'message': message
            }), 500
            
    except Exception as e:
        logger.error(f"Train model error: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': _get_safe_error_message(e)
        }), 500


@mobile_api.route('/models/<model_name>', methods=['DELETE'])
def delete_model(model_name):
    """
    Delete a model
    
    Args:
        model_name: Name of the model to delete
        
    Returns:
        {
            "status": "success",
            "message": "Model deleted successfully"
        }
    """
    try:
        success = model_repo.delete_model(model_name)
        
        if success:
            return jsonify({
                'status': 'success',
                'message': f'Successfully deleted {model_name}'
            }), 200
        else:
            return jsonify({
                'status': 'error',
                'message': f'Failed to delete {model_name}'
            }), 500
            
    except Exception as e:
        logger.error(f"Delete model error: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': _get_safe_error_message(e)
        }), 500


# ============================================================================
# PREDICTIONS ENDPOINTS
# ============================================================================

@mobile_api.route('/predictions/single', methods=['POST'])
def predict_single_match():
    """
    Predict a single match outcome
    
    Request Body:
        {
            "model_name": "epl_fcnet_2025",
            "home_team": "Manchester United",
            "away_team": "Liverpool"
        }
        
    Returns:
        {
            "status": "success",
            "data": {
                "prediction": "Home Win",
                "confidence": 0.75,
                "probabilities": {...}
            }
        }
    """
    try:
        data = request.get_json()
        
        required_fields = ['model_name', 'home_team', 'away_team']
        if not data or not all(field in data for field in required_fields):
            return jsonify({
                'status': 'error',
                'message': f'All fields required: {", ".join(required_fields)}'
            }), 400
            
        model_name = data['model_name']
        home_team = data['home_team']
        away_team = data['away_team']
        
        result = prediction_service.predict_single_match(model_name, home_team, away_team)
        
        if result:
            return jsonify({
                'status': 'success',
                'data': result
            }), 200
        else:
            return jsonify({
                'status': 'error',
                'message': 'Prediction failed'
            }), 500
            
    except Exception as e:
        logger.error(f"Single prediction error: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': _get_safe_error_message(e)
        }), 500


@mobile_api.route('/predictions/fixtures', methods=['POST'])
def predict_fixtures():
    """
    Predict upcoming fixtures for a league
    
    Request Body:
        {
            "model_name": "epl_fcnet_2025",
            "league_name": "England-Premier League"
        }
        
    Returns:
        {
            "status": "success",
            "data": [...]
        }
    """
    try:
        data = request.get_json()
        
        required_fields = ['model_name', 'league_name']
        if not data or not all(field in data for field in required_fields):
            return jsonify({
                'status': 'error',
                'message': f'All fields required: {", ".join(required_fields)}'
            }), 400
            
        model_name = data['model_name']
        league_name = data['league_name']
        
        if league_name not in FIXTURE_URLS:
            return jsonify({
                'status': 'error',
                'message': f'Unsupported league for fixtures: {league_name}'
            }), 400
            
        # Scrape fixtures
        fixtures = scraping_service.scrape_fixtures(league_name)
        
        if not fixtures:
            return jsonify({
                'status': 'error',
                'message': 'No fixtures found or scraping failed'
            }), 500
            
        # Make predictions
        results = prediction_service.predict_fixtures(model_name, fixtures)
        
        if results:
            return jsonify({
                'status': 'success',
                'data': results
            }), 200
        else:
            return jsonify({
                'status': 'error',
                'message': 'Prediction failed'
            }), 500
            
    except Exception as e:
        logger.error(f"Fixtures prediction error: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': _get_safe_error_message(e)
        }), 500


# ============================================================================
# ANALYSIS ENDPOINTS
# ============================================================================

@mobile_api.route('/analysis/league/<league_name>', methods=['GET'])
def analyze_league(league_name):
    """
    Get analysis for a league
    
    Args:
        league_name: Name of the league
        
    Returns:
        {
            "status": "success",
            "data": {...}
        }
    """
    try:
        if not league_repo.league_exists(league_name):
            return jsonify({
                'status': 'error',
                'message': f'League {league_name} not found'
            }), 404
            
        analysis = data_service.analyze_league_data(league_name)
        
        if analysis:
            return jsonify({
                'status': 'success',
                'data': analysis
            }), 200
        else:
            return jsonify({
                'status': 'error',
                'message': 'Analysis failed'
            }), 500
            
    except Exception as e:
        logger.error(f"League analysis error: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': _get_safe_error_message(e)
        }), 500


@mobile_api.route('/analysis/model/<model_name>', methods=['GET'])
def analyze_model(model_name):
    """
    Get performance analysis for a model
    
    Args:
        model_name: Name of the model
        
    Returns:
        {
            "status": "success",
            "data": {...}
        }
    """
    try:
        if not model_repo.model_exists(model_name):
            return jsonify({
                'status': 'error',
                'message': f'Model {model_name} not found'
            }), 404
            
        analysis = prediction_service.analyze_model_performance(model_name)
        
        if analysis:
            return jsonify({
                'status': 'success',
                'data': analysis
            }), 200
        else:
            return jsonify({
                'status': 'error',
                'message': 'Analysis failed'
            }), 500
            
    except Exception as e:
        logger.error(f"Model analysis error: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': _get_safe_error_message(e)
        }), 500


# ============================================================================
# COUNTRIES & METADATA ENDPOINTS
# ============================================================================

@mobile_api.route('/countries', methods=['GET'])
def get_countries():
    """
    Get list of available countries with their leagues
    
    Returns:
        {
            "status": "success",
            "data": [...]
        }
    """
    try:
        countries = [
            {
                'name': country,
                'leagues': list(leagues.keys()),
                'leagues_count': len(leagues)
            }
            for country, leagues in LEAGUE_URLS.items()
        ]
        
        return jsonify({
            'status': 'success',
            'data': countries
        }), 200
        
    except Exception as e:
        logger.error(f"Get countries error: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': _get_safe_error_message(e)
        }), 500


@mobile_api.route('/model-types', methods=['GET'])
def get_model_types():
    """
    Get available model types
    
    Returns:
        {
            "status": "success",
            "data": [...]
        }
    """
    try:
        model_types = [
            {
                'type': 'fcnet',
                'name': 'Fully Connected Neural Network',
                'description': 'Deep learning model with dropout and batch normalization'
            },
            {
                'type': 'random_forest',
                'name': 'Random Forest Classifier',
                'description': 'Ensemble learning method with calibration'
            }
        ]
        
        return jsonify({
            'status': 'success',
            'data': model_types
        }), 200
        
    except Exception as e:
        logger.error(f"Get model types error: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': _get_safe_error_message(e)
        }), 500
