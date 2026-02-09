const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');

// ---------------------------------------------------------------------------
// EventFeedback schema
// ---------------------------------------------------------------------------
// Flutter EventFeedbackModel.fromJson reads (snake_case):
//   feedback_id, event_id, user_id, user_name, user_image,
//   rating, comment, created_at, is_host

const eventFeedbackSchema = new mongoose.Schema({
  feedbackId: { type: String, default: uuidv4, unique: true, index: true },
  eventId: { type: Number, required: true, index: true },
  userId: { type: Number, required: true, index: true },
  userName: { type: String, default: null },
  userImage: { type: String, default: null },
  rating: {
    type: Number,
    required: [true, 'Rating is required'],
    min: 1,
    max: 5,
  },
  comment: { type: String, default: null, maxlength: 2000 },
  createdAt: { type: Date, default: Date.now },
  isHost: { type: Boolean, default: false },
});

// ---------------------------------------------------------------------------
// Indexes
// ---------------------------------------------------------------------------
eventFeedbackSchema.index({ eventId: 1, userId: 1 }, { unique: true });
eventFeedbackSchema.index({ eventId: 1, createdAt: -1 });

// ---------------------------------------------------------------------------
// toJSON – convert to snake_case matching Flutter EventFeedbackModel.fromJson
// ---------------------------------------------------------------------------
eventFeedbackSchema.set('toJSON', {
  transform: function (doc, ret) {
    return {
      feedback_id: ret.feedbackId,
      event_id: ret.eventId,
      user_id: ret.userId,
      user_name: ret.userName,
      user_image: ret.userImage,
      rating: ret.rating,
      comment: ret.comment,
      created_at: ret.createdAt,
      is_host: ret.isHost,
    };
  },
});

module.exports = mongoose.model('EventFeedback', eventFeedbackSchema);
