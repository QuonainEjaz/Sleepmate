const mongoose = require('mongoose');

const sleepDataSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  date: {
    type: Date,
    required: true
  },
  bedTime: {
    type: Date,
    required: true
  },
  wakeUpTime: {
    type: Date,
    required: true
  },
  sleepDuration: {
    type: Number,
    required: true,
    min: 0
  },
  timeToFallAsleep: {
    type: Number,
    required: true,
    min: 0
  },
  interruptionCount: {
    type: Number,
    required: true,
    default: 0,
    min: 0
  },
  interruptionTimes: [{
    type: Date
  }],
  sleepQuality: {
    type: Number,
    required: true,
    min: 0,
    max: 10
  },
  notes: {
    type: String,
    trim: true
  },
  environmentalData: {
    noise: {
      type: Number,
      min: 0,
      max: 100
    },
    light: {
      type: Number,
      min: 0,
      max: 100
    },
    temperature: {
      type: Number
    }
  },
  dietaryData: {
    caffeine: {
      type: Number,
      min: 0
    },
    alcohol: {
      type: Number,
      min: 0
    },
    lastMealTime: {
      type: Date
    }
  }
}, {
  timestamps: true
});

// Index for efficient querying
sleepDataSchema.index({ userId: 1, date: -1 });

module.exports = mongoose.model('SleepData', sleepDataSchema);
