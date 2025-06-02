import os
import numpy as np
import pandas as pd
from flask import Flask, request, jsonify
from flask_cors import CORS
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
import joblib
import json
import datetime
import logging
from typing import Dict, List, Any, Tuple, Union

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

# Health check endpoint

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Path to save/load the model
MODEL_PATH = os.path.join(os.path.dirname(__file__), 'sleep_model.pkl')

# Define feature columns for our model based on Sleep Health Dataset
# These will be overridden when loading the model but defined here as fallback
NUMERICAL_FEATURES = [
    'Age', 'Sleep Duration', 'Physical Activity Level', 
    'Heart Rate', 'Daily Steps', 'Stress Level'
]

CATEGORICAL_FEATURES = [
    'Gender', 'BMI Category'
]

ALL_FEATURES = NUMERICAL_FEATURES + CATEGORICAL_FEATURES

# Initialize or load model
def get_model():
    global NUMERICAL_FEATURES, CATEGORICAL_FEATURES, ALL_FEATURES
    
    if os.path.exists(MODEL_PATH):
        logger.info(f"Loading existing model from {MODEL_PATH}...")
        try:
            # Load the model info dictionary that contains model and feature lists
            model_info = joblib.load(MODEL_PATH)
            
            # Extract the model and feature lists
            if isinstance(model_info, dict):
                model = model_info['model']
                NUMERICAL_FEATURES = model_info.get('numerical_features', NUMERICAL_FEATURES)
                CATEGORICAL_FEATURES = model_info.get('categorical_features', CATEGORICAL_FEATURES)
                ALL_FEATURES = NUMERICAL_FEATURES + CATEGORICAL_FEATURES
                logger.info(f"Model loaded successfully with {len(ALL_FEATURES)} features")
                return model
            else:
                # If model_info is not a dict, assume it's just the model
                logger.warning("Model file doesn't contain feature information. Using defaults.")
                return model_info
        except Exception as e:
            logger.error(f"Error loading model: {str(e)}")
            return create_fallback_model()
    else:
        logger.warning(f"No model found at {MODEL_PATH}. Creating fallback model...")
        return create_fallback_model()

def create_fallback_model():
    """Create a simple model for when the trained model is not available"""
    logger.info("Creating fallback model...")
    
    # Define preprocessing for numerical features
    numerical_transformer = Pipeline(steps=[
        ('scaler', StandardScaler())
    ])
    
    # Define preprocessing for categorical features
    categorical_transformer = Pipeline(steps=[
        ('onehot', OneHotEncoder(handle_unknown='ignore'))
    ])
    
    # Combine preprocessing steps
    preprocessor = ColumnTransformer(
        transformers=[
            ('num', numerical_transformer, NUMERICAL_FEATURES),
            ('cat', categorical_transformer, CATEGORICAL_FEATURES)
        ])
    
    # Create and return the model pipeline
    model = Pipeline(steps=[
        ('preprocessor', preprocessor),
        ('classifier', RandomForestClassifier(n_estimators=100, random_state=42))
    ])
    
    logger.warning("Using untrained fallback model. Please train a proper model using train_model.py")
    return model

# Initialize model
model = get_model()

def preprocess_input(data: Dict[str, Any]) -> Dict[str, Any]:
    """Process input data from the request into model-compatible format"""
    processed_data = {}
    
    # Map the JSON input fields to our model features
    feature_mapping = {
        # Direct mappings
        'Age': 'Age',
        'Gender': 'Gender',
        'BMI Category': 'BMI Category',
        'Sleep Duration': 'Sleep Duration',
        'Physical Activity Level': 'Physical Activity Level',
        'Heart Rate': 'Heart Rate',
        'Daily Steps': 'Daily Steps',
        'Stress Level': 'Stress Level',
        
        # Common alternate field names
        'age': 'Age',
        'gender': 'Gender',
        'bmi_category': 'BMI Category',
        'sleep_duration': 'Sleep Duration',
        'physical_activity': 'Physical Activity Level',
        'heart_rate': 'Heart Rate',
        'steps': 'Daily Steps',
        'stress': 'Stress Level',
    }
    
    # Process known fields
    for input_field, model_field in feature_mapping.items():
        if input_field in data:
            processed_data[model_field] = data[input_field]
    
    # Handle missing required features with reasonable defaults
    for feature in ALL_FEATURES:
        if feature not in processed_data:
            if feature == 'Age':
                processed_data[feature] = 35  # Default age
            elif feature == 'Gender':
                processed_data[feature] = 'Male'  # Default gender
            elif feature == 'BMI Category':
                processed_data[feature] = 'Normal'  # Default BMI
            elif feature == 'Sleep Duration':
                processed_data[feature] = 7.0  # Default sleep hours
            elif feature == 'Physical Activity Level':
                processed_data[feature] = 45  # Default minutes of activity
            elif feature == 'Heart Rate':
                processed_data[feature] = 70  # Default BPM
            elif feature == 'Daily Steps':
                processed_data[feature] = 7000  # Default steps
            elif feature == 'Stress Level':
                processed_data[feature] = 5  # Default stress (1-10)
    
    logger.info(f"Processed input: {processed_data}")
    return processed_data

# Train the model with sample data if it's newly created
def initialize_model_with_sample_data():
    if not os.path.exists(MODEL_PATH):
        print("Training model with sample data...")
        
        # Create synthetic sample data
        np.random.seed(42)
        n_samples = 200
        
        # Generate random values for features
        data = {
            'Age': np.random.uniform(20, 60, n_samples),
            'Gender': np.random.choice(['Male', 'Female'], n_samples),
            'BMI Category': np.random.choice(['Underweight', 'Normal', 'Overweight', 'Obese'], n_samples),
            'Sleep Duration': np.random.uniform(5, 10, n_samples),
            'Physical Activity Level': np.random.uniform(30, 90, n_samples),
            'Heart Rate': np.random.uniform(60, 100, n_samples),
            'Daily Steps': np.random.uniform(5000, 15000, n_samples),
            'Stress Level': np.random.uniform(1, 10, n_samples),
        }
        
        # Generate target variables: sleep quality (0-10) and interruption count
        base_quality = 7.0
        noise = np.random.normal(0, 1, n_samples)
        
        # Sleep quality decreases with age, stress, and increases with physical activity
        quality_adjustments = (
            -0.01 * (data['Age'] - 30) 
            + 0.01 * data['Physical Activity Level'] 
            - 0.1 * data['Stress Level']
        )
        
        # Adjustments for categorical variables
        gender_adj = np.where(data['Gender'] == 'Female', 0.5, -0.5)
        bmi_adj = np.zeros(n_samples)
        bmi_adj[data['BMI Category'] == 'Underweight'] = -0.5
        bmi_adj[data['BMI Category'] == 'Overweight'] = -0.3
        bmi_adj[data['BMI Category'] == 'Obese'] = -0.8
        
        # Combine all adjustments
        sleep_quality = base_quality + quality_adjustments + gender_adj + bmi_adj + noise
        sleep_quality = np.clip(sleep_quality, 0, 10)  # Ensure it's within 0-10 range
        
        # Calculate interruption count based on similar factors
        interruption_base = 2
        interruption_adj = (
            0.01 * (data['Age'] - 30)
            - 0.01 * data['Physical Activity Level']
            + 0.1 * data['Stress Level']
        )
        interruption_count = interruption_base + interruption_adj + np.random.normal(0, 0.5, n_samples)
        interruption_count = np.clip(interruption_count, 0, 10).astype(int)
        
        # Create a DataFrame with all features and targets
        df = pd.DataFrame(data)
        df['sleep_quality'] = sleep_quality
        df['interruption_count'] = interruption_count
        
        # Split into features and targets
        X = df[ALL_FEATURES]
        y_quality = df['sleep_quality']
        y_interruptions = df['interruption_count']
        
        # Train model for sleep quality prediction
        model.fit(X, y_quality)
        
        # Save the model
        joblib.dump(model, MODEL_PATH)
        
        return model
    
    return model

# Initialize with sample data if needed
model = initialize_model_with_sample_data()

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({'status': 'healthy', 'timestamp': datetime.datetime.now().isoformat()})

@app.route('/predict', methods=['POST'])
def predict():
    try:
        # Get data from request
        data = request.get_json()
        logger.info(f"Received prediction request with data: {data}")
        
        # Extract sleep data, environmental data, and dietary data from the request
        sleep_data = data.get('sleepData', {})
        environmental_data = data.get('environmentalData', {})
        dietary_data = data.get('dietaryData', {})
        
        # Combine all data sources
        combined_data = {}
        combined_data.update(sleep_data)
        combined_data.update(environmental_data)
        combined_data.update(dietary_data)
        
        # Process input data to match model features
        processed_data = preprocess_input(combined_data)
        
        # Create a dataframe from the processed features
        input_df = pd.DataFrame([processed_data])
        
        # Make prediction with the model
        try:
            # For binary classification (probability of sleep disorder)
            prediction_proba = model.predict_proba(input_df)
            sleep_disorder_prob = prediction_proba[0][1]  # Probability of class 1 (having a sleep disorder)
            logger.info(f"Prediction probability: {sleep_disorder_prob}")
            
            # Calculate sleep quality score (inverse of disorder probability)
            sleep_quality_score = 10 * (1 - sleep_disorder_prob)
        except Exception as model_error:
            logger.error(f"Error during model prediction: {str(model_error)}")
            # Fallback to a simple prediction if probabilistic prediction fails
            prediction = model.predict(input_df)[0]
            sleep_quality_score = 5.0 if prediction else 8.0
            sleep_disorder_prob = 0.5 if prediction else 0.2
        
        # Calculate contributing factors
        contributing_factors = calculate_contributing_factors(processed_data)
        
        # Generate personalized recommendations
        recommendations = generate_recommendations(processed_data, contributing_factors)
        
        # Generate sleep interruption windows based on the disorder probability
        interruption_windows = []
        if sleep_disorder_prob > 0.3:  # Only predict interruptions for higher probability of sleep disorder
            num_interruptions = max(1, int(sleep_disorder_prob * 5))  # Scale by probability
            for i in range(num_interruptions):
                # Generate times between 11 PM and 6 AM
                hour = np.random.randint(23, 29) % 24
                minute = np.random.randint(0, 60)
                duration = np.random.randint(10, 30)  # Duration in minutes
                
                start_time = f"{hour:02d}:{minute:02d}"
                end_minute = (minute + duration) % 60
                end_hour = (hour + (minute + duration) // 60) % 24
                end_time = f"{end_hour:02d}:{end_minute:02d}"
                
                interruption_windows.append({
                    "startTime": start_time,
                    "endTime": end_time,
                    "probability": round(0.4 + (sleep_disorder_prob * 0.5), 2)  # Scale probability by disorder probability
                })
        
        # Prepare response
        response = {
            "predictionScore": round(sleep_quality_score, 2),
            "normalizedScore": round(sleep_quality_score / 10, 2),  # Normalize to 0-1
            "sleepDisorderProbability": round(sleep_disorder_prob, 2),
            "predictedInterruptionCount": len(interruption_windows),
            "predictedInterruptionWindows": interruption_windows,
            "contributingFactors": contributing_factors,
            "recommendations": recommendations,
            "timestamp": datetime.datetime.now().isoformat()
        }
        
        logger.info(f"Returning prediction response: {json.dumps(response)}")
        return jsonify(response)
    
    except Exception as e:
        logger.error(f"Error in predict endpoint: {str(e)}", exc_info=True)
        return jsonify({"error": str(e)}), 500

def calculate_contributing_factors(features):
    """Calculate how much each feature contributes to the prediction based on the Sleep Health Dataset"""
    contributing_factors = {}
    
    # Age impact (higher age is typically worse for sleep quality)
    if 'Age' in features and features['Age'] > 0:
        age_factor = min(1.0, max(0, (features['Age'] - 25) / 50))  # Normalize to 0-1, impact starts after age 25
        contributing_factors['age'] = round(age_factor, 2)
    
    # Physical activity impact (higher is better for sleep up to a point)
    if 'Physical Activity Level' in features and features['Physical Activity Level'] > 0:
        activity = features['Physical Activity Level']
        if activity <= 60:
            factor = activity / 60  # Positive impact up to 60 minutes
        else:
            factor = 1.0 - min(0.5, (activity - 60) / 120)  # Diminishing returns after 60 minutes
        contributing_factors['physical_activity'] = round(factor, 2)
    
    # Stress level impact (higher is worse)
    if 'Stress Level' in features and features['Stress Level'] > 0:
        stress_factor = min(1.0, features['Stress Level'] / 10)  # Normalize to 0-1
        contributing_factors['stress_level'] = round(stress_factor, 2)
    
    # Sleep duration impact (deviation from optimal 7-8 hours)
    if 'Sleep Duration' in features and features['Sleep Duration'] > 0:
        optimal_sleep = 7.5
        deviation = abs(features['Sleep Duration'] - optimal_sleep)
        sleep_factor = min(1.0, deviation / 3.5)  # Normalize to 0-1
        contributing_factors['sleep_duration'] = round(sleep_factor, 2)
    
    # Heart rate impact (deviation from optimal range 60-70 BPM)
    if 'Heart Rate' in features and features['Heart Rate'] > 0:
        optimal_hr = 65
        deviation = abs(features['Heart Rate'] - optimal_hr)
        hr_factor = min(1.0, deviation / 35)  # Normalize to 0-1
        contributing_factors['heart_rate'] = round(hr_factor, 2)
    
    # Daily steps impact (lower is worse, optimal is 7000-10000)
    if 'Daily Steps' in features and features['Daily Steps'] > 0:
        if features['Daily Steps'] < 7000:
            steps_factor = min(1.0, (7000 - features['Daily Steps']) / 7000)  # Less steps than optimal
        else:
            steps_factor = 0  # Meets or exceeds step goal
        contributing_factors['daily_steps'] = round(steps_factor, 2)
    
    # BMI Category impact
    if 'BMI Category' in features:
        bmi_factor = 0
        if features['BMI Category'] == 'Obese':
            bmi_factor = 0.8
        elif features['BMI Category'] == 'Overweight':
            bmi_factor = 0.5
        elif features['BMI Category'] == 'Underweight':
            bmi_factor = 0.4
        # Normal weight has 0 impact
        
        if bmi_factor > 0:
            contributing_factors['bmi'] = round(bmi_factor, 2)
    
    # Gender impact - minor factor
    if 'Gender' in features:
        if features['Gender'] == 'Male':
            contributing_factors['gender'] = 0.1  # Minor impact
    
    # For back-compatibility with old features
    # Caffeine intake (from dietary data)
    if 'caffeine_intake_mg' in features and features['caffeine_intake_mg'] > 0:
        caffeine_factor = min(1.0, features['caffeine_intake_mg'] / 300)  # Normalize to 0-1
        contributing_factors['caffeine_intake'] = round(caffeine_factor, 2)
    
    # Screen time (from environmental data)
    if 'screen_time_minutes' in features and features['screen_time_minutes'] > 0:
        screen_factor = min(1.0, features['screen_time_minutes'] / 180)  # Normalize to 0-1
        contributing_factors['screen_time'] = round(screen_factor, 2)
    
    return contributing_factors

def generate_recommendations(features, factors):
    """Generate personalized recommendations based on contributing factors"""
    recommendations = []
    
    # Sort factors by contribution value (highest first)
    sorted_factors = sorted(factors.items(), key=lambda x: x[1], reverse=True)
    
    # Generate targeted recommendations for the top contributing factors
    for factor_name, factor_value in sorted_factors[:3]:  # Focus on top 3 factors
        if factor_value >= 0.3:  # Only consider significant factors
            if factor_name == 'age':
                recommendations.append("As we age, sleep quality naturally changes. Consider discussing age-related sleep changes with your healthcare provider.")
            
            elif factor_name == 'physical_activity':
                recommendations.append("Aim for 30-60 minutes of moderate exercise daily, but try to complete your workout at least 2-3 hours before bedtime.")
            
            elif factor_name == 'stress_level':
                recommendations.append("Practice stress reduction techniques like meditation, deep breathing, or progressive muscle relaxation before bedtime.")
            
            elif factor_name == 'sleep_duration':
                if 'Sleep Duration' in features:
                    if features['Sleep Duration'] < 7:
                        recommendations.append("You may not be getting enough sleep. Aim for 7-9 hours of sleep per night for optimal health.")
                    elif features['Sleep Duration'] > 9:
                        recommendations.append("Too much sleep can sometimes be as problematic as too little. Try to maintain a consistent 7-9 hour sleep schedule.")
                else:
                    recommendations.append("Maintain a consistent sleep schedule with 7-9 hours of sleep per night.")
            
            elif factor_name == 'heart_rate':
                recommendations.append("Your heart rate may be affecting your sleep quality. Regular cardiovascular exercise and relaxation techniques can help regulate heart rate.")
            
            elif factor_name == 'daily_steps':
                recommendations.append("Try to increase your daily physical activity to at least 7,000-10,000 steps per day for better sleep quality.")
            
            elif factor_name == 'bmi':
                recommendations.append("Your BMI category may be affecting your sleep. Consider discussing weight management strategies with your healthcare provider.")
            
            elif factor_name == 'caffeine_intake':
                recommendations.append("Limit caffeine consumption, especially after noon, as it can remain in your system for up to 8 hours.")
            
            elif factor_name == 'screen_time':
                recommendations.append("Reduce screen time at least 1-2 hours before bed and use blue light filters on devices when using them in the evening.")
    
    # Add general recommendations if we don't have enough specific ones
    if len(recommendations) < 2:
        general_recommendations = [
            "Maintain a consistent sleep schedule, even on weekends.",
            "Create a relaxing bedtime routine to signal your body it's time to sleep.",
            "Ensure your bedroom is dark, quiet, and at a comfortable temperature (around 65°F or 18°C).",
            "Avoid large meals, alcohol, and nicotine close to bedtime.",
            "Exercise regularly, but not too close to bedtime."
        ]
        
        # Add general recommendations until we have at least 3 total
        for rec in general_recommendations:
            if rec not in recommendations:
                recommendations.append(rec)
                if len(recommendations) >= 3:
                    break
    
    return recommendations

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=True)
