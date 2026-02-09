const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');

// ---------------------------------------------------------------------------
// Waitlist schema
// ---------------------------------------------------------------------------
// Flutter WaitlistEntryModel.fromJson reads (snake_case):
//   waitlist_id, event_id, user_id, user_name, user_image,
//   position, status, joined_at, offered_at, offer_expires_at,
//   responded_at, note, guests_count

const waitlistSchema = new mongoose.Schema({
  waitlistId: { type: String, default: uuidv4, unique: true, index: true },
  eventId: { type: Number, required: true, index: true },
  userId: { type: Number, required: true, index: true },
  userName: { type: String, default: null },
  userImage: { type: String, default: null },
  position: { type: Number, default: 0, min: 0 },
  status: {
    type: String,
    enum: ['waiting', 'offered', 'accepted', 'declined', 'expired', 'removed', 'cancelled'],
    default: 'waiting',
  },
  joinedAt: { type: Date, default: Date.now },
  offeredAt: { type: Date, default: null },
  offerExpiresAt: { type: Date, default: null },
  respondedAt: { type: Date, default: null },
  note: { type: String, default: null, maxlength: 500 },
  guestsCount: { type: Number, default: 0, min: 0 },
});

// ---------------------------------------------------------------------------
// Indexes
// ---------------------------------------------------------------------------
waitlistSchema.index({ eventId: 1, userId: 1 }, { unique: true });
waitlistSchema.index({ eventId: 1, status: 1, position: 1 });
waitlistSchema.index({ offerExpiresAt: 1 }, { sparse: true });

// ---------------------------------------------------------------------------
// toJSON – convert to snake_case matching Flutter WaitlistEntryModel.fromJson
// ---------------------------------------------------------------------------
waitlistSchema.set('toJSON', {
  transform: function (doc, ret) {
    return {
      waitlist_id: ret.waitlistId,
      event_id: ret.eventId,
      user_id: ret.userId,
      user_name: ret.userName,
      user_image: ret.userImage,
      position: ret.position,
      status: ret.status,
      joined_at: ret.joinedAt,
      offered_at: ret.offeredAt,
      offer_expires_at: ret.offerExpiresAt,
      responded_at: ret.respondedAt,
      note: ret.note,
      guests_count: ret.guestsCount,
    };
  },
});

module.exports = mongoose.model('Waitlist', waitlistSchema);
