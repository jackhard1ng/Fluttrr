const mongoose = require('mongoose');
const Counter = require('./Counter');

const businessEventSchema = new mongoose.Schema(
  {
    eventId: { type: Number, unique: true, index: true },
    businessId: { type: Number, required: true, index: true },
    name: { type: String, required: true, trim: true },
    description: String,
    location: String,
    locationName: String,
    latitude: Number,
    longitude: Number,
    startDate: { type: Date, required: true },
    endDate: Date,
    eventType: String,
    privacy: { type: String, default: 'public' },
    image: String,
    images: [String],
    totalSlots: { type: Number, default: 50 },
    maxAttendees: { type: Number, default: 50 },
    remainingSlots: { type: Number, default: 50 },
    price: { type: Number, default: 0 },
    currency: { type: String, default: 'USD' },
    ticketUrl: String,
    joinedBy: [Number],
    savedBy: [Number],
    attendeesCount: { type: Number, default: 0 },
    views: { type: Number, default: 0 },
    clicks: { type: Number, default: 0 },
    saves: { type: Number, default: 0 },
    status: { type: String, enum: ['active', 'cancelled', 'completed'], default: 'active' },
  },
  { timestamps: true }
);

businessEventSchema.pre('save', async function (next) {
  if (this.isNew) {
    this.eventId = await Counter.getNextSequence('businessEventId');
  }
  next();
});

businessEventSchema.methods.toApiResponse = function (userId) {
  return {
    id: this.eventId,
    eventId: this.eventId,
    businessId: this.businessId,
    name: this.name,
    description: this.description,
    location: this.location,
    locationName: this.locationName,
    latitude: this.latitude,
    longitude: this.longitude,
    startDate: this.startDate?.toISOString(),
    endDate: this.endDate?.toISOString(),
    eventType: this.eventType,
    privacy: this.privacy,
    image: this.image || (this.images?.[0] || ''),
    images: this.images,
    totalSlots: this.totalSlots,
    maxAttendees: this.maxAttendees,
    remainingSlots: this.remainingSlots,
    price: this.price,
    currency: this.currency,
    ticketUrl: this.ticketUrl,
    attendeesCount: this.attendeesCount,
    views: this.views,
    clicks: this.clicks,
    saves: this.saves,
    user_joined: userId ? this.joinedBy.includes(userId) : false,
    user_saved: userId ? this.savedBy.includes(userId) : false,
  };
};

module.exports = mongoose.model('BusinessEvent', businessEventSchema);
