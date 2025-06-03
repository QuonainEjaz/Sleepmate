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
from sleep_prediction_service import SleepPredictionService

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
    'Heart Rate', 'Daily Steps', 'Stress Level',
    'Weekday Bedtime Hour', 'Weekday Bedtime Minute', 'Weekday Wake-up Hour', 'Weekday Wake-up Minute',
    'Weekend Bedtime Hour', 'Weekend Bedtime Minute', 'Weekend Wake-up Hour', 'Weekend Wake-up Minute',
    'Awakenings During Night', 'Rate Sleep Quality', 'How Relaxed Before Sleep',
    'Breakfast Time Hour', 'Breakfast Time Minute', 'Breakfast Portion Size',
    'Lunch Time Hour', 'Lunch Time Minute', 'Lunch Portion Size',
    'Dinner Time Hour', 'Dinner Time Minute', 'Dinner Portion Size',
    'No. of Meals Per Day',
    'Light Intensity', 'Temperature'
]

CATEGORICAL_FEATURES = [
    'Gender', 'BMI Category',
    'Use Electronic Devices Before Bed', 'Take Breakfast', 'Breakfast Food Type',
    'Do Lunch', 'Lunch Food Type', 'Have Dinner', 'Dinner Food Type',
    'Sound Exposure'
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

        # Sleep Patterns
        'weekdayBedtimeHour': 'Weekday Bedtime Hour',
        'weekdayBedtimeMinute': 'Weekday Bedtime Minute',
        'weekdayWakeUpHour': 'Weekday Wake-up Hour',
        'weekdayWakeUpMinute': 'Weekday Wake-up Minute',
        'weekendBedtimeHour': 'Weekend Bedtime Hour',
        'weekendBedtimeMinute': 'Weekend Bedtime Minute',
        'weekendWakeUpHour': 'Weekend Wake-up Hour',
        'weekendWakeUpMinute': 'Weekend Wake-up Minute',
        'awakeningsDuringNight': 'Awakenings During Night',
        'rateSleepQuality': 'Rate Sleep Quality',
        'useElectronicDevicesBeforeBed': 'Use Electronic Devices Before Bed',
        'howRelaxedBeforeSleep': 'How Relaxed Before Sleep',

        # Dietary Habits
        'takeBreakfast': 'Take Breakfast',
        'breakfastTimeHour': 'Breakfast Time Hour',
        'breakfastTimeMinute': 'Breakfast Time Minute',
        'breakfastFoodType': 'Breakfast Food Type',
        'breakfastPortionSize': 'Breakfast Portion Size',
        'doLunch': 'Do Lunch',
        'lunchTimeHour': 'Lunch Time Hour',
        'lunchTimeMinute': 'Lunch Time Minute',
        'lunchFoodType': 'Lunch Food Type',
        'lunchPortionSize': 'Lunch Portion Size',
        'haveDinner': 'Have Dinner',
        'dinnerTimeHour': 'Dinner Time Hour',
        'dinnerTimeMinute': 'Dinner Time Minute',
        'dinnerFoodType': 'Dinner Food Type',
        'dinnerPortionSize': 'Dinner Portion Size',
        'noOfMealsPerDay': 'No. of Meals Per Day',

        # Environmental Factors
        'lightIntensity': 'Light Intensity',
        'temperature': 'Temperature',
        'soundExposure': 'Sound Exposure',
        
        # Common alternate field names (existing ones)
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
            
            # Sleep Patterns Defaults
            elif feature == 'Weekday Bedtime Hour': processed_data[feature] = 22
            elif feature == 'Weekday Bedtime Minute': processed_data[feature] = 0
            elif feature == 'Weekday Wake-up Hour': processed_data[feature] = 7
            elif feature == 'Weekday Wake-up Minute': processed_data[feature] = 0
            elif feature == 'Weekend Bedtime Hour': processed_data[feature] = 23
            elif feature == 'Weekend Bedtime Minute': processed_data[feature] = 0
            elif feature == 'Weekend Wake-up Hour': processed_data[feature] = 9
            elif feature == 'Weekend Wake-up Minute': processed_data[feature] = 0
            elif feature == 'Awakenings During Night': processed_data[feature] = 1
            elif feature == 'Rate Sleep Quality': processed_data[feature] = 3
            elif feature == 'Use Electronic Devices Before Bed': processed_data[feature] = False
            elif feature == 'How Relaxed Before Sleep': processed_data[feature] = 3

            # Dietary Habits Defaults
            elif feature == 'Take Breakfast': processed_data[feature] = True
            elif feature == 'Breakfast Time Hour': processed_data[feature] = 8
            elif feature == 'Breakfast Time Minute': processed_data[feature] = 0
            elif feature == 'Breakfast Food Type': processed_data[feature] = 'Proteins'
            elif feature == 'Breakfast Portion Size': processed_data[feature] = 300
            elif feature == 'Do Lunch': processed_data[feature] = True
            elif feature == 'Lunch Time Hour': processed_data[feature] = 13
            elif feature == 'Lunch Time Minute': processed_data[feature] = 0
            elif feature == 'Lunch Food Type': processed_data[feature] = 'Carbohydrates'
            elif feature == 'Lunch Portion Size': processed_data[feature] = 400
            elif feature == 'Have Dinner': processed_data[feature] = True
            elif feature == 'Dinner Time Hour': processed_data[feature] = 20
            elif feature == 'Dinner Time Minute': processed_data[feature] = 0
            elif feature == 'Dinner Food Type': processed_data[feature] = 'Proteins'
            elif feature == 'Dinner Portion Size': processed_data[feature] = 400
            elif feature == 'No. of Meals Per Day': processed_data[feature] = 3

            # Environmental Factors Defaults
            elif feature == 'Light Intensity': processed_data[feature] = 300
            elif feature == 'Temperature': processed_data[feature] = 22
            elif feature == 'Sound Exposure': processed_data[feature] = 'Moderate (30-60 dB)'
    
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

def generate_sleep_analysis(features, prediction_score, user_name, user_age, user_gender):
    """Generate detailed sleep analysis based on user data and prediction score"""
    analysis = []
    
    # Personalized greeting with name
    analysis.append(f"Hello {user_name}! Here's your personalized sleep analysis:")
    analysis.append("="*50)
    
    # Age and gender specific considerations
    age = features.get('Age', user_age)
    gender = features.get('Gender', user_gender).lower()
    
    # Basic sleep duration analysis with age and gender context
    sleep_duration = features.get('Sleep Duration', 0)
    if age >= 18 and age <= 64:
        if sleep_duration < 7:
            analysis.append(f"At {age} years old, you're getting {sleep_duration:.1f} hours of sleep, which is below the recommended 7-9 hours for adults.")
        elif sleep_duration > 9:
            analysis.append(f"At {age} years old, you're getting {sleep_duration:.1f} hours of sleep, which is more than the recommended amount for adults.")
        else:
            analysis.append(f"Your sleep duration of {sleep_duration:.1f} hours is within the recommended range for adults.")
    else:
        analysis.append(f"Your current sleep duration is {sleep_duration:.1f} hours.")
    
    # Gender-specific considerations
    if gender == 'female':
        analysis.append("As a woman, you might experience sleep pattern variations due to hormonal changes. "
                      "This is normal but can affect sleep quality.")
    
    # Sleep quality analysis with personalized tips
    sleep_quality = features.get('Rate Sleep Quality', 3)
    if sleep_quality < 3:
        analysis.append(f"Your reported sleep quality is below average. Let's work on improving this, {user_name}!")
    elif sleep_quality > 3:
        analysis.append("Great job! Your reported sleep quality is above average.")
    
    # Environmental factors with personalized recommendations
    if features.get('Use Electronic Devices Before Bed', False):
        analysis.append(f"{user_name}, using electronic devices before bed is affecting your sleep quality due to blue light exposure. "
                      "Try using blue light filters or avoiding screens 1 hour before bed.")
    
    sound_level = features.get('Sound Exposure', '')
    if 'Loud' in sound_level:
        analysis.append("The noise levels in your environment might be disrupting your sleep. Consider using earplugs or white noise.")
    
    # Dietary factors with timing considerations
    dinner_time_hour = features.get('Dinner Time Hour', 20)
    if dinner_time_hour >= 21:
        analysis.append(f"{user_name}, eating dinner at {dinner_time_hour}:00 is quite late and might be affecting your sleep quality. "
                      "Try to have dinner at least 2-3 hours before bedtime.")
    
    # Age-specific recommendations
    if age > 50:
        analysis.append("As we get older, sleep patterns naturally change. You might find it helpful to maintain a consistent sleep schedule.")
    
    return analysis

@app.route('/predict', methods=['POST'])
def predict():
    try:
        # Get data from request
        data = request.get_json()
        logger.info(f"Received prediction request with data: {data}")
        
        # Get user's name if provided
        user_name = data.get('userName', 'there')
        
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
        input_df = pd.DataFrame([processed_data], columns=ALL_FEATURES)
        
        # Generate predictions
        try:
            # Convert processed data to DataFrame with correct feature order
            input_df = pd.DataFrame([processed_data], columns=ALL_FEATURES)
            
            # Make prediction with the model
            prediction_proba = model.predict_proba(input_df)
            # Get probability of good sleep (assuming class 0 is good sleep)
            good_sleep_prob = prediction_proba[0][0] if len(prediction_proba[0]) > 1 else 0.7
            sleep_disorder_prob = 1 - good_sleep_prob
            logger.info(f"Good sleep probability: {good_sleep_prob}, Disorder probability: {sleep_disorder_prob}")
            
            # Calculate sleep quality score (0-10 scale)
            sleep_quality_score = good_sleep_prob * 10
            
        except Exception as model_error:
            logger.error(f"Error during model prediction: {str(model_error)}")
            # Fallback to a simple prediction if probabilistic prediction fails
            good_sleep_prob = 0.7
            sleep_disorder_prob = 0.3
            sleep_quality_score = 7.0
        
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
        
        # Get user details
        user_age = int(processed_data.get('Age', 30))  # Default to 30 if not provided
        user_gender = processed_data.get('Gender', 'User')  # Default to 'User' if not provided
        
        # Generate detailed analysis with personalized insights
        sleep_analysis = generate_sleep_analysis(processed_data, good_sleep_prob, user_name, user_age, user_gender)
        
        # Format the analysis with proper spacing
        analysis_text = "\n\n".join(sleep_analysis)
        
        # Add prediction summary with emoji for better readability
        score = round(good_sleep_prob * 10, 1)
        if score >= 8:
            emoji = "😊"
            summary = "Excellent!"
        elif score >= 6:
            emoji = "🙂"
            summary = "Good job!"
        else:
            emoji = "😴"
            summary = "Let's improve this!"
            
        prediction_summary = f"\n\n📊 Sleep Quality Score: {score}/10 {emoji}\n{summary}"
        
        # Calculate sleep duration in hours and minutes
        def format_duration(hours, minutes):
            if hours > 0 and minutes > 0:
                return f"{hours} hours and {minutes} minutes"
            elif hours > 0:
                return f"{hours} hours"
            else:
                return f"{minutes} minutes"
        
        # Calculate sleep duration from input data
        sleep_duration = processed_data.get('Sleep Duration', 7)  # Default to 7 hours if not provided
        
        # If we need to calculate it from bed/wake times
        if 'weekdayBedtimeHour' in processed_data and 'weekdayWakeUpHour' in processed_data:
            bedtime = datetime.time(
                hour=processed_data.get('weekdayBedtimeHour', 23),
                minute=processed_data.get('weekdayBedtimeMinute', 0)
            )
            wakeup = datetime.time(
                hour=processed_data.get('weekdayWakeUpHour', 7),
                minute=processed_data.get('weekdayWakeUpMinute', 0)
            )
            
            bedtime_dt = datetime.datetime.combine(datetime.date.today(), bedtime)
            wakeup_dt = datetime.datetime.combine(
                datetime.date.today() + datetime.timedelta(days=1) 
                if bedtime > wakeup 
                else datetime.date.today(), 
                wakeup
            )
            sleep_duration = (wakeup_dt - bedtime_dt).total_seconds() / 3600
        
        # Get user data
        user_name = data.get('userName', 'there')
        sleep_duration = processed_data.get('Sleep Duration', 6.5)
        awakenings = processed_data.get('awakeningsDuringNight', 0)
        stress_level = processed_data.get('Stress Level', 5)
        temperature = processed_data.get('temperature', 22)
        sound_level = processed_data.get('soundExposure', '').lower()
        
        # Generate prediction message
        score = round(good_sleep_prob * 10, 1)
        if score >= 8:
            prediction_message = "😊 Excellent! Your sleep quality is great!"
        elif score >= 6:
            prediction_message = "🙂 Good! Your sleep quality is decent but can be improved."
        else:
            prediction_message = "😴 Your sleep quality needs attention. Let's work on it!"
        
        # Generate detailed analysis
        analysis_parts = []
        
        # Sleep duration analysis
        if sleep_duration < 7:
            analysis_parts.append(f"You're averaging only {sleep_duration} hours of sleep on weekdays (slightly below the recommended 7-9 hours).")
        else:
            analysis_parts.append(f"Your sleep duration of {sleep_duration} hours is within the healthy range.")
        
        # Sleep quality factors
        if awakenings > 1:
            analysis_parts.append(f"You experience {awakenings} awakenings per night, which can disrupt your sleep cycles.")
            
        if processed_data.get('useElectronicDevicesBeforeBed', False):
            analysis_parts.append("Using electronic devices before bed may be affecting your ability to fall asleep.")
            
        if stress_level > 6:
            analysis_parts.append(f"Your stress level is {stress_level}/10, which might be impacting your sleep quality.")
        
        # Environmental factors
        if temperature > 22:
            analysis_parts.append(f"Your room temperature of {temperature}°C is slightly above the ideal range of 16-20°C for optimal sleep.")
            
        if 'moderate' in sound_level or 'loud' in sound_level:
            analysis_parts.append("The noise levels in your environment might be affecting your sleep quality.")
        
        # Join analysis parts
        detailed_analysis = "We've analyzed your sleep data and found several factors that may affect your rest. " + " ".join(analysis_parts)
        
        # Prepare response with all data
        response = {
            'prediction': prediction_message,
            'detailedAnalysis': detailed_analysis,
            'sleepDisorderProbability': round(sleep_disorder_prob, 2),
            'recommendations': generate_recommendations(processed_data, contributing_factors),
            'predictionScore': round(score, 1),
            'normalizedScore': round(score / 10, 2),
            'predictedInterruptionCount': len(interruption_windows),
            'predictedInterruptionWindows': interruption_windows,
            'timestamp': datetime.datetime.now().isoformat()
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
    user_name = features.get('userName', 'there')
    
    # Sort factors by contribution value (highest first)
    sorted_factors = sorted(factors.items(), key=lambda x: x[1], reverse=True)
    
    # Generate targeted recommendations based on contributing factors
    for factor_name, factor_value in sorted_factors:
        if factor_value >= 0.2:
            if factor_name == 'sleep_duration' and features.get('Sleep Duration', 7) < 7:
                recommendations.append("Sleep at least 7 hours on weekdays.")
            elif factor_name in ['screen_time', 'electronic_devices'] and features.get('useElectronicDevicesBeforeBed', False):
                recommendations.append("Reduce device usage 1 hour before bed to minimize blue light exposure.")
            elif factor_name == 'diet' and features.get('dietaryVariety', 0) < 3:
                recommendations.append("Add more variety to your meals with fruits, vegetables, and whole grains.")
            elif factor_name == 'temperature' and features.get('temperature', 0) > 22:
                recommendations.append("Keep your bedroom cooler (16-20°C) for better sleep quality.")
            elif factor_name == 'noise' and 'moderate' in str(features.get('soundExposure', '')).lower():
                recommendations.append("Use earplugs or white noise to block out disruptive sounds.")
            elif factor_name == 'stress' and features.get('Stress Level', 5) > 6:
                recommendations.append("Practice relaxation techniques like deep breathing or meditation before bed.")
            elif factor_name in ['caffeine', 'caffeine_intake']:
                recommendations.append("Avoid caffeine after 2 PM to prevent sleep disturbances.")
    
    # Add general recommendations if we need more
    general_recommendations = [
        "Maintain a consistent sleep schedule, even on weekends.",
        "Create a relaxing bedtime routine to signal your body it's time to sleep.",
        "Avoid large meals, alcohol, and nicotine close to bedtime.",
        "Get regular exercise, but finish at least 3 hours before bed.",
        "Make sure your bedroom is dark, quiet, and at a comfortable temperature.",
        "Expose yourself to natural light during the day to regulate your sleep-wake cycle.",
        "Consider using blackout curtains or a sleep mask if your room isn't dark enough.",
        "If you can't sleep, get out of bed and do something relaxing until you feel sleepy.",
        "Limit daytime naps to 20-30 minutes to avoid disrupting nighttime sleep.",
        "Try to resolve worries or concerns before bedtime by making a to-do list for the next day."
    ]
    
    # Add general recommendations until we have 5-7 total
    for rec in general_recommendations:
        if rec not in recommendations:
            recommendations.append(rec)
            if len(recommendations) >= 7:  # Aim for 5-7 recommendations
                break
    
    # Format the final recommendations message
    if recommendations:
        message = f"Dear {user_name}, you can follow these recommendations for better sleep experience!\n\n"
        message += "\n".join([f"• {rec}" for rec in recommendations])
        message += "\n\nSmall adjustments can greatly improve your sleep quality!"
        return message
    
    return f"Dear {user_name}, focus on maintaining good sleep hygiene. Keep a consistent sleep schedule and create a relaxing bedtime routine for better sleep!"

@app.route('/personalized_prediction', methods=['POST'])
def personalized_prediction():
    """
    Endpoint for personalized sleep prediction with detailed analysis and recommendations.
    Follows the format requested in the UI design.
    """
    try:
        # Get data from request
        data = request.get_json()
        logger.info(f"Received personalized prediction request with data: {data}")
        
        # Initialize the sleep prediction service
        prediction_service = SleepPredictionService()
        
        # Generate the prediction and analysis
        response = prediction_service.analyze_sleep_data(data)
        
        logger.info(f"Returning personalized prediction response")
        return jsonify(response)
    
    except Exception as e:
        logger.error(f"Error in personalized_prediction endpoint: {str(e)}", exc_info=True)
        return jsonify({
            "error": str(e),
            "prediction": "😴 We couldn't analyze your sleep data properly.",
            "detailedAnalysis": "There was an error processing your data. Please check your inputs and try again.",
            "recommendations": "Please ensure all required fields are filled correctly."
        }), 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=True)
