const mongoose = require('mongoose');
const Counter = require('./Counter');

// ---------------------------------------------------------------------------
// BusinessEvent schema
// ---------------------------------------------------------------------------
// Flutter BusinessEvent.fromJson reads (snake_case with camelCase fallback):
//   id, event_id, business_id, name, description, location, location_name,
//   latitude, longitude, start_date, end_date, event_type, privacy,
//   image, images, total_slots, max_attendees, remaining_slots,
//   price, currency, ticket_url, attendees_count, views, clicks, saves,
//   user_joined, user_saved

const businessEventSchema = new mongoose.Schema(
  {
    eventId: { type: Number, unique: true, index: true },
    businessId: { type: Number, required: true, index: true },
    name: {
      type: String,
      required: [true, 'Event name is required'],
      trim: true,
      maxlength: 200,
    },
    description: { type: String, default: null, maxlength: 5000 },
    location: { type: String, default: null },
    locationName: { type: String, default: null },
    latitude: { type: Number, default: null },
    longitude: { type: Number, default: null },
    startDate: { type: Date, required: [true, 'Start date is required'] },
    endDate: { type: Date, default: null },
    eventType: { type: String, default: 'general' },
    privacy: { type: String, default: 'public', enum: ['public', 'private', 'invite_only'] },
    image: { type: String, default: null },
    images: { type: [String], default: [] },
    totalSlots: { type: Number, default: 50, min: 1 },
    maxAttendees: { type: Number, default: 50, min: 1 },
    remainingSlots: { type: Number, default: 50, min: 0 },
    price: { type: Number, default: 0, min: 0 },
    currency: { type: String, default: 'USD' },
    ticketUrl: { type: String, default: null },
    attendees: { type: [Number], default: [] },
    joinedBy: { type: [Number], default: [] },
    savedBy: { type: [Number], default: [] },
    attendeesCount: { type: Number, default: 0, min: 0 },
    views: { type: Number, default: 0, min: 0 },
    clicks: { type: Number, default: 0, min: 0 },
    saves: { type: Number, default: 0, min: 0 },
    status: {
      type: String,
      enum: ['active', 'cancelled', 'completed', 'draft'],
      default: 'active',
    },
  },
  { timestamps: true }
);

// ---------------------------------------------------------------------------
// Indexes
// ---------------------------------------------------------------------------
businessEventSchema.index({ startDate: 1 });
businessEventSchema.index({ latitude: 1, longitude: 1 });
businessEventSchema.index({ status: 1 });
businessEventSchema.index({ eventType: 1 });

// ---------------------------------------------------------------------------
// Pre-save: auto-increment eventId
// ---------------------------------------------------------------------------
businessEventSchema.pre('save', async function (next) {
  try {
    if (this.isNew && !this.eventId) {
      this.eventId = await Counter.getNextSequence('businessEventId');
    }
    next();
  } catch (error) {
    next(error);
  }
});

// ---------------------------------------------------------------------------
// toJSON – convert to snake_case matching Flutter BusinessEvent.fromJson
// ---------------------------------------------------------------------------
businessEventSchema.set('toJSON', {
  transform: function (doc, ret) {
    return {
      id: ret.eventId,
      event_id: ret.eventId,
      eventId: ret.eventId,
      business_id: ret.businessId,
      businessId: ret.businessId,
      name: ret.name,
      description: ret.description,
      location: ret.location,
      location_name: ret.locationName,
      locationName: ret.locationName,
      latitude: ret.latitude,
      longitude: ret.longitude,
      start_date: ret.startDate,
      startDate: ret.startDate,
      end_date: ret.endDate,
      endDate: ret.endDate,
      event_type: ret.eventType,
      eventType: ret.eventType,
      privacy: ret.privacy,
      image: ret.image || (ret.images && ret.images[0]) || null,
      images: ret.images,
      total_slots: ret.totalSlots,
      totalSlots: ret.totalSlots,
      max_attendees: ret.maxAttendees,
      maxAttendees: ret.maxAttendees,
      remaining_slots: ret.remainingSlots,
      remainingSlots: ret.remainingSlots,
      price: ret.price,
      currency: ret.currency,
      ticket_url: ret.ticketUrl,
      ticketUrl: ret.ticketUrl,
      attendees: ret.attendees,
      joined_by: ret.joinedBy,
      saved_by: ret.savedBy,
      attendees_count: ret.attendeesCount,
      attendeesCount: ret.attendeesCount,
      views: ret.views,
      view_count: ret.views,
      clicks: ret.clicks,
      click_count: ret.clicks,
      saves: ret.saves,
      save_count: ret.saves,
      status: ret.status,
      created_at: ret.createdAt,
      updated_at: ret.updatedAt,
    };
  },
});

// ---------------------------------------------------------------------------
// Convenience: API response with user-specific flags
// ---------------------------------------------------------------------------
businessEventSchema.methods.toApiResponse = function (requestingUserId) {
  var json = this.toJSON();
  json.user_joined = requestingUserId
    ? this.joinedBy.includes(requestingUserId)
    : false;
  json.userJoined = json.user_joined;
  json.user_saved = requestingUserId
    ? this.savedBy.includes(requestingUserId)
    : false;
  json.userSaved = json.user_saved;
  return json;
};

module.exports = mongoose.model('BusinessEvent', businessEventSchema);
