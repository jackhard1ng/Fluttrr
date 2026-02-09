const mongoose = require('mongoose');

const otpSchema = new mongoose.Schema({
  email: {
    type: String,
    required: [true, 'Email is required'],
    lowercase: true,
    trim: true,
  },
  otp: {
    type: String,
    required: [true, 'OTP code is required'],
  },
  type: {
    type: String,
    enum: ['registration', 'passwordReset', 'businessVerification', 'phoneVerification'],
    required: [true, 'OTP type is required'],
    default: 'registration',
  },
  // Store full registration payload temporarily until OTP is verified
  userData: {
    type: mongoose.Schema.Types.Mixed,
    default: null,
  },
  // Optional reset token for password-reset flow
  resetToken: { type: String, default: null },
  attempts: { type: Number, default: 0, max: 5 },
  expiresAt: {
    type: Date,
    required: true,
    index: { expires: 0 }, // TTL index – MongoDB auto-deletes expired docs
  },
  createdAt: { type: Date, default: Date.now },
});

// Indexes
otpSchema.index({ email: 1, type: 1 });
otpSchema.index({ email: 1, otp: 1 });

// toJSON
otpSchema.set('toJSON', {
  transform: function (doc, ret) {
    ret.id = ret._id;
    delete ret._id;
    delete ret.__v;
    return ret;
  },
});

module.exports = mongoose.model('Otp', otpSchema);
