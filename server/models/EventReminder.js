const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');

// ---------------------------------------------------------------------------
// EventReminder schema
// ---------------------------------------------------------------------------
// Flutter EventReminderModel.fromJson reads (snake_case):
//   reminder_id, event_id, user_id, type, delivery_methods,
//   scheduled_for, is_sent, sent_at, is_enabled, custom_message

const eventReminderSchema = new mongoose.Schema({
  reminderId: { type: String, default: uuidv4, unique: true, index: true },
  eventId: { type: Number, required: true, index: true },
  userId: { type: Number, required: true, index: true },
  type: {
    type: String,
    enum: [
      'oneHour',
      'oneHourBefore',
      'oneDay',
      'oneDayBefore',
      'threeDays',
      'oneWeek',
      'oneWeekBefore',
      'custom',
    ],
    default: 'oneDay',
  },
  deliveryMethods: {
    type: [String],
    default: ['push', 'inApp'],
    validate: {
      validator: function (arr) {
        var valid = ['push', 'inApp', 'email', 'sms'];
        return arr.every(function (m) { return valid.includes(m); });
      },
      message: 'Invalid delivery method',
    },
  },
  scheduledFor: { type: Date, default: null },
  isSent: { type: Boolean, default: false },
  sentAt: { type: Date, default: null },
  isEnabled: { type: Boolean, default: true },
  customMessage: { type: String, default: null, maxlength: 500 },
  createdAt: { type: Date, default: Date.now },
});

// ---------------------------------------------------------------------------
// Indexes
// ---------------------------------------------------------------------------
eventReminderSchema.index({ eventId: 1, userId: 1 });
eventReminderSchema.index({ scheduledFor: 1, isSent: 1, isEnabled: 1 });

// ---------------------------------------------------------------------------
// toJSON – convert to snake_case matching Flutter EventReminderModel.fromJson
// ---------------------------------------------------------------------------
eventReminderSchema.set('toJSON', {
  transform: function (doc, ret) {
    return {
      reminder_id: ret.reminderId,
      event_id: ret.eventId,
      user_id: ret.userId,
      type: ret.type,
      delivery_methods: ret.deliveryMethods,
      scheduled_for: ret.scheduledFor,
      is_sent: ret.isSent,
      sent_at: ret.sentAt,
      is_enabled: ret.isEnabled,
      custom_message: ret.customMessage,
      created_at: ret.createdAt,
    };
  },
});

module.exports = mongoose.model('EventReminder', eventReminderSchema);
