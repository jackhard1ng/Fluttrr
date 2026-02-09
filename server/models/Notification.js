const mongoose = require('mongoose');
const Counter = require('./Counter');

const notificationSchema = new mongoose.Schema({
  notificationId: { type: Number, unique: true },
  userId: { type: Number, required: true, index: true },
  title: String,
  body: String,
  type: {
    type: String,
    enum: [
      'general', 'like', 'match', 'message', 'activityInvite', 'activityUpdate',
      'activityReminder', 'follow', 'comment', 'badge', 'friendRequest',
      'eventReminder', 'newMessage', 'eventUpdate', 'newAttendee', 'update',
    ],
    default: 'general',
  },
  senderId: Number,
  senderName: String,
  senderImage: String,
  relatedId: Number,
  relatedType: String,
  isRead: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now },
});

notificationSchema.pre('save', async function (next) {
  if (this.isNew) {
    this.notificationId = await Counter.getNextSequence('notificationId');
  }
  next();
});

module.exports = mongoose.model('Notification', notificationSchema);
