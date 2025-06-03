const axios = require('axios');

// Configuration for ML service
const ML_SERVICE_URL = process.env.ML_SERVICE_URL || 'http://localhost:5000';

// Function to check if ML service is available
async function checkMLServiceHealth() {
  try {
    const response = await axios.get(`${ML_SERVICE_URL}/health`);
    return response.data.status === 'healthy';
  } catch (error) {
    console.error('ML service health check failed:', error.message);
    return false;
  }
}

// Function to get prediction from ML service
async function getPrediction(data) {
  try {
    const response = await axios.post(`${ML_SERVICE_URL}/predict`, data);
    return response.data;
  } catch (error) {
    console.error('ML service prediction request failed:', error.message);
    throw new Error('Failed to get prediction from ML service: ' + error.message);
  }
}

// Map sleep data to ML model input format for the Sleep Health Dataset model
function mapSleepDataToMLInput(sleepData, environmentalData, dietaryData) {
  // Map to the new model features based on Sleep Health Dataset
  const mappedData = {
    // Default values for Sleep Health Dataset features
    'Age': 35,  // Default age
    'Gender': 'Male',  // Default gender
    'BMI Category': 'Normal',  // Default BMI category
    'Sleep Duration': 7.0,  // Default sleep duration in hours
    'Physical Activity Level': 45,  // Default physical activity in minutes
    'Heart Rate': 70,  // Default heart rate in BPM
    'Daily Steps': 7000,  // Default daily steps
    'Stress Level': 5,  // Default stress level (1-10)
    
    // Keep backward compatibility with old features
    'caffeine_intake_mg': 0,
    'screen_time_minutes': 0
  };

  // Map sleep data if available
  if (sleepData) {
    // Map sleep duration from sleepData if available
    if (sleepData.sleepDuration) {
      mappedData['Sleep Duration'] = parseFloat(sleepData.sleepDuration);
    }
    
    // Map stress level (convert from 1-5 to 1-10 scale)
    if (sleepData.stressLevel) {
      mappedData['Stress Level'] = Math.min(10, sleepData.stressLevel * 2);
    }
    
    // Map demographic data if available
    if (sleepData.userProfile) {
      if (sleepData.userProfile.age) {
        mappedData['Age'] = parseInt(sleepData.userProfile.age);
      }
      
      if (sleepData.userProfile.gender) {
        mappedData['Gender'] = sleepData.userProfile.gender === 'male' ? 'Male' : 'Female';
      }
      
      if (sleepData.userProfile.bmi) {
        const bmi = parseFloat(sleepData.userProfile.bmi);
        if (bmi < 18.5) {
          mappedData['BMI Category'] = 'Underweight';
        } else if (bmi >= 18.5 && bmi < 25) {
          mappedData['BMI Category'] = 'Normal';
        } else if (bmi >= 25 && bmi < 30) {
          mappedData['BMI Category'] = 'Overweight';
        } else {
          mappedData['BMI Category'] = 'Obese';
        }
      }
    }
    
    // Map physical activity data
    if (sleepData.activities) {
      if (sleepData.activities.exerciseMinutes) {
        mappedData['Physical Activity Level'] = parseFloat(sleepData.activities.exerciseMinutes);
      }
      
      if (sleepData.activities.dailySteps) {
        mappedData['Daily Steps'] = parseInt(sleepData.activities.dailySteps);
      }
      
      // Map backward compatible fields
      if (sleepData.activities.caffeineIntake) {
        mappedData.caffeine_intake_mg = parseFloat(sleepData.activities.caffeineIntake);
      }
      
      if (sleepData.activities.screenTimeMinutes) {
        mappedData.screen_time_minutes = parseFloat(sleepData.activities.screenTimeMinutes);
      }
    }
  }

  // Map environmental data if available
  if (environmentalData) {
    // Ambient temperature might influence heart rate slightly
    if (environmentalData.temperature) {
      const temp = parseFloat(environmentalData.temperature);
      // Adjust heart rate slightly based on temperature (higher temp, higher heart rate)
      const tempEffect = (temp - 22) * 0.5; // 0.5 BPM per degree C deviation from 22°C
      mappedData['Heart Rate'] = Math.max(60, Math.min(100, mappedData['Heart Rate'] + tempEffect));
    }
    
    // Light exposure can affect stress
    if (environmentalData.lightIntensity) {
      const lightIntensity = parseFloat(environmentalData.lightIntensity);
      // High light intensity might increase stress slightly
      if (lightIntensity > 300) {
        mappedData['Stress Level'] = Math.min(10, mappedData['Stress Level'] + 1);
      }
    }
    
    // Sound exposure can affect stress
    if (environmentalData.soundExposure) {
      if (environmentalData.soundExposure.includes('Loud')) {
        mappedData['Stress Level'] = Math.min(10, mappedData['Stress Level'] + 2);
      } else if (environmentalData.soundExposure.includes('Moderate')) {
        mappedData['Stress Level'] = Math.min(10, mappedData['Stress Level'] + 1);
      }
    }
  }

  // Map dietary data if available
  if (dietaryData) {
    // Meal regularity can affect sleep quality and stress levels
    let regularMeals = 0;
    if (dietaryData.isBreakfastRegular) regularMeals++;
    if (dietaryData.isLunchRegular) regularMeals++;
    if (dietaryData.isDinnerRegular) regularMeals++;
    
    // More regular meals generally means better sleep
    if (regularMeals < 2) {
      mappedData['Stress Level'] = Math.min(10, mappedData['Stress Level'] + 1);
    }
    
    // Analyze food types
    const allFoodTypes = [
      ...(dietaryData.selectedBreakfastFoodTypes || []),
      ...(dietaryData.selectedLunchFoodTypes || []),
      ...(dietaryData.selectedDinnerFoodTypes || [])
    ];
    
    // A balanced diet generally contributes to better sleep
    const isBalanced = allFoodTypes.includes('Proteins') && 
                      allFoodTypes.includes('Carbohydrates') && 
                      allFoodTypes.includes('Vegetables');
                      
    if (!isBalanced) {
      // Less balanced diet may increase stress slightly
      mappedData['Stress Level'] = Math.min(10, mappedData['Stress Level'] + 0.5);
    }
  }

  return mappedData;
}

module.exports = {
  checkMLServiceHealth,
  getPrediction,
  mapSleepDataToMLInput
};
