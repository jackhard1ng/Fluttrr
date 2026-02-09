const mongoose = require('mongoose');

const otpSchema = new mongoose.Schema({
  email: { type: String, required: true, lowercase: true, trim: true },
  otp: { type: String, required: true },
  type: {
    type: String,
    enum: ['registration', 'passwordReset', 'businessVerification', 'phoneVerification'],
    default: 'registration',
  },
  // Store registration data temporarily until OTP is verified
  userData: {
    userName: String,
    email: String,
    password: String,
  },
  // For password reset - store a temporary token
  resetToken: String,
  attempts: { type: Number, default: 0 },
  expiresAt: { type: Date, required: true, index: { expireAfterSeconds: 0 } },
  createdAt: { type: Date, default: Date.now },
});

// Allow multiple OTPs per email but clean up old ones
otpSchema.index({ email: 1, type: 1 });

module.exports = mongoose.model('Otp', otpSchema);
