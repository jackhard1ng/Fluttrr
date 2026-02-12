const mongoose = require('mongoose');

const privacySchema = new mongoose.Schema(
  {
    userId: { type: Number, required: true, unique: true, index: true },
    showOnlineStatus: { type: Boolean, default: true },
    showLastSeen: { type: Boolean, default: true },
    showLocation: { type: Boolean, default: true },
    showAge: { type: Boolean, default: true },
    showDistance: { type: Boolean, default: true },
    profileVisibility: { type: String, enum: ['everyone', 'matchesOnly', 'nobody'], default: 'everyone' },
    allowMessages: { type: Boolean, default: true },
    allowActivityInvites: { type: Boolean, default: true },
    showInNearby: { type: Boolean, default: true },
    showInSearch: { type: Boolean, default: true },
    // Notification preferences
    pushEnabled: { type: Boolean, default: true },
    emailEnabled: { type: Boolean, default: true },
    newMatchNotifications: { type: Boolean, default: true },
    messageNotifications: { type: Boolean, default: true },
    activityNotifications: { type: Boolean, default: true },
    activityReminderNotifications: { type: Boolean, default: true },
    likeNotifications: { type: Boolean, default: true },
    commentNotifications: { type: Boolean, default: true },
    marketingNotifications: { type: Boolean, default: false },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Privacy', privacySchema);
