import json
from sleep_prediction_service import SleepPredictionService

def main():
    """Test the sleep prediction service with sample data"""
    # Sample input data matching the format from the requirements
    sample_data = {
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
        "useElectronicDevicesBeforeBed": True,
        "howRelaxedBeforeSleep": 2,
        "takeBreakfast": True,
        "breakfastTimeHour": 8,
        "breakfastTimeMinute": 0,
        "breakfastFoodType": "Proteins",
        "breakfastPortionSize": 300,
        "doLunch": True,
        "lunchTimeHour": 13,
        "lunchTimeMinute": 0,
        "lunchFoodType": "Carbohydrates",
        "lunchPortionSize": 500,
        "haveDinner": True,
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
    
    # Initialize the service
    prediction_service = SleepPredictionService()
    
    # Get prediction results
    results = prediction_service.analyze_sleep_data(sample_data)
    
    # Print results in a formatted way
    print("\n===== SLEEP PREDICTION RESULTS =====\n")
    print(f"Prediction: {results['prediction']}")
    
    print("\nDetailed Analysis:")
    # Format detailed analysis for better readability
    analysis = results['detailedAnalysis']
    # Split into lines of max 80 characters
    analysis_lines = []
    while len(analysis) > 80:
        split_point = analysis[:80].rfind('.')
        if split_point == -1:
            split_point = analysis[:80].rfind(' ')
        if split_point == -1:
            split_point = 80
        analysis_lines.append(analysis[:split_point+1])
        analysis = analysis[split_point+1:].lstrip()
    if analysis:
        analysis_lines.append(analysis)
    for line in analysis_lines:
        print(line)
    
    print(f"\nSleep Disorder Probability: {results['sleepDisorderProbability']}")
    
    print("\nRecommendations:")
    # Format recommendations for better readability
    recommendations = results['recommendations']
    # Split into lines of max 80 characters
    recommendation_lines = []
    while len(recommendations) > 80:
        split_point = recommendations[:80].rfind('.')
        if split_point == -1:
            split_point = recommendations[:80].rfind(' ')
        if split_point == -1:
            split_point = 80
        recommendation_lines.append(recommendations[:split_point+1])
        recommendations = recommendations[split_point+1:].lstrip()
    if recommendations:
        recommendation_lines.append(recommendations)
    for line in recommendation_lines:
        print(line)
    
    print(f"\nPrediction Score: {results['predictionScore']}/10")
    print(f"Normalized Score: {results['normalizedScore']}")
    print(f"Predicted Interruption Count: {results['predictedInterruptionCount']}")
    
    if results['predictedInterruptionWindows']:
        print("\nPredicted Interruption Windows:")
        for window in results['predictedInterruptionWindows']:
            print(f"  • {window['startTime']} - {window['endTime']} (Probability: {window['probability']})")

    
    # Save the results to a JSON file for reference
    with open('prediction_results.json', 'w') as f:
        json.dump(results, f, indent=2)
    print("\nResults saved to prediction_results.json")

if __name__ == "__main__":
    main()
