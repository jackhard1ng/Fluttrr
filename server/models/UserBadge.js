const mongoose = require('mongoose');

// ---------------------------------------------------------------------------
// UserBadge schema – tracks per-user badge progress
// ---------------------------------------------------------------------------
// Flutter BadgeModel.fromJson also reads user-specific fields:
//   current_progress, is_unlocked, is_claimed, unlocked_at

const userBadgeSchema = new mongoose.Schema({
  userId: { type: Number, required: true, index: true },
  badgeId: { type: Number, required: true, index: true },
  currentProgress: { type: Number, default: 0, min: 0 },
  isUnlocked: { type: Boolean, default: false },
  isClaimed: { type: Boolean, default: false },
  unlockedAt: { type: Date, default: null },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now },
});

// ---------------------------------------------------------------------------
// Indexes
// ---------------------------------------------------------------------------
userBadgeSchema.index({ userId: 1, badgeId: 1 }, { unique: true });
userBadgeSchema.index({ userId: 1, isUnlocked: 1 });

// ---------------------------------------------------------------------------
// Pre-save: update timestamps
// ---------------------------------------------------------------------------
userBadgeSchema.pre('save', function (next) {
  this.updatedAt = new Date();
  next();
});

// ---------------------------------------------------------------------------
// toJSON – convert to snake_case matching Flutter BadgeModel combined view
// ---------------------------------------------------------------------------
userBadgeSchema.set('toJSON', {
  transform: function (doc, ret) {
    return {
      user_id: ret.userId,
      badge_id: ret.badgeId,
      badgeId: ret.badgeId,
      current_progress: ret.currentProgress,
      currentProgress: ret.currentProgress,
      is_unlocked: ret.isUnlocked,
      isUnlocked: ret.isUnlocked,
      is_claimed: ret.isClaimed,
      isClaimed: ret.isClaimed,
      unlocked_at: ret.unlockedAt,
      unlockedAt: ret.unlockedAt,
      created_at: ret.createdAt,
      updated_at: ret.updatedAt,
    };
  },
});

module.exports = mongoose.model('UserBadge', userBadgeSchema);
