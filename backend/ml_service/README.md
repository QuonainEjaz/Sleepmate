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

### Personalized Sleep Prediction
- **POST /personalized_prediction**
  - Accepts comprehensive JSON with user's sleep, diet, and lifestyle data
  - Returns personalized prediction with friendly, professional output including:
    - Prediction summary with emoji
    - Detailed sleep quality analysis
    - Sleep disorder risk probability
    - Customized recommendations using the user's name

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

## Personalized Prediction Example

### Example Request

```json
{
  "userName": "Quonain",
  "Age": 28,
  "Gender": "Male",
  "BMI Category": "Normal",
  "weekdayBedtimeHour": 23,
  "weekdayBedtimeMinute": 30,
  "weekdayWakeUpHour": 7,
  "weekdayWakeUpMinute": 0,
  "weekendBedtimeHour": 1,
  "weekendBedtimeMinute": 0,
  "weekendWakeUpHour": 9,
  "weekendWakeUpMinute": 30,
  "awakeningsDuringNight": 2,
  "rateSleepQuality": 3,
  "useElectronicDevicesBeforeBed": true,
  "howRelaxedBeforeSleep": 2,
  "takeBreakfast": true,
  "breakfastTimeHour": 8,
  "breakfastTimeMinute": 0,
  "breakfastFoodType": "Proteins",
  "breakfastPortionSize": 300,
  "doLunch": true,
  "lunchTimeHour": 13,
  "lunchTimeMinute": 0,
  "lunchFoodType": "Carbohydrates",
  "lunchPortionSize": 500,
  "haveDinner": true,
  "dinnerTimeHour": 21,
  "dinnerTimeMinute": 30,
  "dinnerFoodType": "Proteins",
  "dinnerPortionSize": 400,
  "noOfMealsPerDay": 3,
  "lightIntensity": 50,
  "temperature": 23,
  "soundExposure": "Moderate (30-60 dB)",
  "Sleep Duration": 6.5,
  "Physical Activity Level": 45,
  "Heart Rate": 72,
  "Daily Steps": 8500,
  "Stress Level": 7
}
```

### Example Response

```json
{
  "prediction": "😴 Your sleep quality needs attention. Let's work on it!",
  "detailedAnalysis": "We've analyzed your sleep data and found several factors that may affect your rest. You're averaging only 6.5 hours of sleep (slightly below the recommended 7-9 hours). Night awakenings (2 times) may be reducing your deep sleep quality. Device use before bed is likely affecting your ability to fall asleep due to blue light exposure. Your relaxation level before sleep is below average (2/5), which may be affecting sleep onset. Room temperature (23°C) is slightly above the ideal range of 16-20°C for optimal sleep. Moderate (30-60 dB) noise levels may impact your ability to rest fully. Light intensity in your room (50 units) may be interfering with melatonin production. Your stress level is relatively high (7/10), which can affect sleep quality. Late dinner (at 21:30) may be affecting your digestion during sleep.",
  "sleepDisorderProbability": 0.55,
  "recommendations": "Dear Quonain, you can follow these recommendations for better sleep experience! Sleep at least 7 hours on weekdays (currently 6.5 hours). Reduce device usage 1 hour before bed to improve melatonin production. Try relaxation techniques like deep breathing or meditation before bed. Maintain bedroom temperature between 16-20°C (currently 23°C). Create a quieter sleeping environment or use white noise to mask disruptive sounds. Reduce light exposure in your bedroom with blackout curtains or an eye mask. Practice stress management techniques like mindfulness or journaling. Have dinner at least 2-3 hours before bedtime to improve digestion. Small adjustments can greatly improve your sleep quality!",
  "predictionScore": 2.8,
  "normalizedScore": 0.28,
  "predictedInterruptionCount": 2,
  "predictedInterruptionWindows": [
    {
      "startTime": "00:50",
      "endTime": "00:56",
      "probability": 0.68
    },
    {
      "startTime": "02:32",
      "endTime": "02:41",
      "probability": 0.68
    }
  ]
}
```
