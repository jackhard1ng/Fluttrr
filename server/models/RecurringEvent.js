const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');

// ---------------------------------------------------------------------------
// Sub-schemas
// ---------------------------------------------------------------------------

// Flutter RecurrenceRuleModel.fromJson reads (snake_case):
//   frequency, interval, days_of_week, day_of_month,
//   start_date, end_date, max_occurrences, exceptions
const recurrenceRuleSchema = new mongoose.Schema(
  {
    frequency: {
      type: String,
      enum: ['once', 'daily', 'weekly', 'biweekly', 'monthly', 'yearly', 'custom'],
      default: 'weekly',
    },
    interval: { type: Number, default: 1, min: 1 },
    daysOfWeek: {
      type: [String],
      default: [],
      validate: {
        validator: function (arr) {
          var valid = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
          return arr.every(function (d) { return valid.includes(d); });
        },
        message: 'Invalid day of week',
      },
    },
    dayOfMonth: { type: Number, default: null, min: 1, max: 31 },
    startDate: { type: Date, default: null },
    endDate: { type: Date, default: null },
    maxOccurrences: { type: Number, default: null, min: 1 },
    exceptions: { type: [Date], default: [] },
  },
  { _id: false }
);

// Flutter RecurringEventInstance.fromJson reads (snake_case):
//   instance_id, series_id, event_id, date, start_time, end_time,
//   is_cancelled, is_modified, cancellation_reason, attendee_count,
//   remaining_slots, user_joined
const instanceSchema = new mongoose.Schema(
  {
    instanceId: { type: String, default: uuidv4 },
    eventId: { type: Number, default: null },
    date: { type: Date, required: true },
    startTime: { type: String, default: null },
    endTime: { type: String, default: null },
    isCancelled: { type: Boolean, default: false },
    isModified: { type: Boolean, default: false },
    cancellationReason: { type: String, default: null },
    attendeeCount: { type: Number, default: 0, min: 0 },
    remainingSlots: { type: Number, default: null },
  },
  { _id: false }
);

// ---------------------------------------------------------------------------
// RecurringEvent schema
// ---------------------------------------------------------------------------
// Flutter RecurringEventModel.fromJson reads (snake_case):
//   series_id, template_event_id, name, description, location, latitude, longitude,
//   start_time, end_time, duration_minutes, max_attendees, event_type, images,
//   creator_id, creator_name, recurrence_rule, is_active, created_at, upcoming_instances

const recurringEventSchema = new mongoose.Schema({
  seriesId: { type: String, default: uuidv4, unique: true, index: true },
  templateEventId: { type: Number, default: null },
  name: {
    type: String,
    required: [true, 'Event name is required'],
    trim: true,
    maxlength: 200,
  },
  description: { type: String, default: null, maxlength: 5000 },
  location: { type: String, default: null },
  latitude: { type: Number, default: null },
  longitude: { type: Number, default: null },
  startTime: { type: String, default: null },
  endTime: { type: String, default: null },
  durationMinutes: { type: Number, default: null, min: 0 },
  maxAttendees: { type: Number, default: null, min: 1 },
  eventType: { type: String, default: 'general' },
  images: { type: [String], default: [] },
  creatorId: { type: Number, required: true, index: true },
  creatorName: { type: String, default: null },
  recurrenceRule: { type: recurrenceRuleSchema, default: () => ({}) },
  isActive: { type: Boolean, default: true },
  createdAt: { type: Date, default: Date.now },
  instances: { type: [instanceSchema], default: [] },
});

// ---------------------------------------------------------------------------
// Indexes
// ---------------------------------------------------------------------------
recurringEventSchema.index({ creatorId: 1, isActive: 1 });
recurringEventSchema.index({ isActive: 1 });

// ---------------------------------------------------------------------------
// toJSON – convert to snake_case matching Flutter RecurringEventModel.fromJson
// ---------------------------------------------------------------------------
recurringEventSchema.set('toJSON', {
  transform: function (doc, ret) {
    var rule = ret.recurrenceRule || {};
    return {
      series_id: ret.seriesId,
      template_event_id: ret.templateEventId,
      name: ret.name,
      description: ret.description,
      location: ret.location,
      latitude: ret.latitude,
      longitude: ret.longitude,
      start_time: ret.startTime,
      end_time: ret.endTime,
      duration_minutes: ret.durationMinutes,
      max_attendees: ret.maxAttendees,
      event_type: ret.eventType,
      images: ret.images,
      creator_id: ret.creatorId,
      creator_name: ret.creatorName,
      recurrence_rule: {
        frequency: rule.frequency,
        interval: rule.interval,
        days_of_week: rule.daysOfWeek,
        day_of_month: rule.dayOfMonth,
        start_date: rule.startDate,
        end_date: rule.endDate,
        max_occurrences: rule.maxOccurrences,
        exceptions: rule.exceptions,
      },
      is_active: ret.isActive,
      created_at: ret.createdAt,
      upcoming_instances: (ret.instances || []).map(function (i) {
        return {
          instance_id: i.instanceId,
          series_id: ret.seriesId,
          event_id: i.eventId,
          date: i.date,
          start_time: i.startTime,
          end_time: i.endTime,
          is_cancelled: i.isCancelled,
          is_modified: i.isModified,
          cancellation_reason: i.cancellationReason,
          attendee_count: i.attendeeCount,
          remaining_slots: i.remainingSlots,
        };
      }),
    };
  },
});

module.exports = mongoose.model('RecurringEvent', recurringEventSchema);
