const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const Counter = require('./Counter');

const userSchema = new mongoose.Schema(
  {
    numericId: { type: Number, unique: true, index: true },
    userName: { type: String, required: true, trim: true },
    email: { type: String, required: true, unique: true, lowercase: true, trim: true },
    password: { type: String, required: true, minlength: 6, select: false },
    accountType: { type: String, enum: ['regular', 'business'], default: 'regular' },
    role: { type: String, enum: ['user', 'admin', 'moderator'], default: 'user' },
    onlineStatus: { type: String, enum: ['online', 'offline', 'away'], default: 'offline' },
    lastSeen: { type: Date, default: Date.now },
    profile: {
      age: Number,
      gender: String,
      bio: String,
      interests: [String],
      images: [String],
      coverImages: [String],
      location: String,
      languages: [String],
      latitude: Number,
      longitude: Number,
    },
    isLowProfile: { type: Boolean, default: false },
    completionPercentage: { type: Number, default: 0 },
    fcmToken: String,
    phoneVerification: {
      phoneNumber: String,
      countryCode: String,
      status: { type: String, enum: ['unverified', 'pending', 'verified'], default: 'unverified' },
      verifiedAt: Date,
      otpAttempts: { type: Number, default: 0 },
    },
    averageRating: { type: Number, default: 0 },
    totalRatings: { type: Number, default: 0 },
    followedBusinessIds: [Number],
    status: { type: String, enum: ['active', 'suspended', 'banned', 'deleted'], default: 'active' },
    businessName: String,
    refreshToken: { type: String, select: false },
  },
  { timestamps: true }
);

// Auto-increment numericId
userSchema.pre('save', async function (next) {
  if (this.isNew) {
    this.numericId = await Counter.getNextSequence('userId');
  }
  if (this.isModified('password')) {
    this.password = await bcrypt.hash(this.password, 12);
  }
  // Calculate completion percentage
  this.completionPercentage = this.calculateCompletion();
  next();
});

userSchema.methods.comparePassword = async function (candidatePassword) {
  return bcrypt.compare(candidatePassword, this.password);
};

userSchema.methods.calculateCompletion = function () {
  let score = 0;
  const total = 10;
  if (this.userName) score++;
  if (this.email) score++;
  if (this.profile?.age) score++;
  if (this.profile?.gender) score++;
  if (this.profile?.bio) score++;
  if (this.profile?.interests?.length > 0) score++;
  if (this.profile?.images?.length > 0) score++;
  if (this.profile?.location) score++;
  if (this.profile?.languages?.length > 0) score++;
  if (this.phoneVerification?.status === 'verified') score++;
  return Math.round((score / total) * 100);
};

// Transform output
userSchema.set('toJSON', {
  transform: (doc, ret) => {
    ret.userId = ret.numericId;
    delete ret.password;
    delete ret.refreshToken;
    delete ret.__v;
    return ret;
  },
});

module.exports = mongoose.model('User', userSchema);
