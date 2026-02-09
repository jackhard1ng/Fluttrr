const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');

// ---------------------------------------------------------------------------
// AttendeeRating schema
// ---------------------------------------------------------------------------
// Flutter AttendeeRatingModel.fromJson reads (snake_case):
//   rating_id, event_id, rater_id, rated_user_id,
//   rated_user_name, rated_user_image, rating, tags, comment, created_at

const attendeeRatingSchema = new mongoose.Schema({
  ratingId: { type: String, default: uuidv4, unique: true, index: true },
  eventId: { type: Number, required: true, index: true },
  raterId: { type: Number, required: true, index: true },
  ratedUserId: { type: Number, required: true, index: true },
  ratedUserName: { type: String, default: null },
  ratedUserImage: { type: String, default: null },
  rating: {
    type: Number,
    required: [true, 'Rating is required'],
    min: 1,
    max: 5,
  },
  tags: { type: [String], default: [] },
  comment: { type: String, default: null, maxlength: 1000 },
  createdAt: { type: Date, default: Date.now },
});

// ---------------------------------------------------------------------------
// Indexes
// ---------------------------------------------------------------------------
attendeeRatingSchema.index({ eventId: 1, raterId: 1, ratedUserId: 1 }, { unique: true });
attendeeRatingSchema.index({ ratedUserId: 1, createdAt: -1 });

// ---------------------------------------------------------------------------
// toJSON – convert to snake_case matching Flutter AttendeeRatingModel.fromJson
// ---------------------------------------------------------------------------
attendeeRatingSchema.set('toJSON', {
  transform: function (doc, ret) {
    return {
      rating_id: ret.ratingId,
      event_id: ret.eventId,
      rater_id: ret.raterId,
      rated_user_id: ret.ratedUserId,
      rated_user_name: ret.ratedUserName,
      rated_user_image: ret.ratedUserImage,
      rating: ret.rating,
      tags: ret.tags,
      comment: ret.comment,
      created_at: ret.createdAt,
    };
  },
});

module.exports = mongoose.model('AttendeeRating', attendeeRatingSchema);
