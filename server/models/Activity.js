const mongoose = require('mongoose');
const Counter = require('./Counter');

// ---------------------------------------------------------------------------
// Sub-schemas
// ---------------------------------------------------------------------------

// Flutter Attendee.fromJson reads: user_id, name, images
const attendeeSchema = new mongoose.Schema(
  {
    userId: { type: Number, required: true },
    name: { type: String, default: null },
    images: { type: [String], default: [] },
    joinedAt: { type: Date, default: Date.now },
  },
  { _id: false }
);

// ---------------------------------------------------------------------------
// Activity schema
// ---------------------------------------------------------------------------
// Flutter ActivityModel.fromJson reads (snake_case):
//   activity_id, event_id, name, description, location, latitude, longitude,
//   date_time, event_type, image (array!), total_slots, remaining_slots,
//   attendees [{user_id, name, images}], user_joined, user_saved,
//   creator_id, creator_name, creator_image (array!)

const activitySchema = new mongoose.Schema(
  {
    activityId: { type: Number, unique: true, index: true },
    name: {
      type: String,
      required: [true, 'Activity name is required'],
      trim: true,
      maxlength: 100,
    },
    description: { type: String, trim: true, maxlength: 2000 },
    location: { type: String, trim: true },
    latitude: { type: Number, default: null },
    longitude: { type: Number, default: null },
    dateTime: { type: Date, required: [true, 'Date/time is required'] },
    eventType: { type: String, default: 'general' },
    images: { type: [String], default: [] },
    totalSlots: { type: Number, default: 20, min: 1 },
    remainingSlots: { type: Number, default: 20, min: 0 },
    attendees: { type: [attendeeSchema], default: [] },
    savedBy: { type: [Number], default: [] },
    creatorId: { type: Number, required: true, index: true },
    creatorName: { type: String, default: null },
    creatorImages: { type: [String], default: [] },
    status: {
      type: String,
      enum: ['active', 'cancelled', 'completed'],
      default: 'active',
    },

    // Event feedback
    feedback: { type: [mongoose.Schema.Types.Mixed], default: [] },
    attendeeRatings: { type: [mongoose.Schema.Types.Mixed], default: [] },
    thankYouMessages: { type: [mongoose.Schema.Types.Mixed], default: [] },

    // Guest invites
    guests: { type: [mongoose.Schema.Types.Mixed], default: [] },

    // Reminders
    reminders: { type: [mongoose.Schema.Types.Mixed], default: [] },

    // Waitlist
    waitlist: { type: [mongoose.Schema.Types.Mixed], default: [] },

    // Recurring events
    isRecurringSeries: { type: Boolean, default: false },
    seriesId: { type: Number, default: null },
    recurrenceRule: { type: mongoose.Schema.Types.Mixed, default: null },
    recurringInstances: { type: [mongoose.Schema.Types.Mixed], default: [] },
  },
  { timestamps: true }
);

// ---------------------------------------------------------------------------
// Indexes
// ---------------------------------------------------------------------------
activitySchema.index({ latitude: 1, longitude: 1 });
activitySchema.index({ dateTime: 1 });
activitySchema.index({ status: 1, dateTime: 1 });
activitySchema.index({ 'attendees.userId': 1 });
activitySchema.index({ 'reminders.userId': 1 });
activitySchema.index({ 'waitlist.userId': 1 });
activitySchema.index({ seriesId: 1 }, { sparse: true });

// ---------------------------------------------------------------------------
// Pre-save: auto-increment activityId
// ---------------------------------------------------------------------------
activitySchema.pre('save', async function (next) {
  try {
    if (this.isNew && !this.activityId) {
      this.activityId = await Counter.getNextSequence('activityId');
    }
    next();
  } catch (error) {
    next(error);
  }
});

// ---------------------------------------------------------------------------
// toJSON – convert to snake_case matching Flutter ActivityModel.fromJson
// ---------------------------------------------------------------------------
activitySchema.set('toJSON', {
  transform: function (doc, ret) {
    return {
      activity_id: ret.activityId,
      event_id: ret.activityId, // Flutter uses both interchangeably
      name: ret.name,
      description: ret.description,
      location: ret.location,
      latitude: ret.latitude,
      longitude: ret.longitude,
      date_time: ret.dateTime,
      event_type: ret.eventType,
      image: ret.images, // Flutter reads json['image'] as array
      total_slots: ret.totalSlots,
      remaining_slots: ret.remainingSlots,
      attendees: (ret.attendees || []).map(function (a) {
        return {
          user_id: a.userId,
          name: a.name,
          images: a.images,
          joined_at: a.joinedAt,
        };
      }),
      saved_by: ret.savedBy,
      creator_id: ret.creatorId,
      creator_name: ret.creatorName,
      creator_image: ret.creatorImages, // Flutter reads json['creator_image'] as array
      status: ret.status,
      created_at: ret.createdAt,
      updated_at: ret.updatedAt,
    };
  },
});

// ---------------------------------------------------------------------------
// Convenience: full API response with user-specific computed fields
// ---------------------------------------------------------------------------
activitySchema.methods.toApiResponse = function (requestingUserId) {
  const json = this.toJSON();
  json.user_joined = requestingUserId
    ? this.attendees.some(function (a) { return a.userId === requestingUserId; })
    : false;
  json.user_saved = requestingUserId
    ? this.savedBy.includes(requestingUserId)
    : false;
  return json;
};

module.exports = mongoose.model('Activity', activitySchema);
