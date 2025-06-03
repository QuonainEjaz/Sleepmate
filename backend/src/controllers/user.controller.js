const jwt = require('jsonwebtoken');
const User = require('../models/user.model');
const { sendPasswordResetOTP } = require('../services/email.service');
const logger = require('../utils/logger');
const path = require('path');
const { uploadProfileImage, profileImagesDir } = require('../utils/file-upload');

const formatUserResponse = (user) => {
  const userObj = user.toJSON();
  const formattedUser = {
    ...userObj,
    id: userObj._id.toString(),
    createdAt: userObj.createdAt ? userObj.createdAt.toISOString() : null,
    updatedAt: userObj.updatedAt ? userObj.updatedAt.toISOString() : null
  };
  
  // Only include dateOfBirth if it exists
  if (userObj.dateOfBirth) {
    formattedUser.dateOfBirth = userObj.dateOfBirth.toISOString();
  }
  
  return formattedUser;
};

const generateToken = (userId) => {
  return jwt.sign({ userId }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN
  });
};

exports.register = async (req, res) => {
  try {
    console.log('Registration request body:', req.body);
    
    // Validate required fields
    if (!req.body.name || !req.body.email || !req.body.password) {
      console.error('Missing required fields');
      return res.status(400).json({
        error: 'Missing required fields',
        required: ['name', 'email', 'password'],
        received: Object.keys(req.body)
      });
    }

    // Check if user already exists
    const existingUser = await User.findOne({ email: req.body.email });
    if (existingUser) {
      console.error('Email already registered:', req.body.email);
      return res.status(400).json({
        error: 'Email already registered'
      });
    }

    // Create user with only required fields
    const user = new User({
      name: req.body.name,
      email: req.body.email,
      password: req.body.password,
      // Additional fields will be null by default
    });
    
    // Log validation errors if any
    const validationError = user.validateSync();
    if (validationError) {
      console.error('Validation error:', validationError);
      return res.status(400).json({
        error: 'Validation error',
        details: Object.values(validationError.errors).map(err => ({
          field: err.path,
          message: err.message,
          value: err.value
        }))
      });
    }

    await user.save();
    console.log('User registered successfully:', { id: user._id, email: user.email });
    
    const token = generateToken(user._id);
    res.status(201).json({ 
      user: formatUserResponse(user), 
      token 
    });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(400).json({
      error: 'Registration failed',
      message: error.message,
      details: error.errors ? Object.values(error.errors).map(err => ({
        field: err.path,
        message: err.message,
        value: err.value
      })) : undefined
    });
  }
};

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email });

    if (!user || !(await user.comparePassword(password))) {
      throw new Error('Invalid login credentials');
    }

    const token = generateToken(user._id);
    res.json({ 
      user: formatUserResponse(user), 
      token 
    });
  } catch (error) {
    res.status(401).json({ error: error.message });
  }
};

exports.getProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.json(formatUserResponse(user));
  } catch (error) {
    console.error('Error getting user profile:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

exports.updateProfile = async (req, res) => {
  const updates = Object.keys(req.body);
  const allowedUpdates = ['name', 'email', 'password', 'dateOfBirth', 'gender', 
                         'weight', 'height', 'healthConditions', 'profileImageUrl'];
  
  const isValidOperation = updates.every(update => allowedUpdates.includes(update));

  if (!isValidOperation) {
    return res.status(400).json({ error: 'Invalid updates' });
  }

  try {
    updates.forEach(update => req.user[update] = req.body[update]);
    await req.user.save();
    res.json(req.user);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

exports.deleteAccount = async (req, res) => {
  try {
    await req.user.remove();
    res.json({ message: 'Account deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) {
      return res.status(400).json({ error: 'Email is required' });
    }

    logger.info(`Password reset requested for email: ${email}`);
    
    // Check if user exists
    const user = await User.findOne({ email });
    if (!user) {
      logger.warn(`Password reset attempt for non-existent email: ${email}`);
      return res.status(404).json({ 
        success: false,
        message: 'No account found with this email address.'
      });
    }

    // Generate a random 4-digit OTP
    const otp = Math.floor(1000 + Math.random() * 9000).toString();
    
    // Store OTP with expiry (15 minutes)
    user.resetPasswordOTP = otp;
    user.resetPasswordExpires = Date.now() + 15 * 60 * 1000; // 15 minutes
    
    try {
      // Save user with new OTP
      await user.save();
      
      logger.info(`Saving OTP for user ${email}: ${otp}`);
      
      // Send OTP via email
      try {
        await sendPasswordResetOTP(email, otp);
        logger.info(`Password reset OTP sent to ${email}`);
        
        // Return success response
        return res.status(200).json({ 
          success: true,
          message: 'If an account exists with this email, you will receive an OTP shortly.'
        });
        
      } catch (emailError) {
        logger.error('Failed to send password reset email:', emailError);
        return res.status(500).json({ 
          success: false,
          message: 'Failed to send password reset email. Please try again later.'
        });
      }
      
    } catch (error) {
      logger.error('Failed to process password reset:', error);
      return res.status(500).json({ 
        success: false,
        message: 'An error occurred while processing your request.'
      });
    }
  } catch (error) {
    logger.error('Unexpected error in forgotPassword:', error);
    res.status(500).json({ 
      success: false,
      error: 'An unexpected error occurred. Please try again later.'
    });
  }
};

exports.verifyOTP = async (req, res) => {
  try {
    const { email, otp } = req.body;
    
    if (!email || !otp) {
      logger.warn('Missing email or OTP in request');
      return res.status(400).json({ 
        success: false,
        error: 'Email and OTP are required' 
      });
    }

    logger.info(`Verifying OTP for email: ${email}`);
    
    // Find user by email first
    const user = await User.findOne({ email });
    
    if (!user) {
      logger.warn(`No user found with email: ${email}`);
      return res.status(200).json({ 
        success: false,
        error: 'If an account exists with this email, you will receive an OTP shortly.' 
      });
    }
    
    // Check if OTP matches and is not expired
    if (user.resetPasswordOTP !== otp || user.resetPasswordExpires < Date.now()) {
      logger.warn(`Invalid or expired OTP for email: ${email}`);
      return res.status(200).json({ 
        success: false,
        error: 'Invalid or expired OTP' 
      });
    }

    // Generate a temporary token for password reset
    const resetToken = jwt.sign(
      { 
        userId: user._id, 
        email: user.email, // Include email for additional verification
        purpose: 'reset_password' 
      },
      process.env.JWT_SECRET,
      { expiresIn: '15m' }
    );

    logger.info(`OTP verified successfully for user: ${user._id}`);
    
    res.status(200).json({ 
      success: true,
      message: 'OTP verified successfully',
      resetToken
    });
  } catch (error) {
    console.error('OTP verification error:', error);
    res.status(500).json({ error: 'Failed to verify OTP' });
  }
};

exports.resetPassword = async (req, res) => {
  try {
    const { email, resetToken, newPassword } = req.body;
    
    if (!newPassword) {
      return res.status(400).json({ 
        success: false,
        error: 'New password is required' 
      });
    }

    if (!resetToken) {
      return res.status(400).json({ 
        success: false,
        error: 'Reset token is required' 
      });
    }

    // Verify the reset token
    let decoded;
    try {
      decoded = jwt.verify(resetToken, process.env.JWT_SECRET);
      
      // Check if token was issued for password reset
      if (decoded.purpose !== 'reset_password') {
        logger.warn('Invalid token purpose for password reset');
        return res.status(400).json({ 
          success: false,
          error: 'Invalid token' 
        });
      }
    } catch (err) {
      logger.warn('Invalid or expired reset token', { error: err.message });
      return res.status(400).json({ 
        success: false,
        error: 'Invalid or expired reset token. Please request a new OTP.' 
      });
    }

    // Find user by ID from token
    const user = await User.findById(decoded.userId);
    if (!user) {
      logger.warn(`User not found for password reset: ${decoded.userId}`);
      return res.status(404).json({ 
        success: false,
        error: 'User not found' 
      });
    }

    // Optional: Verify email matches if provided
    if (email && user.email !== email) {
      logger.warn(`Email mismatch during password reset for user: ${user._id}`);
      return res.status(400).json({ 
        success: false,
        error: 'Invalid request' 
      });
    }

    try {
      // Update password and clear reset fields
      user.password = newPassword;
      user.resetPasswordOTP = undefined;
      user.resetPasswordExpires = undefined;
      await user.save();
      
      logger.info(`Password reset successful for user: ${user._id}`);
      
      res.status(200).json({ 
        success: true,
        message: 'Password reset successful' 
      });
    } catch (saveError) {
      logger.error('Error saving new password', { error: saveError.message, userId: user._id });
      throw saveError; // Will be caught by the outer catch block
    }
  } catch (error) {
    logger.error('Password reset error', { 
      error: error.message,
      stack: error.stack 
    });
    res.status(500).json({ 
      success: false,
      error: 'An error occurred while resetting your password. Please try again.' 
    });
  }
};

exports.refreshToken = async (req, res) => {
  try {
    // The auth middleware will have already verified the token and added the user to req
    const token = generateToken(req.user._id);
    const user = await User.findById(req.user._id);
    
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    res.json({ 
      user: formatUserResponse(user),
      token 
    });
  } catch (error) {
    console.error('Error refreshing token:', error);
    res.status(500).json({ error: 'Failed to refresh token' });
  }
};

exports.uploadProfileImage = (req, res) => {
  console.log('Profile image upload request received');
  uploadProfileImage(req, res, async (err) => {
    if (err) {
      console.error('Image upload error:', err.message);
      return res.status(400).json({ 
        error: 'Image upload failed', 
        message: err.message 
      });
    }
    
    if (!req.file) {
      console.error('No file uploaded');
      return res.status(400).json({ 
        error: 'Please select an image to upload' 
      });
    }
    
    try {
      console.log('File uploaded successfully:', req.file.path);
      // Create the URL for the uploaded image
      const baseUrl = `${req.protocol}://${req.get('host')}`;
      const relativePath = `/uploads/profile-images/${path.basename(req.file.path)}`;
      const imageUrl = baseUrl + relativePath;
      
      console.log('Image URL:', imageUrl);
      // Update user's profile image URL
      req.user.profileImageUrl = imageUrl;
      await req.user.save();
      
      // Return updated user
      res.json(formatUserResponse(req.user));
    } catch (error) {
      console.error('Failed to update profile image:', error);
      res.status(500).json({ 
        error: 'Failed to update profile image', 
        message: error.message 
      });
    }
  });
};

exports.getUserStats = async (req, res) => {
  try {
    const userId = req.user._id;
    
    // Import models only when needed to avoid circular dependencies
    const SleepData = require('../models/sleep-data.model');
    const Prediction = require('../models/prediction.model');
    
    // Get sleep data statistics
    const sleepDataCount = await SleepData.countDocuments({ userId });
    const sleepDataStats = await SleepData.aggregate([
      { $match: { userId: userId.toString() } },
      { $group: {
          _id: null,
          averageDuration: { $avg: '$sleepDuration' },
          averageQuality: { $avg: '$sleepQuality' },
          totalEntries: { $sum: 1 }
        }
      }
    ]);
    
    // Get prediction statistics
    const predictionCount = await Prediction.countDocuments({ userId });
    const predictionStats = await Prediction.aggregate([
      { $match: { userId: userId.toString() } },
      { $group: {
          _id: null,
          averageScore: { $avg: '$predictionScore' },
          totalEntries: { $sum: 1 }
        }
      }
    ]);
    
    // Format response
    const stats = {
      sleepData: {
        count: sleepDataCount,
        averageDuration: sleepDataStats.length > 0 ? Math.round(sleepDataStats[0].averageDuration) : 0,
        averageQuality: sleepDataStats.length > 0 ? parseFloat(sleepDataStats[0].averageQuality.toFixed(1)) : 0
      },
      predictions: {
        count: predictionCount,
        averageScore: predictionStats.length > 0 ? parseFloat(predictionStats[0].averageScore.toFixed(2)) : 0
      }
    };
    
    res.status(200).json(stats);
  } catch (error) {
    console.error('Error getting user stats:', error);
    res.status(500).json({ error: 'Failed to retrieve user statistics' });
  }
};
