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
        'Sleep Disorder': sleep_disorder_type
    })
    
    return data

def preprocess_data(df):
    """Preprocess the dataset for training"""
    print("Preprocessing data...")
    
    # Convert Sleep Disorder to binary target (1 for any disorder, 0 for None)
    df['Sleep Disorder Binary'] = df['Sleep Disorder'].apply(lambda x: 0 if x == 'None' else 1)
    
    # Define numerical and categorical features
    numerical_features = ['Age', 'Sleep Duration', 'Physical Activity Level', 
                         'Heart Rate', 'Daily Steps', 'Stress Level']
    
    categorical_features = ['Gender', 'BMI Category']
    
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
