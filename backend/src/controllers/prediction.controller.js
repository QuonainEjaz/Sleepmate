const Prediction = require('../models/prediction.model');
const SleepData = require('../models/sleep-data.model');
const User = require('../models/user.model');
const { checkMLServiceHealth, getPrediction, mapSleepDataToMLInput } = require('../utils/ml-service');
const EnvironmentalData = require('../models/environmental-data.model');
const DietaryData = require('../models/dietary-data.model');

// New predict endpoint that accepts user data and returns a prediction
exports.predict = async (req, res) => {
  try {
    // Validate required fields
    if (!req.body) {
      return res.status(400).json({
        error: 'Missing prediction data in request body'
      });
    }

    // Extract data from request body
    const { sleepData, environmentalData, dietaryData } = req.body;
    
    // Check if ML service is available
    const isMLServiceAvailable = await checkMLServiceHealth();
    
    if (!isMLServiceAvailable) {
      return res.status(503).json({
        error: 'ML service is currently unavailable'
      });
    }
    
    // Map data to ML input format
    const mlInputData = mapSleepDataToMLInput(sleepData, environmentalData, dietaryData);
    
    // Get prediction from ML service
    const mlPrediction = await getPrediction(mlInputData);
    
    // Process interruption windows to convert string times to Date objects
    const interruptionWindows = mlPrediction.predictedInterruptionWindows.map(window => {
      const today = new Date();
      const startParts = window.startTime.split(':');
      const endParts = window.endTime.split(':');
      
      const startTime = new Date(today.getFullYear(), today.getMonth(), today.getDate(), 
                               parseInt(startParts[0]), parseInt(startParts[1]), 0, 0);
      const endTime = new Date(today.getFullYear(), today.getMonth(), today.getDate(), 
                             parseInt(endParts[0]), parseInt(endParts[1]), 0, 0);
      
      // If end time is before start time, it's the next day
      if (endTime < startTime) {
        endTime.setDate(endTime.getDate() + 1);
      }
      
      return {
        startTime,
        endTime,
        probability: window.probability
      };
    });
    
    // Create prediction object to save to database
    const predictionData = {
      userId: req.user._id,
      date: new Date(),
      predictionScore: mlPrediction.normalizedScore,
      predictedInterruptionCount: mlPrediction.predictedInterruptionCount,
      predictedInterruptionWindows: interruptionWindows,
      contributingFactors: mlPrediction.contributingFactors,
      recommendations: mlPrediction.recommendations,
      inputData: {
        ...mlInputData,
        userProvidedData: true
      }
    };

    // Save prediction to database
    const prediction = new Prediction(predictionData);
    await prediction.save();
    
    // Return prediction data to client
    res.status(201).json({
      prediction: {
        ...predictionData,
        id: prediction._id
      },
      message: 'Prediction generated successfully based on provided data'
    });
  } catch (error) {
    console.error('Error in predict endpoint:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.createPrediction = async (req, res) => {
  try {
    const prediction = new Prediction({
      ...req.body,
      userId: req.user._id
    });
    await prediction.save();
    res.status(201).json(prediction);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

exports.getPrediction = async (req, res) => {
  try {
    const prediction = await Prediction.findOne({
      _id: req.params.id,
      userId: req.user._id
    });

    if (!prediction) {
      return res.status(404).json({ error: 'Prediction not found' });
    }

    res.json(prediction);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getLatestPrediction = async (req, res) => {
  try {
    const prediction = await Prediction.findOne({
      userId: req.user._id
    }).sort({ date: -1 });

    if (!prediction) {
      return res.status(404).json({ error: 'No predictions found' });
    }

    res.json(prediction);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.generatePrediction = async (req, res) => {
  try {
    // Get historical sleep data
    const historicalData = await SleepData.find({
      userId: req.user._id
    })
    .sort({ date: -1 })
    .limit(30); // Last 30 days

    if (historicalData.length < 3) {
      return res.status(400).json({
        error: 'Insufficient historical data. Need at least 3 days of sleep data.'
      });
    }

    // Get most recent sleep data
    const latestSleepData = historicalData[0];
    
    // Get environmental and dietary data if available
    const environmentalData = await EnvironmentalData.findOne({ userId: req.user._id }).sort({ createdAt: -1 });
    const dietaryData = await DietaryData.findOne({ userId: req.user._id }).sort({ createdAt: -1 });
    
    // Check if ML service is available
    const isMLServiceAvailable = await checkMLServiceHealth();
    
    let predictionData;
    
    if (isMLServiceAvailable) {
      // Prepare data for ML service
      const mlInputData = mapSleepDataToMLInput(latestSleepData, environmentalData, dietaryData);
      
      // Get prediction from ML service
      const mlPrediction = await getPrediction(mlInputData);
      
      // Process interruption windows to convert string times to Date objects
      const interruptionWindows = mlPrediction.predictedInterruptionWindows.map(window => {
        const today = new Date();
        const startParts = window.startTime.split(':');
        const endParts = window.endTime.split(':');
        
        const startTime = new Date(today.getFullYear(), today.getMonth(), today.getDate(), 
                                   parseInt(startParts[0]), parseInt(startParts[1]), 0, 0);
        const endTime = new Date(today.getFullYear(), today.getMonth(), today.getDate(), 
                                 parseInt(endParts[0]), parseInt(endParts[1]), 0, 0);
        
        // If end time is before start time, it's the next day
        if (endTime < startTime) {
          endTime.setDate(endTime.getDate() + 1);
        }
        
        return {
          startTime,
          endTime,
          probability: window.probability
        };
      });
      
      predictionData = {
        userId: req.user._id,
        date: new Date(),
        predictionScore: mlPrediction.normalizedScore,
        predictedInterruptionCount: mlPrediction.predictedInterruptionCount,
        predictedInterruptionWindows: interruptionWindows,
        contributingFactors: mlPrediction.contributingFactors,
        recommendations: mlPrediction.recommendations,
        inputData: mlInputData
      };
    } else {
      // Fallback to simple prediction if ML service is not available
      console.log('ML service not available, using fallback prediction');
      
      predictionData = {
        userId: req.user._id,
        date: new Date(),
        predictionScore: Math.random(),
        predictedInterruptionCount: Math.floor(Math.random() * 3),
        predictedInterruptionWindows: [
          {
            startTime: new Date(new Date().setHours(2, 0, 0, 0)),
            endTime: new Date(new Date().setHours(3, 0, 0, 0)),
            probability: Math.random()
          }
        ],
        contributingFactors: {
          'caffeine_intake': 0.7,
          'exercise': 0.3,
          'screen_time': 0.5
        },
        recommendations: [
          'Reduce caffeine intake after 2 PM',
          'Maintain consistent sleep schedule',
          'Exercise earlier in the day'
        ],
        inputData: {
          recentSleepQuality: latestSleepData?.sleepQuality || 0,
          averageSleepDuration: historicalData.reduce((acc, curr) => acc + curr.sleepDuration, 0) / historicalData.length
        }
      };
    }

    const prediction = new Prediction(predictionData);
    await prediction.save();
    res.status(201).json(prediction);
  } catch (error) {
    console.error('Error generating prediction:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.getPredictionHistory = async (req, res) => {
  try {
    const match = { userId: req.user._id };
    const sort = { date: -1 };

    if (req.query.startDate && req.query.endDate) {
      match.date = {
        $gte: new Date(req.query.startDate),
        $lte: new Date(req.query.endDate)
      };
    }

    const predictions = await Prediction.find(match)
      .sort(sort)
      .limit(parseInt(req.query.limit) || 10)
      .skip(parseInt(req.query.skip) || 0);

    res.json(predictions);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getPredictionsByUserId = async (req, res) => {
  try {
    // Check if the requesting user is an admin or the same user
    const isAuthorized = req.user.isAdmin || req.user._id.toString() === req.params.userId;
    
    if (!isAuthorized) {
      return res.status(403).json({ error: 'Not authorized to access this data' });
    }

    const match = { userId: req.params.userId };
    const sort = { date: -1 };

    // Date range filter
    if (req.query.startDate && req.query.endDate) {
      match.date = {
        $gte: new Date(req.query.startDate),
        $lte: new Date(req.query.endDate)
      };
    }

    const predictions = await Prediction.find(match)
      .sort(sort)
      .limit(parseInt(req.query.limit) || 10)
      .skip(parseInt(req.query.skip) || 0);

    res.json(predictions);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.deletePrediction = async (req, res) => {
  try {
    const prediction = await Prediction.findOneAndDelete({
      _id: req.params.id,
      userId: req.user._id
    });

    if (!prediction) {
      return res.status(404).json({ error: 'Prediction not found' });
    }

    res.json({ message: 'Prediction deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getRecommendations = async (req, res) => {
  try {
    // Get the latest prediction for the user
    const latestPrediction = await Prediction.findOne({
      userId: req.user._id
    }).sort({ date: -1 });

    if (!latestPrediction) {
      return res.status(404).json({ error: 'No predictions found' });
    }

    // If there are recommendations in the prediction, return them
    if (latestPrediction.recommendations && latestPrediction.recommendations.length > 0) {
      return res.json({
        recommendations: latestPrediction.recommendations,
        contributingFactors: latestPrediction.contributingFactors || {}
      });
    }

    // If no recommendations, generate some default ones
    const defaultRecommendations = [
      'Maintain a consistent sleep schedule',
      'Avoid caffeine and alcohol before bedtime',
      'Create a relaxing bedtime routine',
      'Ensure your bedroom is dark, quiet, and cool',
      'Limit screen time before bed'
    ];

    res.json({
      recommendations: defaultRecommendations,
      contributingFactors: {}
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
