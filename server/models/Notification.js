const mongoose = require('mongoose');
const Counter = require('./Counter');

// ---------------------------------------------------------------------------
// Notification schema
// ---------------------------------------------------------------------------
// Flutter NotificationModel.fromJson reads (snake_case with camelCase fallback):
//   notification_id (or _id), title, body (or message), type,
//   sender_id, sender_name, sender_image,
//   related_id, related_type, created_at, is_read

const notificationSchema = new mongoose.Schema({
  notificationId: { type: Number, unique: true, index: true },
  userId: { type: Number, required: true, index: true }, // recipient
  title: { type: String, default: null },
  body: { type: String, default: null },
  type: {
    type: String,
    enum: [
      'general',
      'like',
      'match',
      'message',
      'activityInvite',
      'activityUpdate',
      'activityReminder',
      'follow',
      'comment',
      'badge',
      'friendRequest',
      'eventReminder',
      'newMessage',
      'eventUpdate',
      'newAttendee',
      'update',
    ],
    default: 'general',
  },
  senderId: { type: Number, default: null },
  senderName: { type: String, default: null },
  senderImage: { type: String, default: null },
  relatedId: { type: Number, default: null },
  relatedType: { type: String, default: null },
  isRead: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now },
});

// ---------------------------------------------------------------------------
// Indexes
// ---------------------------------------------------------------------------
notificationSchema.index({ userId: 1, isRead: 1, createdAt: -1 });
notificationSchema.index({ userId: 1, type: 1 });

// ---------------------------------------------------------------------------
// Pre-save: auto-increment notificationId
// ---------------------------------------------------------------------------
notificationSchema.pre('save', async function (next) {
  try {
    if (this.isNew && !this.notificationId) {
      this.notificationId = await Counter.getNextSequence('notificationId');
    }
    next();
  } catch (error) {
    next(error);
  }
});

// ---------------------------------------------------------------------------
// toJSON – convert to snake_case matching Flutter NotificationModel.fromJson
// ---------------------------------------------------------------------------
notificationSchema.set('toJSON', {
  transform: function (doc, ret) {
    return {
      notification_id: ret.notificationId,
      user_id: ret.userId,
      title: ret.title,
      body: ret.body,
      message: ret.body, // Flutter also checks json['message']
      type: ret.type,
      sender_id: ret.senderId,
      senderId: ret.senderId,
      sender_name: ret.senderName,
      senderName: ret.senderName,
      sender_image: ret.senderImage,
      senderImage: ret.senderImage,
      related_id: ret.relatedId,
      relatedId: ret.relatedId,
      related_type: ret.relatedType,
      relatedType: ret.relatedType,
      is_read: ret.isRead,
      isRead: ret.isRead,
      created_at: ret.createdAt,
      createdAt: ret.createdAt,
    };
  },
});

module.exports = mongoose.model('Notification', notificationSchema);
