# Sleep Prediction ML Service

This is a Flask-based machine learning service that predicts sleep quality and interruptions based on various factors like environmental conditions, dietary habits, and user activities.

## Features

- Predicts sleep quality score
- Identifies potential sleep interruption windows
- Calculates contributing factors to sleep quality
- Generates personalized recommendations for improving sleep quality
- Pre-trained with synthetic data for immediate use

## Setup and Installation

1. Install the required Python packages:
```
pip install -r requirements.txt
```

2. Run the Flask application:
```
python app.py
```

The service will start on port 5000 by default.

## API Endpoints

### Health Check
- **GET /health**
  - Returns the status of the ML service

### Prediction
- **POST /predict**
  - Accepts JSON with sleep-related parameters
  - Returns prediction results including sleep quality, interruptions, contributing factors, and recommendations

## Example Request

```json
{
  "caffeine_intake_mg": 150,
  "exercise_minutes": 30,
  "screen_time_minutes": 120,
  "stress_level": 3.5,
  "sleep_latency_minutes": 20,
  "ambient_temperature": 24,
  "light_intensity_lux": 200,
  "noise_level_db": 40,
  "meal_regularity": "regular",
  "food_types": "balanced"
}
```

## Example Response

```json
{
  "predictionScore": 6.75,
  "normalizedScore": 0.67,
  "predictedInterruptionCount": 1,
  "predictedInterruptionWindows": [
    {
      "startTime": "02:15",
      "endTime": "02:35",
      "probability": 0.8
    }
  ],
  "contributingFactors": {
    "caffeine_intake": 0.5,
    "screen_time": 0.67,
    "stress_level": 0.7
  },
  "recommendations": [
    "Reduce caffeine intake, especially after 2 PM",
    "Limit screen time to at least 1 hour before bedtime",
    "Practice relaxation techniques like deep breathing before bed"
  ],
  "timestamp": "2023-04-10T12:34:56.789Z"
}
```
