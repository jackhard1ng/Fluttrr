const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');

// ---------------------------------------------------------------------------
// Guest schema
// ---------------------------------------------------------------------------
// Flutter GuestModel.fromJson reads (snake_case):
//   guest_id, event_id, invited_by_user_id, invited_by_user_name,
//   guest_name, guest_phone, guest_email, status, invited_at,
//   responded_at, is_app_user, app_user_id, invite_code, invite_link

const guestSchema = new mongoose.Schema({
  guestId: { type: String, default: uuidv4, unique: true, index: true },
  eventId: { type: Number, required: true, index: true },
  invitedByUserId: { type: Number, required: true, index: true },
  invitedByUserName: { type: String, default: null },
  guestName: {
    type: String,
    required: [true, 'Guest name is required'],
    trim: true,
  },
  guestPhone: { type: String, default: null },
  guestEmail: { type: String, default: null, lowercase: true, trim: true },
  status: {
    type: String,
    enum: ['invited', 'pending', 'confirmed', 'declined', 'attended', 'checkedIn', 'noShow'],
    default: 'invited',
  },
  invitedAt: { type: Date, default: Date.now },
  respondedAt: { type: Date, default: null },
  isAppUser: { type: Boolean, default: false },
  appUserId: { type: Number, default: null },
  inviteCode: {
    type: String,
    default: function () {
      return uuidv4().replace(/-/g, '').substring(0, 8).toUpperCase();
    },
    unique: true,
  },
  inviteLink: { type: String, default: null },
});

// ---------------------------------------------------------------------------
// Indexes
// ---------------------------------------------------------------------------
guestSchema.index({ eventId: 1, invitedByUserId: 1 });
guestSchema.index({ inviteCode: 1 });
guestSchema.index({ eventId: 1, status: 1 });

// ---------------------------------------------------------------------------
// toJSON – convert to snake_case matching Flutter GuestModel.fromJson
// ---------------------------------------------------------------------------
guestSchema.set('toJSON', {
  transform: function (doc, ret) {
    return {
      guest_id: ret.guestId,
      event_id: ret.eventId,
      invited_by_user_id: ret.invitedByUserId,
      invited_by_user_name: ret.invitedByUserName,
      guest_name: ret.guestName,
      guest_phone: ret.guestPhone,
      guest_email: ret.guestEmail,
      status: ret.status,
      invited_at: ret.invitedAt,
      responded_at: ret.respondedAt,
      is_app_user: ret.isAppUser,
      app_user_id: ret.appUserId,
      invite_code: ret.inviteCode,
      invite_link: ret.inviteLink,
    };
  },
});

module.exports = mongoose.model('Guest', guestSchema);
