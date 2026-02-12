const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const Counter = require('./Counter');

// ---------------------------------------------------------------------------
// Sub-schemas
// ---------------------------------------------------------------------------

// Flutter PhoneVerificationModel.fromJson reads snake_case keys:
//   phone_number, country_code, status, verified_at, otp_sent_at, otp_attempts
const phoneVerificationSchema = new mongoose.Schema(
  {
    phone_number: { type: String, default: null },
    country_code: { type: String, default: null },
    status: {
      type: String,
      enum: ['unverified', 'pending', 'verified'],
      default: 'unverified',
    },
    verified_at: { type: Date, default: null },
    otp_sent_at: { type: Date, default: null },
    otp_attempts: { type: Number, default: 0 },
    otp: { type: String, default: null },
    otp_expires_at: { type: Date, default: null },
  },
  { _id: false }
);

// Flutter Profile.fromJson reads:
//   age, status, gender, bio, interests, images, location,
//   coverImage (singular key, array value), Language (capital L, array value),
//   latitude, longitude
const profileSchema = new mongoose.Schema(
  {
    age: { type: Number, default: null },
    status: { type: String, default: null },
    gender: { type: String, default: null },
    bio: { type: String, default: null, maxlength: 500 },
    interests: { type: [String], default: [] },
    images: { type: [String], default: [] },
    location: { type: String, default: null },
    coverImage: { type: [String], default: [] }, // Flutter reads json['coverImage']
    Language: { type: [String], default: [] }, // Flutter reads json['Language']
    latitude: { type: Number, default: null },
    longitude: { type: Number, default: null },
  },
  { _id: false }
);

// ---------------------------------------------------------------------------
// Main User schema
// ---------------------------------------------------------------------------
// Flutter UserModel.fromJson reads camelCase keys:
//   userId, userName, email, onlineStatus, profile, completionPercentage,
//   accountType, businessName, isLowProfile, phoneVerification,
//   averageRating, totalRatings, followedBusinessIds

const userSchema = new mongoose.Schema(
  {
    userId: { type: Number, unique: true, index: true },
    userName: {
      type: String,
      required: [true, 'Username is required'],
      unique: true,
      trim: true,
      minlength: [2, 'Username must be at least 2 characters'],
      maxlength: [30, 'Username cannot exceed 30 characters'],
    },
    email: {
      type: String,
      required: [true, 'Email is required'],
      unique: true,
      lowercase: true,
      trim: true,
      match: [/^\S+@\S+\.\S+$/, 'Please provide a valid email address'],
    },
    password: {
      type: String,
      required: [true, 'Password is required'],
      minlength: [6, 'Password must be at least 6 characters'],
      select: false,
    },
    onlineStatus: {
      type: String,
      enum: ['online', 'offline', 'away'],
      default: 'offline',
    },
    lastSeen: { type: Date, default: Date.now },
    profile: { type: profileSchema, default: () => ({}) },
    completionPercentage: { type: Number, default: 0, min: 0, max: 100 },
    accountType: {
      type: String,
      enum: ['regular', 'business'],
      default: 'regular',
    },
    googleId: { type: String, default: null },
    businessName: { type: String, default: null },
    isLowProfile: { type: Boolean, default: false },
    fcmToken: { type: String, default: null },
    phoneVerification: { type: phoneVerificationSchema, default: () => ({}) },
    averageRating: { type: Number, default: 0, min: 0, max: 5 },
    totalRatings: { type: Number, default: 0, min: 0 },
    activities: {
      created: { type: Number, default: 0 },
      joined: { type: Number, default: 0 },
    },
    followedBusinessIds: { type: [Number], default: [] },
    status: {
      type: String,
      enum: ['active', 'suspended', 'banned', 'deleted'],
      default: 'active',
    },
    reminderPreferences: {
      activityReminders: { type: Boolean, default: true },
      messageNotifications: { type: Boolean, default: true },
      promotionalEmails: { type: Boolean, default: false },
      reminderTime: { type: Number, default: 30 },
    },
    refreshToken: { type: String, select: false },
    role: {
      type: String,
      enum: ['user', 'admin', 'moderator'],
      default: 'user',
    },
  },
  { timestamps: true }
);

// ---------------------------------------------------------------------------
// Indexes
// ---------------------------------------------------------------------------
userSchema.index({ 'profile.latitude': 1, 'profile.longitude': 1 });
userSchema.index({ status: 1, 'profile.latitude': 1, 'profile.longitude': 1 });
userSchema.index({ status: 1 });
userSchema.index({ onlineStatus: 1 });
userSchema.index({ accountType: 1 });
userSchema.index({ googleId: 1 }, { sparse: true });
userSchema.index({ accountType: 1, status: 1 });
userSchema.index({ userName: 1 });

// ---------------------------------------------------------------------------
// Pre-save: auto-increment userId, hash password, calculate completion
// ---------------------------------------------------------------------------
userSchema.pre('save', async function (next) {
  try {
    if (this.isNew && !this.userId) {
      this.userId = await Counter.getNextSequence('userId');
    }
    if (this.isModified('password') && !this.password.startsWith('$2a$') && !this.password.startsWith('$2b$')) {
      this.password = await bcrypt.hash(this.password, 12);
    }
    this.completionPercentage = this.calculateCompletion();
    next();
  } catch (error) {
    next(error);
  }
});

// ---------------------------------------------------------------------------
// Methods
// ---------------------------------------------------------------------------
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
  if (this.profile?.Language?.length > 0) score++;
  if (this.phoneVerification?.status === 'verified') score++;
  return Math.round((score / total) * 100);
};

// ---------------------------------------------------------------------------
// toJSON – strip sensitive fields, keep camelCase (Flutter expects camelCase)
// ---------------------------------------------------------------------------
userSchema.set('toJSON', {
  transform: function (doc, ret) {
    delete ret._id;
    delete ret.id;
    delete ret.__v;
    delete ret.password;
    delete ret.refreshToken;
    return ret;
  },
});

userSchema.set('toObject', {
  transform: function (doc, ret) {
    delete ret._id;
    delete ret.id;
    delete ret.__v;
    delete ret.password;
    delete ret.refreshToken;
    return ret;
  },
});

module.exports = mongoose.model('User', userSchema);
