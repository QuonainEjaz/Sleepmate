import pandas as pd
import numpy as np
import joblib
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.metrics import classification_report, accuracy_score
import os

# Define model path
MODEL_PATH = os.path.join(os.path.dirname(__file__), 'sleep_model.pkl')

# Function to download dataset - for actual use, you'd download from Kaggle
def get_dataset():
    """
    In a real scenario, you would download the dataset from Kaggle.
    For this example, we'll create a synthetic dataset based on the described features.
    """
    print("Creating synthetic dataset based on Sleep Health and Lifestyle Dataset schema...")
    
    # Create synthetic data with similar properties to the Kaggle dataset
    np.random.seed(42)
    n_samples = 500
    
    # Generate features
    age = np.random.randint(18, 80, n_samples)
    gender = np.random.choice(['Male', 'Female'], n_samples)
    bmi_categories = np.random.choice(['Normal', 'Overweight', 'Obese', 'Underweight'], n_samples, 
                                     p=[0.45, 0.35, 0.15, 0.05])
    sleep_duration = np.random.normal(7, 1.5, n_samples)
    sleep_duration = np.clip(sleep_duration, 3, 11)  # Clip to reasonable range
    
    physical_activity = np.random.normal(45, 20, n_samples)
    physical_activity = np.clip(physical_activity, 0, 120)
    
    heart_rate = np.random.normal(70, 8, n_samples)
    heart_rate = np.clip(heart_rate, 55, 100)
    
    daily_steps = np.random.normal(7000, 2500, n_samples)
    daily_steps = np.clip(daily_steps, 1000, 15000)
    
    stress_level = np.random.randint(1, 11, n_samples)

    # New features from Sleep Patterns screen
    weekday_bedtime_hour = np.random.randint(21, 24, n_samples) # 9 PM to 12 AM
    weekday_bedtime_minute = np.random.choice([0, 30], n_samples)
    weekday_wake_up_hour = np.random.randint(6, 10, n_samples) # 6 AM to 10 AM
    weekday_wake_up_minute = np.random.choice([0, 30], n_samples)
    weekend_bedtime_hour = np.random.choice([22, 23, 0, 1], n_samples) # 10 PM to 1 AM
    weekend_bedtime_minute = np.random.choice([0, 30], n_samples)
    weekend_wake_up_hour = np.random.randint(7, 12, n_samples) # 7 AM to 12 PM
    weekend_wake_up_minute = np.random.choice([0, 30], n_samples)
    awakenings_during_night = np.random.randint(0, 5, n_samples)
    rate_sleep_quality = np.random.randint(1, 6, n_samples) # 1-5 scale
    use_electronic_devices_before_bed = np.random.choice([True, False], n_samples)
    how_relaxed_before_sleep = np.random.randint(1, 6, n_samples) # 1-5 scale

    # New features from Dietary Habits screen
    take_breakfast = np.random.choice([True, False], n_samples)
    breakfast_time_hour = np.random.randint(7, 10, n_samples)
    breakfast_time_minute = np.random.choice([0, 30], n_samples)
    breakfast_food_type = np.random.choice(['Carbohydrates', 'Proteins', 'Dairy', 'Beverage intake', 'Fruits and Vegetables'], n_samples)
    breakfast_portion_size = np.random.uniform(200, 500, n_samples) # grams

    do_lunch = np.random.choice([True, False], n_samples)
    lunch_time_hour = np.random.randint(12, 15, n_samples)
    lunch_time_minute = np.random.choice([0, 30], n_samples)
    lunch_food_type = np.random.choice(['Carbohydrates', 'Proteins', 'Fats', 'Beverage intake', 'Fruits and Vegetables'], n_samples)
    lunch_portion_size = np.random.uniform(300, 600, n_samples) # grams

    have_dinner = np.random.choice([True, False], n_samples)
    dinner_time_hour = np.random.randint(18, 22, n_samples)
    dinner_time_minute = np.random.choice([0, 30], n_samples)
    dinner_food_type = np.random.choice(['Carbohydrates', 'Proteins', 'Fats', 'Beverage intake', 'Fruits and Vegetables'], n_samples)
    dinner_portion_size = np.random.uniform(300, 600, n_samples) # grams

    no_of_meals_per_day = np.random.randint(2, 5, n_samples)

    # New features from Environmental Factors screen
    light_intensity = np.random.uniform(100, 1000, n_samples) # lux
    temperature = np.random.uniform(18, 25, n_samples) # Celsius
    sound_exposure = np.random.choice(['Quiet (<30 dB)', 'Moderate (30-60 dB)', 'Loud (>60 dB)'], n_samples)
    
    # Create dependent variable - sleep disorder
    # We'll use a probability model to generate realistic outcomes
    sleep_disorder_prob = (
        0.01 * (age - 40) +  # Age factor
        0.05 * (heart_rate - 70) +  # Heart rate factor
        -0.2 * (sleep_duration - 7) +  # Sleep duration factor (less sleep = more problems)
        0.1 * (stress_level - 5) +  # Stress factor
        -0.00005 * (daily_steps - 7000) +  # Steps factor (more steps = less problems)
        -0.002 * (physical_activity - 45) +  # Activity factor
        0.1 * (bmi_categories == 'Obese') +  # BMI factor
        0.05 * (bmi_categories == 'Overweight') +
        -0.05 * (bmi_categories == 'Normal') +
        -0.02 * (gender == 'Female')  # Slight gender factor
    )
    
    # Normalize probabilities to 0-1 range
    sleep_disorder_prob = (sleep_disorder_prob - min(sleep_disorder_prob)) / (max(sleep_disorder_prob) - min(sleep_disorder_prob))
    
    # Generate sleep disorders
    sleep_disorder = np.random.binomial(1, sleep_disorder_prob)
    
    # Create specific disorders
    sleep_disorder_type = ['None'] * n_samples
    for i in range(n_samples):
        if sleep_disorder[i] == 1:
            sleep_disorder_type[i] = np.random.choice(['Insomnia', 'Sleep Apnea', 'Restless Legs Syndrome'], p=[0.5, 0.3, 0.2])
    
    # Generate sleep quality (0-10)
    base_quality = 7.0
    sleep_quality = base_quality - (
        0.2 * (age - 40) / 40 +
        0.5 * (sleep_disorder == 1) +
        0.5 * (stress_level / 10) +
        -0.3 * (sleep_duration - 7) / 4 +
        -0.2 * (physical_activity / 100)
    )
    sleep_quality = np.clip(sleep_quality + np.random.normal(0, 0.5, n_samples), 1, 10)
    
    # Create DataFrame
    data = pd.DataFrame({
        'Age': age,
        'Gender': gender,
        'BMI Category': bmi_categories,
        'Sleep Duration': sleep_duration,
        'Physical Activity Level': physical_activity,
        'Heart Rate': heart_rate,
        'Daily Steps': daily_steps,
        'Stress Level': stress_level,
        'Sleep Quality': sleep_quality,
        'Sleep Disorder': sleep_disorder_type,

        # Sleep Patterns
        'Weekday Bedtime Hour': weekday_bedtime_hour,
        'Weekday Bedtime Minute': weekday_bedtime_minute,
        'Weekday Wake-up Hour': weekday_wake_up_hour,
        'Weekday Wake-up Minute': weekday_wake_up_minute,
        'Weekend Bedtime Hour': weekend_bedtime_hour,
        'Weekend Bedtime Minute': weekend_bedtime_minute,
        'Weekend Wake-up Hour': weekend_wake_up_hour,
        'Weekend Wake-up Minute': weekend_wake_up_minute,
        'Awakenings During Night': awakenings_during_night,
        'Rate Sleep Quality': rate_sleep_quality,
        'Use Electronic Devices Before Bed': use_electronic_devices_before_bed,
        'How Relaxed Before Sleep': how_relaxed_before_sleep,

        # Dietary Habits
        'Take Breakfast': take_breakfast,
        'Breakfast Time Hour': breakfast_time_hour,
        'Breakfast Time Minute': breakfast_time_minute,
        'Breakfast Food Type': breakfast_food_type,
        'Breakfast Portion Size': breakfast_portion_size,
        'Do Lunch': do_lunch,
        'Lunch Time Hour': lunch_time_hour,
        'Lunch Time Minute': lunch_time_minute,
        'Lunch Food Type': lunch_food_type,
        'Lunch Portion Size': lunch_portion_size,
        'Have Dinner': have_dinner,
        'Dinner Time Hour': dinner_time_hour,
        'Dinner Time Minute': dinner_time_minute,
        'Dinner Food Type': dinner_food_type,
        'Dinner Portion Size': dinner_portion_size,
        'No. of Meals Per Day': no_of_meals_per_day,

        # Environmental Factors
        'Light Intensity': light_intensity,
        'Temperature': temperature,
        'Sound Exposure': sound_exposure
    })
    
    return data

def preprocess_data(df):
    """Preprocess the dataset for training"""
    print("Preprocessing data...")
    
    # Convert Sleep Disorder to binary target (1 for any disorder, 0 for None)
    df['Sleep Disorder Binary'] = df['Sleep Disorder'].apply(lambda x: 0 if x == 'None' else 1)
    
    # Define numerical and categorical features
    numerical_features = [
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
    
    categorical_features = [
        'Gender', 'BMI Category',
        'Use Electronic Devices Before Bed', 'Take Breakfast', 'Breakfast Food Type',
        'Do Lunch', 'Lunch Food Type', 'Have Dinner', 'Dinner Food Type',
        'Sound Exposure'
    ]
    
    # Define preprocessor
    preprocessor = ColumnTransformer(
        transformers=[
            ('num', StandardScaler(), numerical_features),
            ('cat', OneHotEncoder(handle_unknown='ignore'), categorical_features)
        ])
    
    # Extract features and target
    X = df[numerical_features + categorical_features]
    y = df['Sleep Disorder Binary']  # Binary classification target
    
    # Split the data
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    
    return X_train, X_test, y_train, y_test, preprocessor, numerical_features, categorical_features

def train_model(X_train, y_train, preprocessor):
    """Train a Random Forest Classifier model"""
    print("Training Random Forest Classifier...")
    
    # Create the model pipeline
    model = Pipeline(steps=[
        ('preprocessor', preprocessor),
        ('classifier', RandomForestClassifier(n_estimators=100, random_state=42))
    ])
    
    # Train the model
    model.fit(X_train, y_train)
    
    return model

def evaluate_model(model, X_test, y_test):
    """Evaluate model performance"""
    print("Evaluating model...")
    
    # Make predictions
    y_pred = model.predict(X_test)
    
    # Calculate accuracy
    accuracy = accuracy_score(y_test, y_pred)
    print(f"Accuracy: {accuracy:.4f}")
    
    # Print classification report
    print("Classification Report:")
    print(classification_report(y_test, y_pred))
    
    # Get feature importances
    # Extract feature names from preprocessor
    feature_names = []
    for name, trans, cols in model.named_steps['preprocessor'].transformers_:
        if name == 'num':
            feature_names.extend(cols)
        elif name == 'cat':
            for col in cols:
                feature_names.extend([f"{col}_{c}" for c in trans.categories_[0]])
    
    # Get feature importances from Random Forest
    importances = model.named_steps['classifier'].feature_importances_
    
    # Print top 5 features
    if len(feature_names) == len(importances):
        indices = np.argsort(importances)[::-1]
        print("\nTop 5 important features:")
        for i in range(min(5, len(feature_names))):
            print(f"{feature_names[indices[i]]}: {importances[indices[i]]:.4f}")
    
    return accuracy, y_pred

def save_model(model, numerical_features, categorical_features):
    """Save the trained model and feature lists"""
    print(f"Saving model to {MODEL_PATH}...")
    
    # Create a dictionary with the model and feature information
    model_info = {
        'model': model,
        'numerical_features': numerical_features,
        'categorical_features': categorical_features
    }
    
    # Save to disk
    joblib.dump(model_info, MODEL_PATH)
    print("Model saved successfully!")

def main():
    """Main function to execute the model training process"""
    print("Starting sleep prediction model training...")
    
    # Get dataset
    df = get_dataset()
    print(f"Dataset shape: {df.shape}")
    
    # Preprocess data
    X_train, X_test, y_train, y_test, preprocessor, numerical_features, categorical_features = preprocess_data(df)
    
    # Train model
    model = train_model(X_train, y_train, preprocessor)
    
    # Evaluate model
    evaluate_model(model, X_test, y_test)
    
    # Save model
    save_model(model, numerical_features, categorical_features)
    
    print("Training complete!")

if __name__ == "__main__":
    main()
