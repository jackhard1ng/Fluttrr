const mongoose = require('mongoose');
const Counter = require('./Counter');

const businessSchema = new mongoose.Schema(
  {
    businessId: { type: Number, unique: true, index: true },
    userId: { type: Number, required: true, index: true },
    businessName: { type: String, required: true, trim: true },
    email: { type: String, lowercase: true, trim: true },
    phone: String,
    description: String,
    category: String,
    address: String,
    location: String,
    latitude: Number,
    longitude: Number,
    website: String,
    facebook: String,
    instagram: String,
    images: [String],
    profileImage: String,
    coverImage: String,
    isVerified: { type: Boolean, default: false },
    followerCount: { type: Number, default: 0 },
    eventCount: { type: Number, default: 0 },
    followers: [Number],
    subscriptionStatus: {
      planId: String,
      planName: String,
      status: String,
      startDate: Date,
      expiryDate: Date,
      isActive: { type: Boolean, default: false },
    },
    averageRating: { type: Number, default: 0 },
    reviewCount: { type: Number, default: 0 },
  },
  { timestamps: true }
);

businessSchema.pre('save', async function (next) {
  if (this.isNew) {
    this.businessId = await Counter.getNextSequence('businessId');
  }
  next();
});

module.exports = mongoose.model('Business', businessSchema);
