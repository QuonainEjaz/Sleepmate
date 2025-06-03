import requests
import json
import time

def test_personalized_prediction_endpoint():
    """Test the personalized_prediction endpoint with sample data"""
    # Sample input data matching the format from the Flutter app's "save only" mode
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
    
    # Start the Flask server in a separate process
    print("Please make sure the Flask server is running (python app.py)")
    print("Testing in 3 seconds...")
    time.sleep(3)
    
    # Send request to the endpoint
    url = "http://localhost:5000/personalized_prediction"
    headers = {"Content-Type": "application/json"}
    
    try:
        print(f"Sending request to {url}...")
        response = requests.post(url, json=sample_data, headers=headers)
        
        # Check if request was successful
        if response.status_code == 200:
            print("\n✅ Request successful!")
            result = response.json()
            
            # Print key parts of the response
            print("\n===== RESPONSE SUMMARY =====")
            print(f"Prediction: {result.get('prediction', 'N/A')}")
            print(f"Sleep Disorder Probability: {result.get('sleepDisorderProbability', 'N/A')}")
            print(f"Prediction Score: {result.get('predictionScore', 'N/A')}/10")
            
            # Save full response to file
            with open('endpoint_response.json', 'w') as f:
                json.dump(result, f, indent=2)
            print("\nFull response saved to endpoint_response.json")
            
        else:
            print(f"❌ Request failed with status code: {response.status_code}")
            print(f"Error: {response.text}")
    
    except Exception as e:
        print(f"❌ Exception occurred: {str(e)}")

if __name__ == "__main__":
    test_personalized_prediction_endpoint()
