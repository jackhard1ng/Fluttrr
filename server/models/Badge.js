const mongoose = require('mongoose');
const Counter = require('./Counter');

// ---------------------------------------------------------------------------
// Badge schema
// ---------------------------------------------------------------------------
// Flutter BadgeModel.fromJson reads (snake_case with camelCase fallback):
//   badge_id, name, description, icon_url (or icon), category,
//   required_progress, current_progress (from UserBadge), is_unlocked,
//   is_claimed, unlocked_at, xp_reward

const badgeSchema = new mongoose.Schema({
  badgeId: { type: Number, unique: true, index: true },
  name: {
    type: String,
    required: [true, 'Badge name is required'],
    trim: true,
  },
  description: { type: String, default: null },
  iconUrl: { type: String, default: null },
  category: {
    type: String,
    enum: ['general', 'activity', 'social', 'streak', 'milestone', 'special'],
    default: 'general',
  },
  requiredProgress: { type: Number, default: 1, min: 1 },
  xpReward: { type: Number, default: 0, min: 0 },
  createdAt: { type: Date, default: Date.now },
});

// ---------------------------------------------------------------------------
// Pre-save: auto-increment badgeId
// ---------------------------------------------------------------------------
badgeSchema.pre('save', async function (next) {
  try {
    if (this.isNew && !this.badgeId) {
      this.badgeId = await Counter.getNextSequence('badgeId');
    }
    next();
  } catch (error) {
    next(error);
  }
});

// ---------------------------------------------------------------------------
// toJSON – convert to snake_case matching Flutter BadgeModel.fromJson
// ---------------------------------------------------------------------------
badgeSchema.set('toJSON', {
  transform: function (doc, ret) {
    return {
      badge_id: ret.badgeId,
      badgeId: ret.badgeId,
      name: ret.name,
      description: ret.description,
      icon_url: ret.iconUrl,
      iconUrl: ret.iconUrl,
      icon: ret.iconUrl,
      category: ret.category,
      required_progress: ret.requiredProgress,
      requiredProgress: ret.requiredProgress,
      xp_reward: ret.xpReward,
      xpReward: ret.xpReward,
      created_at: ret.createdAt,
    };
  },
});

// ---------------------------------------------------------------------------
// Static: seed default badges
// ---------------------------------------------------------------------------
badgeSchema.statics.seedDefaults = async function () {
  var Badge = this;
  var count = await Badge.countDocuments();
  if (count > 0) return;

  var defaults = [
    { name: 'First Activity', description: 'Create your first activity', category: 'activity', requiredProgress: 1, xpReward: 50 },
    { name: 'Social Butterfly', description: 'Join 5 activities', category: 'social', requiredProgress: 5, xpReward: 100 },
    { name: 'Event Host', description: 'Create 10 activities', category: 'activity', requiredProgress: 10, xpReward: 200 },
    { name: 'Consistent', description: 'Log in 7 days in a row', category: 'streak', requiredProgress: 7, xpReward: 150 },
    { name: 'Popular', description: 'Receive 50 ratings', category: 'milestone', requiredProgress: 50, xpReward: 300 },
    { name: 'Connector', description: 'Send 100 messages', category: 'social', requiredProgress: 100, xpReward: 200 },
    { name: 'Explorer', description: 'Join activities in 5 different locations', category: 'activity', requiredProgress: 5, xpReward: 150 },
    { name: 'Early Bird', description: 'Be the first to join 3 activities', category: 'special', requiredProgress: 3, xpReward: 100 },
    { name: 'Trailblazer', description: 'Create activities in 3 different categories', category: 'activity', requiredProgress: 3, xpReward: 150 },
    { name: 'Community Leader', description: 'Have 25 people attend your activities', category: 'milestone', requiredProgress: 25, xpReward: 250 },
  ];

  await Badge.insertMany(defaults);
};

module.exports = mongoose.model('Badge', badgeSchema);
