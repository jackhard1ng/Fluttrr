const mongoose = require('mongoose');
const Counter = require('./Counter');

// ---------------------------------------------------------------------------
// Sub-schemas
// ---------------------------------------------------------------------------

// Flutter SubscriptionStatus.fromJson reads (snake_case):
//   plan_id, plan_name, status, start_date, expiry_date, is_active
const subscriptionStatusSchema = new mongoose.Schema(
  {
    planId: { type: String, default: null },
    planName: { type: String, default: null },
    status: { type: String, default: null },
    startDate: { type: Date, default: null },
    expiryDate: { type: Date, default: null },
    isActive: { type: Boolean, default: false },
  },
  { _id: false }
);

// ---------------------------------------------------------------------------
// Business schema
// ---------------------------------------------------------------------------
// Flutter BusinessModel.fromJson reads (snake_case with camelCase fallback):
//   business_id, business_name, name, email, phone, description, category,
//   address, location, latitude, longitude, website, facebook, instagram,
//   images, profile_image, cover_image, is_verified, follower_count,
//   event_count, is_following, subscription_status, average_rating, review_count

const businessSchema = new mongoose.Schema(
  {
    businessId: { type: Number, unique: true, index: true },
    userId: { type: Number, required: true, index: true }, // owner
    businessName: {
      type: String,
      required: [true, 'Business name is required'],
      trim: true,
    },
    name: { type: String, default: null, trim: true }, // display name alias
    email: { type: String, lowercase: true, trim: true, default: null },
    phone: { type: String, default: null },
    description: { type: String, default: null, maxlength: 2000 },
    category: { type: String, default: null },
    address: { type: String, default: null },
    location: { type: String, default: null },
    latitude: { type: Number, default: null },
    longitude: { type: Number, default: null },
    website: { type: String, default: null },
    facebook: { type: String, default: null },
    instagram: { type: String, default: null },
    images: { type: [String], default: [] },
    profileImage: { type: String, default: null },
    coverImage: { type: String, default: null },
    isVerified: { type: Boolean, default: false },
    emailVerified: { type: Boolean, default: false },
    followerCount: { type: Number, default: 0, min: 0 },
    eventCount: { type: Number, default: 0, min: 0 },
    followers: { type: [Number], default: [] },
    subscriptionStatus: {
      type: subscriptionStatusSchema,
      default: () => ({}),
    },
    // Free trial: businesses get a trial period after verification.
    // During trial they can post events without payment.
    trialEndDate: { type: Date, default: null },
    // Discount: percentage off event-posting fees (0-100), set by admin.
    discountPercent: { type: Number, default: 0, min: 0, max: 100 },
    discountCode: { type: String, default: null },
    discountExpiryDate: { type: Date, default: null },
    averageRating: { type: Number, default: 0, min: 0, max: 5 },
    reviewCount: { type: Number, default: 0, min: 0 },
  },
  { timestamps: true }
);

// ---------------------------------------------------------------------------
// Indexes
// ---------------------------------------------------------------------------
businessSchema.index({ latitude: 1, longitude: 1 });
businessSchema.index({ category: 1 });
businessSchema.index({ isVerified: 1 });

// ---------------------------------------------------------------------------
// Pre-save: auto-increment businessId
// ---------------------------------------------------------------------------
businessSchema.pre('save', async function (next) {
  try {
    if (this.isNew && !this.businessId) {
      this.businessId = await Counter.getNextSequence('businessId');
    }
    next();
  } catch (error) {
    next(error);
  }
});

// ---------------------------------------------------------------------------
// toJSON – convert to snake_case matching Flutter BusinessModel.fromJson
// ---------------------------------------------------------------------------
businessSchema.set('toJSON', {
  transform: function (doc, ret) {
    var sub = ret.subscriptionStatus || {};
    return {
      business_id: ret.businessId,
      businessId: ret.businessId,
      user_id: ret.userId,
      business_name: ret.businessName,
      businessName: ret.businessName,
      name: ret.name || ret.businessName,
      email: ret.email,
      phone: ret.phone,
      description: ret.description,
      category: ret.category,
      address: ret.address,
      location: ret.location,
      latitude: ret.latitude,
      longitude: ret.longitude,
      website: ret.website,
      facebook: ret.facebook,
      instagram: ret.instagram,
      images: ret.images,
      profile_image: ret.profileImage,
      profileImage: ret.profileImage,
      cover_image: ret.coverImage,
      coverImage: ret.coverImage,
      is_verified: ret.isVerified,
      isVerified: ret.isVerified,
      follower_count: ret.followerCount,
      followerCount: ret.followerCount,
      event_count: ret.eventCount,
      eventCount: ret.eventCount,
      followers: ret.followers,
      subscription_status: {
        plan_id: sub.planId,
        planId: sub.planId,
        plan_name: sub.planName,
        planName: sub.planName,
        status: sub.status,
        start_date: sub.startDate,
        startDate: sub.startDate,
        expiry_date: sub.expiryDate,
        expiryDate: sub.expiryDate,
        is_active: sub.isActive,
        isActive: sub.isActive,
      },
      trial_end_date: ret.trialEndDate,
      trialEndDate: ret.trialEndDate,
      discount_percent: ret.discountPercent,
      discountPercent: ret.discountPercent,
      discount_code: ret.discountCode,
      discountCode: ret.discountCode,
      discount_expiry_date: ret.discountExpiryDate,
      discountExpiryDate: ret.discountExpiryDate,
      average_rating: ret.averageRating,
      averageRating: ret.averageRating,
      rating: ret.averageRating,
      review_count: ret.reviewCount,
      reviewCount: ret.reviewCount,
      created_at: ret.createdAt,
      updated_at: ret.updatedAt,
    };
  },
});

// ---------------------------------------------------------------------------
// Convenience: API response with user-specific is_following
// ---------------------------------------------------------------------------
businessSchema.methods.toApiResponse = function (requestingUserId) {
  var json = this.toJSON();
  json.is_following = requestingUserId
    ? this.followers.includes(requestingUserId)
    : false;
  json.isFollowing = json.is_following;
  return json;
};

module.exports = mongoose.model('Business', businessSchema);
