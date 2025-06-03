import json
import numpy as np
import datetime
from typing import Dict, Any, List, Optional, Union

class SleepPredictionService:
    """
    A service that analyzes sleep, diet, and lifestyle data to provide personalized sleep predictions,
    detailed explanations, and recommendations.
    """
    
    def __init__(self):
        """Initialize the SleepPredictionService"""
        pass
    
    def analyze_sleep_data(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Analyze the input data and generate a personalized sleep prediction.
        
        Args:
            data: Dictionary containing user's sleep, diet, and lifestyle data
            
        Returns:
            Dictionary with prediction results, detailed analysis, and recommendations
        """
        # Extract user information
        user_name = data.get('userName', 'there')
        age = data.get('Age', 30)
        gender = data.get('Gender', 'Unknown')
        
        # Extract sleep patterns
        sleep_duration = self._calculate_sleep_duration(data)
        awakenings = data.get('awakeningsDuringNight', 0)
        sleep_quality_rating = data.get('rateSleepQuality', 3)
        use_electronics = data.get('useElectronicDevicesBeforeBed', False)
        relaxation_level = data.get('howRelaxedBeforeSleep', 3)
        
        # Extract environmental factors
        light_intensity = data.get('lightIntensity', 50)
        temperature = data.get('temperature', 22)
        sound_exposure = data.get('soundExposure', 'Moderate (30-60 dB)')
        
        # Extract physical activity and health metrics
        physical_activity = data.get('Physical Activity Level', 30)
        heart_rate = data.get('Heart Rate', 70)
        daily_steps = data.get('Daily Steps', 5000)
        stress_level = data.get('Stress Level', 5)
        
        # Calculate prediction score (0-10 scale)
        prediction_score = self._calculate_prediction_score(data)
        normalized_score = round(prediction_score / 10, 2)
        
        # Calculate sleep disorder probability
        sleep_disorder_probability = self._calculate_sleep_disorder_probability(data)
        
        # Generate prediction summary
        prediction_summary = self._generate_prediction_summary(prediction_score)
        
        # Generate detailed analysis
        detailed_analysis = self._generate_detailed_analysis(data)
        
        # Generate sleep interruption predictions
        interruption_count, interruption_windows = self._predict_sleep_interruptions(data, sleep_disorder_probability)
        
        # Generate recommendations
        recommendations = self._generate_recommendations(data, user_name)
        
        # Prepare response - format to match the Flutter app's expected structure
        response = {
            "prediction": prediction_summary,
            "detailedAnalysis": detailed_analysis,
            "sleepDisorderProbability": round(sleep_disorder_probability, 2),
            "recommendations": recommendations,
            "predictionScore": round(prediction_score, 1),
            "normalizedScore": normalized_score,
            "predictedInterruptionCount": interruption_count,
            "predictedInterruptionWindows": interruption_windows
        }
        
        return response
    
    def _calculate_sleep_duration(self, data: Dict[str, Any]) -> float:
        """Calculate sleep duration from input data"""
        # If sleep duration is directly provided
        if 'Sleep Duration' in data:
            return data['Sleep Duration']
        
        # Calculate from bedtime and wake-up times
        try:
            # For weekday
            weekday_bedtime_hour = data.get('weekdayBedtimeHour', 23)
            weekday_bedtime_minute = data.get('weekdayBedtimeMinute', 0)
            weekday_wakeup_hour = data.get('weekdayWakeUpHour', 7)
            weekday_wakeup_minute = data.get('weekdayWakeUpMinute', 0)
            
            bedtime = datetime.datetime.combine(
                datetime.date.today(),
                datetime.time(hour=weekday_bedtime_hour, minute=weekday_bedtime_minute)
            )
            
            wakeup = datetime.datetime.combine(
                datetime.date.today() + datetime.timedelta(days=1) 
                if weekday_bedtime_hour > weekday_wakeup_hour 
                else datetime.date.today(),
                datetime.time(hour=weekday_wakeup_hour, minute=weekday_wakeup_minute)
            )
            
            sleep_duration = (wakeup - bedtime).total_seconds() / 3600
            return round(sleep_duration, 1)
        except Exception:
            # Default to 7 hours if calculation fails
            return 7.0
    
    def _calculate_prediction_score(self, data: Dict[str, Any]) -> float:
        """Calculate sleep quality prediction score (0-10 scale)"""
        base_score = 7.0  # Start with a neutral score
        adjustments = 0.0
        
        # Sleep duration impact (optimal is 7-9 hours)
        sleep_duration = self._calculate_sleep_duration(data)
        if sleep_duration < 6:
            adjustments -= 1.5
        elif sleep_duration < 7:
            adjustments -= 0.5
        elif sleep_duration > 9:
            adjustments -= 0.3
        else:
            adjustments += 0.5  # Optimal range
        
        # Sleep quality self-rating impact
        sleep_quality = data.get('rateSleepQuality', 3)
        adjustments += (sleep_quality - 3) * 0.5  # Scale from -1.5 to +1.5
        
        # Awakenings impact
        awakenings = data.get('awakeningsDuringNight', 0)
        if awakenings > 0:
            adjustments -= min(2.0, awakenings * 0.5)  # Up to -2.0 for many awakenings
        
        # Electronic device usage impact
        if data.get('useElectronicDevicesBeforeBed', False):
            adjustments -= 0.7
        
        # Relaxation level impact
        relaxation = data.get('howRelaxedBeforeSleep', 3)
        adjustments += (relaxation - 3) * 0.3  # Scale from -0.9 to +0.9
        
        # Environmental factors impact
        # Temperature (optimal is 16-20°C)
        temp = data.get('temperature', 22)
        if temp < 16 or temp > 24:
            adjustments -= 0.5
        
        # Sound exposure
        sound = data.get('soundExposure', '').lower()
        if 'loud' in sound:
            adjustments -= 0.8
        elif 'moderate' in sound:
            adjustments -= 0.3
        
        # Light intensity (lower is better for sleep)
        light = data.get('lightIntensity', 50)
        if light > 30:
            adjustments -= min(1.0, (light - 30) / 100)
        
        # Physical activity impact
        activity = data.get('Physical Activity Level', 30)
        if activity < 30:
            adjustments -= 0.5
        elif activity > 30 and activity <= 60:
            adjustments += 0.5
        
        # Stress level impact
        stress = data.get('Stress Level', 5)
        adjustments -= (stress / 10) * 1.5  # Scale from 0 to -1.5
        
        # Dietary factors impact
        # Late dinner impact
        dinner_hour = data.get('dinnerTimeHour', 19)
        if dinner_hour >= 21:
            adjustments -= 0.7
        
        # Final score calculation with bounds
        final_score = base_score + adjustments
        return max(0, min(10, final_score))
    
    def _calculate_sleep_disorder_probability(self, data: Dict[str, Any]) -> float:
        """Calculate the probability of sleep disorder based on input data"""
        # Base probability
        base_probability = 0.2
        
        # Factors that increase probability
        risk_factors = 0.0
        
        # Sleep duration outside optimal range
        sleep_duration = self._calculate_sleep_duration(data)
        if sleep_duration < 6 or sleep_duration > 9:
            risk_factors += 0.1
        
        # Multiple awakenings
        awakenings = data.get('awakeningsDuringNight', 0)
        if awakenings > 1:
            risk_factors += 0.1 * awakenings
        
        # Poor self-rated sleep quality
        sleep_quality = data.get('rateSleepQuality', 3)
        if sleep_quality < 3:
            risk_factors += 0.1 * (3 - sleep_quality)
        
        # Electronic device usage
        if data.get('useElectronicDevicesBeforeBed', False):
            risk_factors += 0.05
        
        # Low relaxation level
        relaxation = data.get('howRelaxedBeforeSleep', 3)
        if relaxation < 3:
            risk_factors += 0.05 * (3 - relaxation)
        
        # Environmental factors
        # Temperature outside optimal range
        temp = data.get('temperature', 22)
        if temp < 16 or temp > 24:
            risk_factors += 0.05
        
        # High noise levels
        sound = data.get('soundExposure', '').lower()
        if 'loud' in sound:
            risk_factors += 0.1
        
        # High light intensity
        light = data.get('lightIntensity', 50)
        if light > 30:
            risk_factors += 0.05
        
        # High stress level
        stress = data.get('Stress Level', 5)
        if stress > 7:
            risk_factors += 0.1
        
        # Age factor (risk increases with age)
        age = data.get('Age', 30)
        if age > 50:
            risk_factors += 0.05 * ((age - 50) / 10)
        
        # Final probability calculation with bounds
        final_probability = base_probability + risk_factors
        return max(0, min(1, final_probability))
    
    def _generate_prediction_summary(self, score: float) -> str:
        """Generate a prediction summary with emoji based on score"""
        if score >= 8:
            return "😊 Excellent! Your sleep quality is great!"
        elif score >= 6:
            return "🙂 Good! Your sleep quality is decent but can be improved."
        else:
            return "😴 Your sleep quality needs attention. Let's work on it!"
    
    def _generate_detailed_analysis(self, data: Dict[str, Any]) -> str:
        """Generate detailed analysis of sleep factors"""
        analysis_parts = []
        
        # Sleep duration analysis
        sleep_duration = self._calculate_sleep_duration(data)
        if sleep_duration < 7:
            analysis_parts.append(f"You're averaging only {sleep_duration} hours of sleep (slightly below the recommended 7-9 hours)")
        else:
            analysis_parts.append(f"Your sleep duration of {sleep_duration} hours is within the healthy range")
        
        # Sleep quality factors
        awakenings = data.get('awakeningsDuringNight', 0)
        if awakenings > 0:
            analysis_parts.append(f"Night awakenings ({awakenings} times) may be reducing your deep sleep quality")
            
        if data.get('useElectronicDevicesBeforeBed', False):
            analysis_parts.append("Device use before bed is likely affecting your ability to fall asleep due to blue light exposure")
            
        relaxation = data.get('howRelaxedBeforeSleep', 3)
        if relaxation < 3:
            analysis_parts.append(f"Your relaxation level before sleep is below average ({relaxation}/5), which may be affecting sleep onset")
        
        # Environmental factors
        temp = data.get('temperature', 22)
        if temp > 22:
            analysis_parts.append(f"Room temperature ({temp}\u00b0C) is slightly above the ideal range of 16-20\u00b0C for optimal sleep")
            
        sound = data.get('soundExposure', '')
        if 'moderate' in sound.lower() or 'loud' in sound.lower():
            analysis_parts.append(f"{sound} noise levels may impact your ability to rest fully")
        
        light = data.get('lightIntensity', 50)
        if light > 30:
            analysis_parts.append(f"Light intensity in your room ({light} units) may be interfering with melatonin production")
        
        # Physical factors
        activity = data.get('Physical Activity Level', 30)
        if activity < 30:
            analysis_parts.append(f"Your physical activity level ({activity} minutes) is below the recommended daily amount")
        
        stress = data.get('Stress Level', 5)
        if stress > 6:
            analysis_parts.append(f"Your stress level is relatively high ({stress}/10), which can affect sleep quality")
        
        # Dietary factors
        dinner_hour = data.get('dinnerTimeHour', 19)
        dinner_minute = data.get('dinnerTimeMinute', 0)
        if dinner_hour >= 21:
            analysis_parts.append(f"Late dinner (at {dinner_hour}:{dinner_minute:02d}) may be affecting your digestion during sleep")
        
        # Diet variety analysis
        breakfast_type = data.get('breakfastFoodType', '')
        lunch_type = data.get('lunchFoodType', '')
        dinner_type = data.get('dinnerFoodType', '')
        if breakfast_type == lunch_type == dinner_type:
            analysis_parts.append("Your diet is consistent but limited in variety, which might impact overall nutrition for sleep")
        
        # Join analysis parts
        detailed_analysis = "We've analyzed your sleep data and found several factors that may affect your rest. " + ". ".join(analysis_parts) + "."
        
        return detailed_analysis
        
    def _predict_sleep_interruptions(self, data: Dict[str, Any], disorder_probability: float) -> tuple:
        """Predict sleep interruptions based on input data and disorder probability"""
        interruption_windows = []
        
        # Only predict interruptions if probability is significant
        if disorder_probability < 0.2:
            return 0, interruption_windows
        
        # Calculate number of interruptions based on probability and other factors
        base_interruptions = int(disorder_probability * 3)  # 0-3 interruptions
        
        # Adjust based on self-reported awakenings
        reported_awakenings = data.get('awakeningsDuringNight', 0)
        if reported_awakenings > 0:
            base_interruptions = max(base_interruptions, reported_awakenings)
        
        # Limit to a reasonable number
        interruption_count = min(3, base_interruptions)
        
        # Generate interruption windows
        if interruption_count > 0:
            # Get bedtime
            bedtime_hour = data.get('weekdayBedtimeHour', 23)
            
            # Calculate typical sleep cycle (90-110 minutes)
            cycle_length = 100  # minutes
            
            for i in range(interruption_count):
                # First interruption typically occurs after 1-2 sleep cycles
                # Subsequent interruptions occur after additional cycles
                cycle_number = i + 1
                minutes_after_sleep = (cycle_number * cycle_length) + np.random.randint(-20, 20)
                
                # Calculate interruption time
                interruption_time = datetime.datetime.combine(
                    datetime.date.today(),
                    datetime.time(hour=bedtime_hour, minute=0)
                ) + datetime.timedelta(minutes=minutes_after_sleep)
                
                # If crosses to next day
                if bedtime_hour + (minutes_after_sleep // 60) >= 24:
                    interruption_time = interruption_time.replace(day=interruption_time.day + 1)
                
                # Format times
                start_hour = interruption_time.hour
                start_minute = interruption_time.minute
                
                # Duration of interruption (5-25 minutes)
                duration = np.random.randint(5, 26)
                
                # Calculate end time
                end_time = interruption_time + datetime.timedelta(minutes=duration)
                end_hour = end_time.hour
                end_minute = end_time.minute
                
                # Add to windows
                interruption_windows.append({
                    "startTime": f"{start_hour:02d}:{start_minute:02d}",
                    "endTime": f"{end_hour:02d}:{end_minute:02d}",
                    "probability": round(0.4 + (disorder_probability * 0.5), 2)
                })
        
        return interruption_count, interruption_windows
    
    def _generate_recommendations(self, data: Dict[str, Any], user_name: str) -> str:
        """Generate personalized recommendations based on input data"""
        recommendations = []
        
        # Sleep duration recommendations
        sleep_duration = self._calculate_sleep_duration(data)
        if sleep_duration < 7:
            recommendations.append(f"Sleep at least 7 hours on weekdays (currently {sleep_duration} hours).")
        
        # Electronic device usage
        if data.get('useElectronicDevicesBeforeBed', False):
            recommendations.append("Reduce device usage 1 hour before bed to improve melatonin production.")
        
        # Relaxation recommendations
        relaxation = data.get('howRelaxedBeforeSleep', 3)
        if relaxation < 4:
            recommendations.append("Try relaxation techniques like deep breathing or meditation before bed.")
        
        # Environmental recommendations
        temp = data.get('temperature', 22)
        if temp < 16 or temp > 22:
            recommendations.append(f"Maintain bedroom temperature between 16-20°C (currently {temp}°C).")
        
        sound = data.get('soundExposure', '').lower()
        if 'moderate' in sound or 'loud' in sound:
            recommendations.append("Create a quieter sleeping environment or use white noise to mask disruptive sounds.")
        
        light = data.get('lightIntensity', 50)
        if light > 30:
            recommendations.append("Reduce light exposure in your bedroom with blackout curtains or an eye mask.")
        
        # Physical activity recommendations
        activity = data.get('Physical Activity Level', 30)
        if activity < 30:
            recommendations.append("Increase daily physical activity to at least 30 minutes.")
        
        # Stress management
        stress = data.get('Stress Level', 5)
        if stress > 6:
            recommendations.append("Practice stress management techniques like mindfulness or journaling.")
        
        # Dietary recommendations
        dinner_hour = data.get('dinnerTimeHour', 19)
        if dinner_hour >= 21:
            recommendations.append("Have dinner at least 2-3 hours before bedtime to improve digestion.")
        
        # Diet variety
        breakfast_type = data.get('breakfastFoodType', '')
        lunch_type = data.get('lunchFoodType', '')
        dinner_type = data.get('dinnerFoodType', '')
        if breakfast_type == lunch_type == dinner_type:
            recommendations.append("Add more variety to your meals for better nutritional balance.")
        
        # Format recommendations
        if recommendations:
            message = f"Dear {user_name}, you can follow these recommendations for better sleep experience! "
            message += " ".join(recommendations)
            message += " Small adjustments can greatly improve your sleep quality!"
            return message
        
        return f"Dear {user_name}, your sleep habits are already quite good! Maintain your current routine for continued quality rest."
