const mongoose = require('mongoose');

const badgeSchema = new mongoose.Schema({
  badgeId: { type: Number, unique: true, index: true },
  name: { type: String, required: true },
  description: String,
  iconUrl: String,
  category: {
    type: String,
    enum: ['general', 'activity', 'social', 'streak', 'milestone', 'special'],
    default: 'general',
  },
  requiredProgress: { type: Number, default: 1 },
  xpReward: { type: Number, default: 10 },
});

const userBadgeSchema = new mongoose.Schema({
  userId: { type: Number, required: true, index: true },
  badgeId: { type: Number, required: true },
  currentProgress: { type: Number, default: 0 },
  isUnlocked: { type: Boolean, default: false },
  isClaimed: { type: Boolean, default: false },
  unlockedAt: Date,
});

userBadgeSchema.index({ userId: 1, badgeId: 1 }, { unique: true });

const Badge = mongoose.model('Badge', badgeSchema);
const UserBadge = mongoose.model('UserBadge', userBadgeSchema);

module.exports = { Badge, UserBadge };
