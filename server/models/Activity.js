const mongoose = require('mongoose');
const Counter = require('./Counter');

const attendeeSchema = new mongoose.Schema(
  {
    userId: { type: Number, required: true },
    name: String,
    images: [String],
    joinedAt: { type: Date, default: Date.now },
  },
  { _id: false }
);

const activitySchema = new mongoose.Schema(
  {
    activityId: { type: Number, unique: true, index: true },
    name: { type: String, required: true, trim: true },
    description: { type: String, trim: true },
    location: { type: String, trim: true },
    latitude: Number,
    longitude: Number,
    dateTime: { type: Date, required: true },
    eventType: { type: String, default: 'general' },
    images: [String],
    totalSlots: { type: Number, default: 20 },
    remainingSlots: { type: Number, default: 20 },
    attendees: [attendeeSchema],
    savedBy: [Number],
    creatorId: { type: Number, required: true },
    creatorName: String,
    creatorImages: [String],
    status: { type: String, enum: ['active', 'cancelled', 'completed'], default: 'active' },
  },
  { timestamps: true }
);

activitySchema.pre('save', async function (next) {
  if (this.isNew) {
    this.activityId = await Counter.getNextSequence('activityId');
  }
  next();
});

// Format for API response
activitySchema.methods.toApiResponse = function (userId) {
  return {
    activityId: this.activityId,
    eventId: this.activityId,
    name: this.name,
    description: this.description,
    location: this.location,
    latitude: this.latitude,
    longitude: this.longitude,
    date_time: this.dateTime?.toISOString(),
    event_type: this.eventType,
    images: this.images,
    total_slots: this.totalSlots,
    remaining_slots: this.remainingSlots,
    attendees: this.attendees.map((a) => ({
      userId: a.userId,
      name: a.name,
      images: a.images,
    })),
    user_joined: userId ? this.attendees.some((a) => a.userId === userId) : false,
    user_saved: userId ? this.savedBy.includes(userId) : false,
    creator_id: this.creatorId,
    creator_name: this.creatorName,
    creator_images: this.creatorImages,
  };
};

// Geo index for location-based queries
activitySchema.index({ latitude: 1, longitude: 1 });
activitySchema.index({ dateTime: 1 });
activitySchema.index({ creatorId: 1 });

module.exports = mongoose.model('Activity', activitySchema);
