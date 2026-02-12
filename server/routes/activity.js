const express = require('express');
const router = express.Router();
const crypto = require('crypto');
const { auth } = require('../middleware/auth');
const upload = require('../middleware/upload');
const Activity = require('../models/Activity');
const User = require('../models/User');

// Helper: parse and validate a numeric ID from request params
function parseNumericId(value) {
  const parsed = parseInt(value);
  return isNaN(parsed) ? null : parsed;
}

// ============================================================
// Helper: Format activity data to match Flutter's ActivityModel
// ============================================================
const formatActivity = (activity, userId) => {
  // Use toApiResponse if available (returns snake_case for Flutter)
  if (activity.toApiResponse) {
    return activity.toApiResponse(userId);
  }
  // Fallback: manual formatting (model uses camelCase internally)
  const attendees = activity.attendees || [];
  const savedBy = activity.savedBy || [];
  return {
    activity_id: activity.activityId,
    event_id: activity.activityId,
    name: activity.name,
    description: activity.description,
    location: activity.location,
    latitude: activity.latitude,
    longitude: activity.longitude,
    date_time: activity.dateTime ? new Date(activity.dateTime).toISOString() : null,
    event_type: activity.eventType,
    image: activity.images || [],
    total_slots: activity.totalSlots,
    remaining_slots: activity.remainingSlots,
    attendees: attendees.map((a) => ({
      user_id: a.userId,
      name: a.name,
      images: a.images || [],
    })),
    user_joined: userId ? attendees.some((a) => String(a.userId) === String(userId)) : false,
    user_saved: userId ? savedBy.some((id) => String(id) === String(userId)) : false,
    creator_id: activity.creatorId,
    creator_name: activity.creatorName,
    creator_image: activity.creatorImages || [],
    status: activity.status,
    created_at: activity.createdAt,
    updated_at: activity.updatedAt,
  };
};

// ============================================================
// GET /daily-activities - Returns today's activities
// ============================================================
router.get('/daily-activities', auth, async (req, res) => {
  try {
    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date();
    endOfDay.setHours(23, 59, 59, 999);

    const activities = await Activity.find({
      dateTime: { $gte: startOfDay, $lte: endOfDay },
    }).sort({ dateTime: 1 });

    const data = activities.map((a) => formatActivity(a, req.user.userId));
    res.json({ success: true, data });
  } catch (error) {
    console.error('Get daily activities error:', error);
    res.status(500).json({ success: false, message: 'Failed to get daily activities' });
  }
});

// ============================================================
// GET /list - List activities with filters
// ============================================================
router.get('/list', auth, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;
    const { eventType, latitude, longitude, radius } = req.query;

    const filter = {};
    if (eventType) {
      filter.eventType = eventType;
    }

    // Geo-based filtering if lat/lng provided
    if (latitude && longitude) {
      const lat = parseFloat(latitude);
      const lng = parseFloat(longitude);
      const rad = parseFloat(radius) || 50; // default 50km

      // Approximate degree conversion: 1 degree ~ 111km
      const latDelta = rad / 111;
      const lngDelta = rad / (111 * Math.cos((lat * Math.PI) / 180));

      filter.latitude = { $gte: lat - latDelta, $lte: lat + latDelta };
      filter.longitude = { $gte: lng - lngDelta, $lte: lng + lngDelta };
    }

    const activities = await Activity.find(filter)
      .sort({ dateTime: -1 })
      .skip(skip)
      .limit(limit);

    const data = activities.map((a) => formatActivity(a, req.user.userId));
    res.json({ success: true, data });
  } catch (error) {
    console.error('List activities error:', error);
    res.status(500).json({ success: false, message: 'Failed to list activities' });
  }
});

// ============================================================
// GET /activity-details/:activityId - Get single activity
// ============================================================
router.get('/activity-details/:activityId', auth, async (req, res) => {
  try {
    const activityId = parseNumericId(req.params.activityId);
    if (!activityId) return res.status(400).json({ success: false, message: 'Invalid activity ID' });
    const activity = await Activity.findOne({ activityId });
    if (!activity) {
      return res.status(404).json({ success: false, message: 'Activity not found' });
    }
    const data = formatActivity(activity, req.user.userId);
    res.json({ success: true, data });
  } catch (error) {
    console.error('Get activity details error:', error);
    res.status(500).json({ success: false, message: 'Failed to get activity details' });
  }
});

// ============================================================
// GET /my-activity - Get activities created by current user
// ============================================================
router.get('/my-activity', auth, async (req, res) => {
  try {
    const activities = await Activity.find({ creatorId: req.user.userId })
      .sort({ createdAt: -1 });
    const data = activities.map((a) => formatActivity(a, req.user.userId));
    res.json({ success: true, data });
  } catch (error) {
    console.error('Get my activities error:', error);
    res.status(500).json({ success: false, message: 'Failed to get your activities' });
  }
});

// ============================================================
// GET /user-activities - Get activities the user has joined
// ============================================================
router.get('/user-activities', auth, async (req, res) => {
  try {
    const activities = await Activity.find({
      'attendees.userId': req.user.userId,
    }).sort({ dateTime: -1 });
    const data = activities.map((a) => formatActivity(a, req.user.userId));
    res.json({ success: true, data });
  } catch (error) {
    console.error('Get user activities error:', error);
    res.status(500).json({ success: false, message: 'Failed to get joined activities' });
  }
});

// ============================================================
// GET /upcoming - Get upcoming activities (future date)
// ============================================================
router.get('/upcoming', auth, async (req, res) => {
  try {
    const now = new Date();
    const activities = await Activity.find({
      dateTime: { $gte: now },
    }).sort({ dateTime: 1 });
    const data = activities.map((a) => formatActivity(a, req.user.userId));
    res.json({ success: true, data });
  } catch (error) {
    console.error('Get upcoming activities error:', error);
    res.status(500).json({ success: false, message: 'Failed to get upcoming activities' });
  }
});

// ============================================================
// POST /search - Search activities
// ============================================================
router.post('/search', auth, async (req, res) => {
  try {
    const { query, eventType, startDate, endDate, latitude, longitude, radius } = req.body;
    const filter = {};

    if (query) {
      // Escape special regex chars to prevent ReDoS attacks
      const escapedQuery = String(query).replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
      filter.$or = [
        { name: { $regex: escapedQuery, $options: 'i' } },
        { description: { $regex: escapedQuery, $options: 'i' } },
        { location: { $regex: escapedQuery, $options: 'i' } },
      ];
    }

    if (eventType) {
      filter.eventType = eventType;
    }

    if (startDate || endDate) {
      filter.dateTime = {};
      if (startDate) filter.dateTime.$gte = new Date(startDate);
      if (endDate) filter.dateTime.$lte = new Date(endDate);
    }

    if (latitude && longitude) {
      const lat = parseFloat(latitude);
      const lng = parseFloat(longitude);
      const rad = parseFloat(radius) || 50;
      const latDelta = rad / 111;
      const lngDelta = rad / (111 * Math.cos((lat * Math.PI) / 180));
      filter.latitude = { $gte: lat - latDelta, $lte: lat + latDelta };
      filter.longitude = { $gte: lng - lngDelta, $lte: lng + lngDelta };
    }

    const activities = await Activity.find(filter).sort({ dateTime: -1 });
    const data = activities.map((a) => formatActivity(a, req.user.userId));
    res.json({ success: true, data });
  } catch (error) {
    console.error('Search activities error:', error);
    res.status(500).json({ success: false, message: 'Failed to search activities' });
  }
});

// ============================================================
// POST /create-activity - Create a new activity
// ============================================================
router.post('/create-activity', auth, async (req, res) => {
  try {
    const { name, description, location, latitude, longitude, date_time, event_type, total_slots } = req.body;

    const activity = new Activity({
      name,
      description,
      location,
      latitude: parseFloat(latitude) || 0,
      longitude: parseFloat(longitude) || 0,
      dateTime: new Date(date_time),
      eventType: event_type,
      images: [],
      totalSlots: parseInt(total_slots) || 20,
      remainingSlots: parseInt(total_slots) || 20,
      attendees: [],
      savedBy: [],
      creatorId: req.user.userId,
      creatorName: req.user.userName || 'Unknown',
      creatorImages: req.user.profile?.images || [],
    });

    await activity.save();

    // Update creator's activity count
    await User.findOneAndUpdate(
      { userId: req.user.userId },
      { $inc: { 'activities.created': 1 } }
    );

    const data = formatActivity(activity, req.user.userId);
    res.status(201).json({ success: true, data });
  } catch (error) {
    console.error('Create activity error:', error);
    res.status(500).json({ success: false, message: 'Failed to create activity' });
  }
});

// ============================================================
// POST /images/:activityId - Upload images to activity
// ============================================================
router.post('/images/:activityId', auth, upload.array('images', 10), async (req, res) => {
  try {
    const activity = await Activity.findOne({ activityId: parseInt(req.params.activityId) });
    if (!activity) {
      return res.status(404).json({ success: false, message: 'Activity not found' });
    }

    if (String(activity.creatorId) !== String(req.user.userId)) {
      return res.status(403).json({ success: false, message: 'Only the creator can upload images' });
    }

    const imageUrls = req.files.map((file) => `/uploads/${file.filename}`);
    activity.images = [...(activity.images || []), ...imageUrls];
    await activity.save();

    res.json({ success: true });
  } catch (error) {
    console.error('Upload activity images error:', error);
    res.status(500).json({ success: false, message: 'Failed to upload images' });
  }
});

// ============================================================
// PUT /update/:activityId - Update activity (only creator)
// ============================================================
router.put('/update/:activityId', auth, async (req, res) => {
  try {
    const activity = await Activity.findOne({ activityId: parseInt(req.params.activityId) });
    if (!activity) {
      return res.status(404).json({ success: false, message: 'Activity not found' });
    }

    if (String(activity.creatorId) !== String(req.user.userId)) {
      return res.status(403).json({ success: false, message: 'Only the creator can update this activity' });
    }

    const { name, description, location, latitude, longitude, date_time, event_type, total_slots } = req.body;

    if (name !== undefined) activity.name = name;
    if (description !== undefined) activity.description = description;
    if (location !== undefined) activity.location = location;
    if (latitude !== undefined) activity.latitude = parseFloat(latitude);
    if (longitude !== undefined) activity.longitude = parseFloat(longitude);
    if (date_time !== undefined) activity.dateTime = new Date(date_time);
    if (event_type !== undefined) activity.eventType = event_type;
    if (total_slots !== undefined) {
      const newTotal = parseInt(total_slots);
      if (isNaN(newTotal) || newTotal < 1) {
        return res.status(400).json({ success: false, message: 'total_slots must be a valid positive number' });
      }
      const currentAttendees = activity.attendees ? activity.attendees.length : 0;
      if (newTotal < currentAttendees) {
        return res.status(400).json({
          success: false,
          message: `Cannot reduce slots below current attendee count (${currentAttendees})`,
        });
      }
      activity.totalSlots = newTotal;
      activity.remainingSlots = newTotal - currentAttendees;
    }

    await activity.save();
    const data = formatActivity(activity, req.user.userId);
    res.json({ success: true, data });
  } catch (error) {
    console.error('Update activity error:', error);
    res.status(500).json({ success: false, message: 'Failed to update activity' });
  }
});

// ============================================================
// DELETE /delete/:activityId - Delete activity (only creator)
// ============================================================
router.delete('/delete/:activityId', auth, async (req, res) => {
  try {
    const activity = await Activity.findOne({ activityId: parseInt(req.params.activityId) });
    if (!activity) {
      return res.status(404).json({ success: false, message: 'Activity not found' });
    }

    if (String(activity.creatorId) !== String(req.user.userId)) {
      return res.status(403).json({ success: false, message: 'Only the creator can delete this activity' });
    }

    // Update all attendees' joined count before deleting
    const attendeeUserIds = (activity.attendees || []).map((a) => a.userId);
    if (attendeeUserIds.length > 0) {
      await User.updateMany(
        { userId: { $in: attendeeUserIds }, 'activities.joined': { $gt: 0 } },
        { $inc: { 'activities.joined': -1 } }
      );
    }

    await Activity.deleteOne({ _id: activity._id });
    res.json({ success: true });
  } catch (error) {
    console.error('Delete activity error:', error);
    res.status(500).json({ success: false, message: 'Failed to delete activity' });
  }
});

// ============================================================
// POST /join - Join an activity
// ============================================================
router.post('/join', auth, async (req, res) => {
  try {
    const { activityId } = req.body;
    if (!activityId || isNaN(parseInt(activityId))) {
      return res.status(400).json({ success: false, message: 'activityId must be a valid number' });
    }

    // Atomic update: only joins if user not already attending AND slots available
    const result = await Activity.findOneAndUpdate(
      {
        activityId: parseInt(activityId),
        remainingSlots: { $gt: 0 },
        'attendees.userId': { $ne: req.user.userId },
      },
      {
        $push: {
          attendees: {
            userId: req.user.userId,
            name: req.user.userName || 'Unknown',
            images: req.user.profile?.images || [],
          },
        },
        $inc: { remainingSlots: -1 },
      },
      { new: true }
    );

    if (!result) {
      // Determine the specific reason for failure
      const activity = await Activity.findOne({ activityId: parseInt(activityId) });
      if (!activity) {
        return res.status(404).json({ success: false, message: 'Activity not found' });
      }
      const alreadyJoined = activity.attendees.some(
        (a) => String(a.userId) === String(req.user.userId)
      );
      if (alreadyJoined) {
        return res.status(400).json({ success: false, message: 'Already joined this activity' });
      }
      return res.status(400).json({ success: false, message: 'No remaining slots' });
    }

    // Safety check: if remainingSlots went negative due to race, revert
    if (result.remainingSlots < 0) {
      await Activity.findOneAndUpdate(
        { _id: result._id },
        {
          $pull: { attendees: { userId: req.user.userId } },
          $inc: { remainingSlots: 1 },
        }
      );
      return res.status(400).json({ success: false, message: 'No remaining slots' });
    }

    // Update user's joined activity count
    await User.findOneAndUpdate(
      { userId: req.user.userId },
      { $inc: { 'activities.joined': 1 } }
    );

    res.json({ success: true });
  } catch (error) {
    console.error('Join activity error:', error);
    res.status(500).json({ success: false, message: 'Failed to join activity' });
  }
});

// ============================================================
// POST /leave - Leave an activity
// ============================================================
router.post('/leave', auth, async (req, res) => {
  try {
    const { activityId } = req.body;
    if (!activityId || isNaN(parseInt(activityId))) {
      return res.status(400).json({ success: false, message: 'activityId must be a valid number' });
    }

    // Atomic update: only leaves if user is actually attending
    const result = await Activity.findOneAndUpdate(
      {
        activityId: parseInt(activityId),
        'attendees.userId': req.user.userId,
      },
      {
        $pull: { attendees: { userId: req.user.userId } },
        $inc: { remainingSlots: 1 },
      },
      { new: true }
    );

    if (!result) {
      const activity = await Activity.findOne({ activityId: parseInt(activityId) });
      if (!activity) {
        return res.status(404).json({ success: false, message: 'Activity not found' });
      }
      return res.status(400).json({ success: false, message: 'You have not joined this activity' });
    }

    // Update user's joined activity count
    await User.findOneAndUpdate(
      { userId: req.user.userId, 'activities.joined': { $gt: 0 } },
      { $inc: { 'activities.joined': -1 } }
    );

    res.json({ success: true });
  } catch (error) {
    console.error('Leave activity error:', error);
    res.status(500).json({ success: false, message: 'Failed to leave activity' });
  }
});

// ============================================================
// POST /save - Toggle save activity
// ============================================================
router.post('/save', auth, async (req, res) => {
  try {
    const { activityId } = req.body;
    const userId = req.user.userId;
    const aid = parseInt(activityId);

    // Atomic toggle: try unsave first (user is in savedBy)
    let result = await Activity.findOneAndUpdate(
      { activityId: aid, savedBy: userId },
      { $pull: { savedBy: userId } },
      { new: true }
    );

    if (!result) {
      // Not currently saved - try to save it
      result = await Activity.findOneAndUpdate(
        { activityId: aid },
        { $addToSet: { savedBy: userId } },
        { new: true }
      );
    }

    if (!result) {
      return res.status(404).json({ success: false, message: 'Activity not found' });
    }

    res.json({ success: true });
  } catch (error) {
    console.error('Save activity error:', error);
    res.status(500).json({ success: false, message: 'Failed to toggle save activity' });
  }
});

// ============================================================
// POST /feedback - Submit event feedback
// ============================================================
router.post('/feedback', auth, async (req, res) => {
  try {
    const { event_id, rating, comment } = req.body;

    if (!event_id || isNaN(parseInt(event_id))) {
      return res.status(400).json({ success: false, message: 'event_id must be a valid number' });
    }
    if (rating === undefined || rating === null || isNaN(parseInt(rating))) {
      return res.status(400).json({ success: false, message: 'rating is required and must be a number' });
    }
    const parsedRating = parseInt(rating);
    if (parsedRating < 1 || parsedRating > 5) {
      return res.status(400).json({ success: false, message: 'rating must be between 1 and 5' });
    }
    if (comment && comment.length > 1000) {
      return res.status(400).json({ success: false, message: 'comment must not exceed 1000 characters' });
    }

    const feedbackEntry = {
      userId: req.user.userId,
      userName: req.user.userName || 'Unknown',
      rating: parsedRating,
      comment: comment || '',
      createdAt: new Date(),
    };

    // Atomic: try to update existing feedback first
    const updated = await Activity.findOneAndUpdate(
      {
        activityId: parseInt(event_id),
        'feedback.userId': req.user.userId,
      },
      {
        $set: { 'feedback.$[elem]': feedbackEntry },
      },
      {
        arrayFilters: [{ 'elem.userId': req.user.userId }],
        new: true,
      }
    );

    if (!updated) {
      // No existing feedback — atomically push new entry (only if not already present)
      const inserted = await Activity.findOneAndUpdate(
        {
          activityId: parseInt(event_id),
          'feedback.userId': { $ne: req.user.userId },
        },
        { $push: { feedback: feedbackEntry } },
        { new: true }
      );
      if (!inserted) {
        // Either activity doesn't exist, or concurrent insert happened
        const activity = await Activity.findOne({ activityId: parseInt(event_id) });
        if (!activity) {
          return res.status(404).json({ success: false, message: 'Activity not found' });
        }
        // Concurrent insert — treat as success (idempotent)
        return res.json({ success: true, data: feedbackEntry });
      }
    }

    res.json({ success: true, data: feedbackEntry });
  } catch (error) {
    console.error('Submit feedback error:', error);
    res.status(500).json({ success: false, message: 'Failed to submit feedback' });
  }
});

// ============================================================
// GET /feedback/:eventId - Get feedback for event
// ============================================================
router.get('/feedback/:eventId', auth, async (req, res) => {
  try {
    const eventId = parseNumericId(req.params.eventId);
    if (!eventId) return res.status(400).json({ success: false, message: 'Invalid event ID' });
    const page = parseInt(req.query.page) || 1;
    const limit = Math.min(parseInt(req.query.limit) || 20, 100);
    const skip = (page - 1) * limit;

    const activity = await Activity.findOne({ activityId: eventId });
    if (!activity) {
      return res.status(404).json({ success: false, message: 'Activity not found' });
    }

    const feedback = (activity.feedback || [])
      .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
      .slice(skip, skip + limit);

    res.json({ success: true, data: feedback });
  } catch (error) {
    console.error('Get feedback error:', error);
    res.status(500).json({ success: false, message: 'Failed to get feedback' });
  }
});

// ============================================================
// POST /rate-attendee - Rate an attendee
// ============================================================
router.post('/rate-attendee', auth, async (req, res) => {
  try {
    const { event_id, rated_user_id, rating, tags, comment } = req.body;

    const parsedRatedUserId = parseInt(rated_user_id);
    if (isNaN(parsedRatedUserId)) {
      return res.status(400).json({ success: false, message: 'rated_user_id must be a valid number' });
    }
    if (parsedRatedUserId === req.user.userId) {
      return res.status(400).json({ success: false, message: 'Cannot rate yourself' });
    }

    // Validate rating range
    const parsedRating = parseInt(rating);
    if (isNaN(parsedRating) || parsedRating < 1 || parsedRating > 5) {
      return res.status(400).json({ success: false, message: 'Rating must be between 1 and 5' });
    }

    // Verify both rater and rated user attended the event
    const activity = await Activity.findOne({ activityId: parseInt(event_id) });
    if (!activity) {
      return res.status(404).json({ success: false, message: 'Activity not found' });
    }
    const attendeeList = activity.attendees || [];
    const raterAttended = attendeeList.some((a) => a.userId === req.user.userId);
    if (!raterAttended && activity.creatorId !== req.user.userId) {
      return res.status(403).json({ success: false, message: 'Only event participants can rate attendees' });
    }
    const ratedUserAttended = attendeeList.some((a) => a.userId === parsedRatedUserId);
    if (!ratedUserAttended && activity.creatorId !== parsedRatedUserId) {
      return res.status(400).json({ success: false, message: 'Rated user was not at this event' });
    }

    const ratingEntry = {
      raterId: req.user.userId,
      raterName: req.user.userName || 'Unknown',
      ratedUserId: parsedRatedUserId,
      rating: parseInt(rating),
      tags: Array.isArray(tags) ? tags.slice(0, 10) : [],
      comment: comment || '',
      createdAt: new Date(),
    };

    // Atomic: try to update existing rating first
    const updated = await Activity.findOneAndUpdate(
      {
        activityId: parseInt(event_id),
        'attendeeRatings.raterId': req.user.userId,
        'attendeeRatings.ratedUserId': parsedRatedUserId,
      },
      {
        $set: {
          'attendeeRatings.$[elem]': ratingEntry,
        },
      },
      {
        arrayFilters: [
          { 'elem.raterId': req.user.userId, 'elem.ratedUserId': parsedRatedUserId },
        ],
        new: true,
      }
    );

    if (!updated) {
      // No existing rating — atomically push new entry
      const inserted = await Activity.findOneAndUpdate(
        { activityId: parseInt(event_id) },
        { $push: { attendeeRatings: ratingEntry } },
        { new: true }
      );
      if (!inserted) {
        return res.status(404).json({ success: false, message: 'Activity not found' });
      }
    }

    res.json({ success: true, data: ratingEntry });
  } catch (error) {
    console.error('Rate attendee error:', error);
    res.status(500).json({ success: false, message: 'Failed to rate attendee' });
  }
});

// ============================================================
// GET /attendee-ratings/:eventId - Get attendee ratings
// ============================================================
router.get('/attendee-ratings/:eventId', auth, async (req, res) => {
  try {
    const activity = await Activity.findOne({ activityId: parseInt(req.params.eventId) });
    if (!activity) {
      return res.status(404).json({ success: false, message: 'Activity not found' });
    }

    // Only event participants can view ratings
    const isParticipant = (activity.attendees || []).some((a) => a.userId === req.user.userId);
    if (!isParticipant && activity.creatorId !== req.user.userId) {
      return res.status(403).json({ success: false, message: 'Only event participants can view ratings' });
    }

    const data = activity.attendeeRatings || [];
    res.json({ success: true, data });
  } catch (error) {
    console.error('Get attendee ratings error:', error);
    res.status(500).json({ success: false, message: 'Failed to get attendee ratings' });
  }
});

// ============================================================
// GET /post-event-summary/pending - Get events pending feedback
// (Must be before /post-event-summary/:eventId to avoid route conflict)
// ============================================================
router.get('/post-event-summary/pending', auth, async (req, res) => {
  try {
    const now = new Date();
    // Find past events the user attended where they haven't left feedback
    const activities = await Activity.find({
      dateTime: { $lt: now },
      'attendees.userId': req.user.userId,
    }).sort({ dateTime: -1 });

    const pending = activities.filter((a) => {
      const feedback = a.feedback || [];
      return !feedback.some((f) => String(f.userId) === String(req.user.userId));
    });

    const data = pending.map((a) => formatActivity(a, req.user.userId));
    res.json({ success: true, data });
  } catch (error) {
    console.error('Get pending feedback error:', error);
    res.status(500).json({ success: false, message: 'Failed to get pending feedback events' });
  }
});

// ============================================================
// GET /post-event-summary/:eventId - Get post-event summary
// ============================================================
router.get('/post-event-summary/:eventId', auth, async (req, res) => {
  try {
    const activity = await Activity.findOne({ activityId: parseInt(req.params.eventId) });
    if (!activity) {
      return res.status(404).json({ success: false, message: 'Activity not found' });
    }

    const feedback = activity.feedback || [];
    const ratings = activity.attendeeRatings || [];
    const avgRating =
      feedback.length > 0
        ? feedback.reduce((sum, f) => sum + f.rating, 0) / feedback.length
        : 0;

    const data = {
      activity: formatActivity(activity, req.user.userId),
      totalAttendees: activity.attendees.length,
      totalFeedback: feedback.length,
      averageRating: Math.round(avgRating * 10) / 10,
      feedback,
      attendeeRatings: ratings,
    };

    res.json({ success: true, data });
  } catch (error) {
    console.error('Get post-event summary error:', error);
    res.status(500).json({ success: false, message: 'Failed to get post-event summary' });
  }
});

// ============================================================
// POST /send-thank-you - Send thank you to attendees
// ============================================================
router.post('/send-thank-you', auth, async (req, res) => {
  try {
    const { event_id, custom_message, include_rating_request } = req.body;

    const activity = await Activity.findOne({ activityId: parseInt(event_id) });
    if (!activity) {
      return res.status(404).json({ success: false, message: 'Activity not found' });
    }

    // Only the event creator can send thank you messages
    if (activity.creatorId !== req.user.userId) {
      return res.status(403).json({ success: false, message: 'Only the event creator can send thank you messages' });
    }

    // Store the thank you record on the activity
    if (!activity.thankYouMessages) activity.thankYouMessages = [];
    activity.thankYouMessages.push({
      senderId: req.user.userId,
      customMessage: custom_message || '',
      includeRatingRequest: include_rating_request || false,
      sentAt: new Date(),
    });
    await activity.save();

    // In production, this would trigger push notifications / emails to attendees
    res.json({ success: true });
  } catch (error) {
    console.error('Send thank you error:', error);
    res.status(500).json({ success: false, message: 'Failed to send thank you' });
  }
});

// ============================================================
// POST /invite-guest - Invite a guest to an event
// ============================================================
router.post('/invite-guest', auth, async (req, res) => {
  try {
    const {
      event_id,
      guest_name,
      guest_phone,
      guest_email,
      send_sms,
      send_email,
      personal_message,
    } = req.body;

    const activity = await Activity.findOne({ activityId: parseInt(event_id) });
    if (!activity) {
      return res.status(404).json({ success: false, message: 'Activity not found' });
    }

    // Only the event creator can invite guests
    if (activity.creatorId !== req.user.userId) {
      return res.status(403).json({ success: false, message: 'Only the event creator can invite guests' });
    }

    if (!activity.guests) activity.guests = [];

    // Generate a cryptographically secure invite code
    const inviteCode = crypto.randomBytes(12).toString('hex').toUpperCase();

    const guest = {
      guestId: Date.now(),
      guestName: guest_name,
      guestPhone: guest_phone || '',
      guestEmail: guest_email || '',
      inviteCode,
      status: 'pending',
      invitedBy: req.user.userId,
      personalMessage: personal_message || '',
      sendSms: send_sms || false,
      sendEmail: send_email || false,
      invitedAt: new Date(),
      respondedAt: null,
    };

    activity.guests.push(guest);
    await activity.save();

    // In production, would send SMS/email here
    res.json({ success: true, data: guest });
  } catch (error) {
    console.error('Invite guest error:', error);
    res.status(500).json({ success: false, message: 'Failed to invite guest' });
  }
});

// ============================================================
// GET /guests/:eventId - Get event guests
// ============================================================
router.get('/guests/:eventId', auth, async (req, res) => {
  try {
    const activity = await Activity.findOne({ activityId: parseInt(req.params.eventId) });
    if (!activity) {
      return res.status(404).json({ success: false, message: 'Activity not found' });
    }

    const guests = activity.guests || [];
    const guestSummary = {
      total: guests.length,
      pending: guests.filter((g) => g.status === 'pending').length,
      accepted: guests.filter((g) => g.status === 'accepted').length,
      declined: guests.filter((g) => g.status === 'declined').length,
      cancelled: guests.filter((g) => g.status === 'cancelled').length,
      guests,
    };

    res.json({ success: true, data: guestSummary });
  } catch (error) {
    console.error('Get guests error:', error);
    res.status(500).json({ success: false, message: 'Failed to get guests' });
  }
});

// ============================================================
// PUT /guest-status - Update guest status
// ============================================================
router.put('/guest-status', auth, async (req, res) => {
  try {
    const { guest_id, status } = req.body;

    if (!guest_id || !status || typeof status !== 'string') {
      return res.status(400).json({ success: false, message: 'guest_id and status are required' });
    }

    const validStatuses = ['pending', 'invited', 'accepted', 'declined', 'cancelled'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ success: false, message: `status must be one of: ${validStatuses.join(', ')}` });
    }

    // Atomic update
    const result = await Activity.findOneAndUpdate(
      { 'guests.guestId': guest_id },
      {
        $set: {
          'guests.$[elem].status': status,
          'guests.$[elem].respondedAt': new Date(),
        },
      },
      {
        arrayFilters: [{ 'elem.guestId': guest_id }],
        new: true,
      }
    );

    if (!result) {
      return res.status(404).json({ success: false, message: 'Guest not found' });
    }

    const updatedGuest = result.guests.find((g) => g.guestId === guest_id);
    res.json({ success: true, data: updatedGuest });
  } catch (error) {
    console.error('Update guest status error:', error);
    res.status(500).json({ success: false, message: 'Failed to update guest status' });
  }
});

// ============================================================
// DELETE /cancel-guest/:guestId - Cancel guest invite
// ============================================================
router.delete('/cancel-guest/:guestId', auth, async (req, res) => {
  try {
    const guestId = parseInt(req.params.guestId);
    if (isNaN(guestId)) {
      return res.status(400).json({ success: false, message: 'Invalid guest ID' });
    }

    // Verify activity exists and user is the creator
    const activity = await Activity.findOne({ 'guests.guestId': guestId });
    if (!activity) {
      return res.status(404).json({ success: false, message: 'Guest not found' });
    }

    if (String(activity.creatorId) !== String(req.user.userId)) {
      return res.status(403).json({ success: false, message: 'Only the event creator can cancel guest invites' });
    }

    // Atomic update
    const result = await Activity.findOneAndUpdate(
      { 'guests.guestId': guestId },
      { $set: { 'guests.$[elem].status': 'cancelled' } },
      { arrayFilters: [{ 'elem.guestId': guestId }], new: true }
    );

    if (!result) {
      return res.status(404).json({ success: false, message: 'Guest not found' });
    }

    res.json({ success: true });
  } catch (error) {
    console.error('Cancel guest error:', error);
    res.status(500).json({ success: false, message: 'Failed to cancel guest invite' });
  }
});

// ============================================================
// POST /guest-rsvp - Guest RSVP (NO AUTH REQUIRED)
// ============================================================
router.post('/guest-rsvp', async (req, res) => {
  try {
    const { invite_code, accept, guest_name, guest_email } = req.body;

    if (!invite_code || typeof invite_code !== 'string' || invite_code.length < 10) {
      return res.status(400).json({ success: false, message: 'Valid invite code is required' });
    }

    // Atomic: update guest status only if still pending/invited
    const updateFields = {
      'guests.$[elem].status': accept ? 'accepted' : 'declined',
      'guests.$[elem].respondedAt': new Date(),
    };
    if (guest_name && typeof guest_name === 'string') {
      updateFields['guests.$[elem].guestName'] = guest_name.slice(0, 100);
    }
    if (guest_email && typeof guest_email === 'string') {
      updateFields['guests.$[elem].guestEmail'] = guest_email.slice(0, 200);
    }

    const result = await Activity.findOneAndUpdate(
      {
        'guests.inviteCode': invite_code,
        'guests.status': { $nin: ['accepted', 'declined'] },
      },
      { $set: updateFields },
      {
        arrayFilters: [{ 'elem.inviteCode': invite_code }],
        new: true,
      }
    );

    if (!result) {
      // Check if already responded or invalid code
      const activity = await Activity.findOne({ 'guests.inviteCode': invite_code });
      if (!activity) {
        return res.status(404).json({ success: false, message: 'Invalid invite code' });
      }
      return res.status(409).json({ success: false, message: 'This invite has already been responded to' });
    }

    const updatedGuest = result.guests.find((g) => g.inviteCode === invite_code);
    res.json({ success: true, data: updatedGuest });
  } catch (error) {
    console.error('Guest RSVP error:', error);
    res.status(500).json({ success: false, message: 'Failed to process RSVP' });
  }
});

// ============================================================
// POST /invite-guest/resend - Resend guest invite
// ============================================================
router.post('/invite-guest/resend', auth, async (req, res) => {
  try {
    const { guest_id, send_sms, send_email } = req.body;

    const activity = await Activity.findOne({ 'guests.guestId': guest_id });
    if (!activity) {
      return res.status(404).json({ success: false, message: 'Guest not found' });
    }

    if (String(activity.creatorId) !== String(req.user.userId)) {
      return res.status(403).json({ success: false, message: 'Only the event creator can resend invites' });
    }

    // Atomic update of delivery preferences
    const updateFields = {};
    if (send_sms !== undefined) updateFields['guests.$[elem].sendSms'] = !!send_sms;
    if (send_email !== undefined) updateFields['guests.$[elem].sendEmail'] = !!send_email;

    if (Object.keys(updateFields).length > 0) {
      await Activity.findOneAndUpdate(
        { 'guests.guestId': guest_id },
        { $set: updateFields },
        { arrayFilters: [{ 'elem.guestId': guest_id }] }
      );
    }

    // In production, would re-send SMS/email here
    res.json({ success: true });
  } catch (error) {
    console.error('Resend invite error:', error);
    res.status(500).json({ success: false, message: 'Failed to resend invite' });
  }
});

// ============================================================
// POST /reminder - Create a reminder
// ============================================================
router.post('/reminder', auth, async (req, res) => {
  try {
    const { event_id, type, delivery_methods, custom_date_time, custom_message } = req.body;

    const activity = await Activity.findOne({ activityId: parseInt(event_id) });
    if (!activity) {
      return res.status(404).json({ success: false, message: 'Activity not found' });
    }

    if (!activity.reminders) activity.reminders = [];

    const reminder = {
      reminderId: Date.now(),
      userId: req.user.userId,
      eventId: parseInt(event_id),
      type: type || 'before_event',
      deliveryMethods: delivery_methods || ['push'],
      customDateTime: custom_date_time ? new Date(custom_date_time) : null,
      customMessage: custom_message || '',
      isEnabled: true,
      createdAt: new Date(),
    };

    activity.reminders.push(reminder);
    await activity.save();

    res.json({ success: true, data: reminder });
  } catch (error) {
    console.error('Create reminder error:', error);
    res.status(500).json({ success: false, message: 'Failed to create reminder' });
  }
});

// ============================================================
// GET /reminders/:eventId - Get event reminders
// ============================================================
router.get('/reminders/:eventId', auth, async (req, res) => {
  try {
    const activity = await Activity.findOne({ activityId: parseInt(req.params.eventId) });
    if (!activity) {
      return res.status(404).json({ success: false, message: 'Activity not found' });
    }

    const reminders = (activity.reminders || []).filter(
      (r) => String(r.userId) === String(req.user.userId)
    );

    res.json({ success: true, data: reminders });
  } catch (error) {
    console.error('Get event reminders error:', error);
    res.status(500).json({ success: false, message: 'Failed to get reminders' });
  }
});

// ============================================================
// GET /reminders - Get all user reminders
// ============================================================
router.get('/reminders', auth, async (req, res) => {
  try {
    const activities = await Activity.find({
      'reminders.userId': req.user.userId,
    });

    const data = [];
    activities.forEach((activity) => {
      const userReminders = (activity.reminders || []).filter(
        (r) => String(r.userId) === String(req.user.userId)
      );
      userReminders.forEach((r) => {
        data.push({
          ...r.toObject ? r.toObject() : r,
          activityName: activity.name,
          activityDate: activity.dateTime,
        });
      });
    });

    res.json({ success: true, data });
  } catch (error) {
    console.error('Get all reminders error:', error);
    res.status(500).json({ success: false, message: 'Failed to get reminders' });
  }
});

// ============================================================
// PUT /reminder - Update a reminder
// ============================================================
router.put('/reminder', auth, async (req, res) => {
  try {
    const { reminder_id, type, delivery_methods, is_enabled, custom_message } = req.body;

    const activity = await Activity.findOne({ 'reminders.reminderId': reminder_id });
    if (!activity) {
      return res.status(404).json({ success: false, message: 'Reminder not found' });
    }

    const reminder = activity.reminders.find((r) => r.reminderId === reminder_id);
    if (!reminder) {
      return res.status(404).json({ success: false, message: 'Reminder not found' });
    }

    if (String(reminder.userId) !== String(req.user.userId)) {
      return res.status(403).json({ success: false, message: 'Not authorized to update this reminder' });
    }

    if (type !== undefined) reminder.type = type;
    if (delivery_methods !== undefined) reminder.deliveryMethods = delivery_methods;
    if (is_enabled !== undefined) reminder.isEnabled = is_enabled;
    if (custom_message !== undefined) reminder.customMessage = custom_message;

    await activity.save();
    res.json({ success: true, data: reminder });
  } catch (error) {
    console.error('Update reminder error:', error);
    res.status(500).json({ success: false, message: 'Failed to update reminder' });
  }
});

// ============================================================
// DELETE /reminder/:reminderId - Delete a reminder
// ============================================================
router.delete('/reminder/:reminderId', auth, async (req, res) => {
  try {
    const reminderId = parseInt(req.params.reminderId);

    const activity = await Activity.findOne({ 'reminders.reminderId': reminderId });
    if (!activity) {
      return res.status(404).json({ success: false, message: 'Reminder not found' });
    }

    const reminderIndex = activity.reminders.findIndex((r) => r.reminderId === reminderId);
    if (reminderIndex === -1) {
      return res.status(404).json({ success: false, message: 'Reminder not found' });
    }

    if (String(activity.reminders[reminderIndex].userId) !== String(req.user.userId)) {
      return res.status(403).json({ success: false, message: 'Not authorized to delete this reminder' });
    }

    activity.reminders.splice(reminderIndex, 1);
    await activity.save();

    res.json({ success: true });
  } catch (error) {
    console.error('Delete reminder error:', error);
    res.status(500).json({ success: false, message: 'Failed to delete reminder' });
  }
});

// ============================================================
// GET /upcoming-reminders - Get upcoming reminders
// ============================================================
router.get('/upcoming-reminders', auth, async (req, res) => {
  try {
    const now = new Date();
    const activities = await Activity.find({
      dateTime: { $gte: now },
      'reminders.userId': req.user.userId,
    }).sort({ dateTime: 1 });

    const data = [];
    activities.forEach((activity) => {
      const userReminders = (activity.reminders || []).filter(
        (r) => String(r.userId) === String(req.user.userId) && r.isEnabled
      );
      userReminders.forEach((r) => {
        data.push({
          ...r.toObject ? r.toObject() : r,
          activityName: activity.name,
          activityDate: activity.dateTime,
        });
      });
    });

    res.json({ success: true, data });
  } catch (error) {
    console.error('Get upcoming reminders error:', error);
    res.status(500).json({ success: false, message: 'Failed to get upcoming reminders' });
  }
});

// ============================================================
// POST /waitlist/join - Join event waitlist
// ============================================================
router.post('/waitlist/join', auth, async (req, res) => {
  try {
    const { event_id, note, guests_count } = req.body;

    const activity = await Activity.findOne({ activityId: parseInt(event_id) });
    if (!activity) {
      return res.status(404).json({ success: false, message: 'Activity not found' });
    }

    if (!activity.waitlist) activity.waitlist = [];

    // Check if already on waitlist
    const existing = activity.waitlist.find(
      (w) => String(w.userId) === String(req.user.userId) && w.status !== 'cancelled'
    );
    if (existing) {
      return res.status(400).json({ success: false, message: 'Already on waitlist' });
    }

    const entry = {
      waitlistId: Date.now(),
      userId: req.user.userId,
      userName: req.user.userName || 'Unknown',
      note: note || '',
      guestsCount: parseInt(guests_count) || 0,
      status: 'waiting',
      position: activity.waitlist.filter((w) => w.status === 'waiting').length + 1,
      joinedAt: new Date(),
      respondedAt: null,
    };

    activity.waitlist.push(entry);
    await activity.save();

    res.json({ success: true, data: entry });
  } catch (error) {
    console.error('Join waitlist error:', error);
    res.status(500).json({ success: false, message: 'Failed to join waitlist' });
  }
});

// ============================================================
// DELETE /waitlist/leave/:eventId - Leave waitlist
// ============================================================
router.delete('/waitlist/leave/:eventId', auth, async (req, res) => {
  try {
    const result = await Activity.findOneAndUpdate(
      {
        activityId: parseInt(req.params.eventId),
        'waitlist.userId': req.user.userId,
        'waitlist.status': 'waiting',
      },
      {
        $set: {
          'waitlist.$[elem].status': 'cancelled',
        },
      },
      {
        arrayFilters: [{ 'elem.userId': req.user.userId, 'elem.status': 'waiting' }],
        new: true,
      }
    );

    if (!result) {
      const activity = await Activity.findOne({ activityId: parseInt(req.params.eventId) });
      if (!activity) {
        return res.status(404).json({ success: false, message: 'Activity not found' });
      }
      return res.status(404).json({ success: false, message: 'Not on waitlist' });
    }

    res.json({ success: true });
  } catch (error) {
    console.error('Leave waitlist error:', error);
    res.status(500).json({ success: false, message: 'Failed to leave waitlist' });
  }
});

// ============================================================
// GET /waitlist/:eventId - Get event waitlist
// ============================================================
router.get('/waitlist/:eventId', auth, async (req, res) => {
  try {
    const activity = await Activity.findOne({ activityId: parseInt(req.params.eventId) });
    if (!activity) {
      return res.status(404).json({ success: false, message: 'Activity not found' });
    }

    const waitlist = activity.waitlist || [];
    const summary = {
      total: waitlist.length,
      waiting: waitlist.filter((w) => w.status === 'waiting').length,
      offered: waitlist.filter((w) => w.status === 'offered').length,
      accepted: waitlist.filter((w) => w.status === 'accepted').length,
      declined: waitlist.filter((w) => w.status === 'declined').length,
      cancelled: waitlist.filter((w) => w.status === 'cancelled').length,
      entries: waitlist,
    };

    res.json({ success: true, data: summary });
  } catch (error) {
    console.error('Get waitlist error:', error);
    res.status(500).json({ success: false, message: 'Failed to get waitlist' });
  }
});

// ============================================================
// POST /waitlist/respond - Respond to waitlist offer
// ============================================================
router.post('/waitlist/respond', auth, async (req, res) => {
  try {
    const { waitlist_id, accept } = req.body;

    // Verify entry exists and user owns it (read-only check)
    const activity = await Activity.findOne({ 'waitlist.waitlistId': waitlist_id });
    if (!activity) {
      return res.status(404).json({ success: false, message: 'Waitlist entry not found' });
    }

    const entry = activity.waitlist.find((w) => w.waitlistId === waitlist_id);
    if (!entry) {
      return res.status(404).json({ success: false, message: 'Waitlist entry not found' });
    }

    if (String(entry.userId) !== String(req.user.userId)) {
      return res.status(403).json({ success: false, message: 'Not authorized' });
    }

    if (entry.status !== 'offered') {
      return res.status(409).json({ success: false, message: 'Waitlist entry is no longer in offered state' });
    }

    if (!accept) {
      // Decline: atomic update of waitlist status only
      const declined = await Activity.findOneAndUpdate(
        { 'waitlist.waitlistId': waitlist_id, 'waitlist.status': 'offered' },
        {
          $set: {
            'waitlist.$[elem].status': 'declined',
            'waitlist.$[elem].respondedAt': new Date(),
          },
        },
        { arrayFilters: [{ 'elem.waitlistId': waitlist_id }], new: true }
      );
      if (!declined) {
        return res.status(409).json({ success: false, message: 'Waitlist entry already responded to' });
      }
      const updatedEntry = declined.waitlist.find((w) => w.waitlistId === waitlist_id);
      return res.json({ success: true, data: updatedEntry });
    }

    // Accept: atomic update of waitlist status + add to attendees + decrement slots
    const accepted = await Activity.findOneAndUpdate(
      {
        _id: activity._id,
        'waitlist.waitlistId': waitlist_id,
        'waitlist.status': 'offered',
        'attendees.userId': { $ne: req.user.userId },
        remainingSlots: { $gt: 0 },
      },
      {
        $set: {
          'waitlist.$[elem].status': 'accepted',
          'waitlist.$[elem].respondedAt': new Date(),
        },
        $push: {
          attendees: {
            userId: req.user.userId,
            name: req.user.userName || 'Unknown',
            images: req.user.profile?.images || [],
          },
        },
        $inc: { remainingSlots: -1 },
      },
      { arrayFilters: [{ 'elem.waitlistId': waitlist_id }], new: true }
    );

    if (!accepted) {
      return res.status(400).json({ success: false, message: 'Event is full, already joined, or offer expired' });
    }

    const updatedEntry = accepted.waitlist.find((w) => w.waitlistId === waitlist_id);
    res.json({ success: true, data: updatedEntry });
  } catch (error) {
    console.error('Respond to waitlist error:', error);
    res.status(500).json({ success: false, message: 'Failed to respond to waitlist' });
  }
});

// ============================================================
// GET /waitlist/position/:eventId - Get user's waitlist position
// ============================================================
router.get('/waitlist/position/:eventId', auth, async (req, res) => {
  try {
    const activity = await Activity.findOne({ activityId: parseInt(req.params.eventId) });
    if (!activity) {
      return res.status(404).json({ success: false, message: 'Activity not found' });
    }

    const waitlist = activity.waitlist || [];
    const entry = waitlist.find(
      (w) => String(w.userId) === String(req.user.userId) && w.status === 'waiting'
    );

    if (!entry) {
      return res.status(404).json({ success: false, message: 'Not on waitlist' });
    }

    // Recalculate position based on waiting entries sorted by joinedAt
    const waitingEntries = waitlist
      .filter((w) => w.status === 'waiting')
      .sort((a, b) => new Date(a.joinedAt) - new Date(b.joinedAt));
    const position = waitingEntries.findIndex(
      (w) => String(w.userId) === String(req.user.userId)
    ) + 1;

    res.json({ success: true, data: { ...entry, position } });
  } catch (error) {
    console.error('Get waitlist position error:', error);
    res.status(500).json({ success: false, message: 'Failed to get waitlist position' });
  }
});

// ============================================================
// GET /waitlist - Get all user's waitlist entries
// ============================================================
router.get('/waitlist', auth, async (req, res) => {
  try {
    const activities = await Activity.find({
      'waitlist.userId': req.user.userId,
    });

    const data = [];
    activities.forEach((activity) => {
      const userEntries = (activity.waitlist || []).filter(
        (w) => String(w.userId) === String(req.user.userId)
      );
      userEntries.forEach((entry) => {
        data.push({
          ...entry.toObject ? entry.toObject() : entry,
          activityId: activity.activityId,
          activityName: activity.name,
          activityDate: activity.dateTime,
        });
      });
    });

    res.json({ success: true, data });
  } catch (error) {
    console.error('Get user waitlists error:', error);
    res.status(500).json({ success: false, message: 'Failed to get waitlists' });
  }
});

// ============================================================
// POST /recurring/create - Create recurring event series
// ============================================================
router.post('/recurring/create', auth, async (req, res) => {
  try {
    const {
      name,
      description,
      location,
      latitude,
      longitude,
      event_type,
      total_slots,
      recurrence_type,
      interval,
      days_of_week,
      day_of_month,
      start_date,
      end_date,
      max_occurrences,
      time_of_day,
    } = req.body;

    // Generate series ID
    const seriesId = Date.now();

    // Find or initialize the recurring series collection on a stub basis
    // Store recurring series data as a special activity document with isRecurringSeries flag
    const lastActivity = await Activity.findOne().sort({ activityId: -1 });
    const baseActivityId = lastActivity ? lastActivity.activityId + 1 : 1;

    const series = new Activity({
      name,
      description,
      location,
      latitude: parseFloat(latitude) || 0,
      longitude: parseFloat(longitude) || 0,
      dateTime: start_date ? new Date(start_date) : new Date(),
      eventType: event_type,
      images: [],
      totalSlots: parseInt(total_slots) || 0,
      remainingSlots: parseInt(total_slots) || 0,
      attendees: [],
      savedBy: [],
      creatorId: req.user.userId,
      creatorName: req.user.userName || 'Unknown',
      creatorImages: req.user.profile?.images || [],
      isRecurringSeries: true,
      seriesId,
      recurrenceRule: {
        recurrenceType: recurrence_type || 'weekly',
        interval: parseInt(interval) || 1,
        daysOfWeek: days_of_week || [],
        dayOfMonth: day_of_month || null,
        startDate: start_date ? new Date(start_date) : new Date(),
        endDate: end_date ? new Date(end_date) : null,
        maxOccurrences: max_occurrences || null,
        timeOfDay: time_of_day || '18:00',
      },
      recurringInstances: [],
    });

    await series.save();

    const data = {
      seriesId,
      activityId: baseActivityId,
      name,
      recurrenceRule: series.recurrenceRule,
      creatorId: req.user.userId,
      createdAt: series.createdAt,
    };

    res.status(201).json({ success: true, data });
  } catch (error) {
    console.error('Create recurring series error:', error);
    res.status(500).json({ success: false, message: 'Failed to create recurring series' });
  }
});

// ============================================================
// GET /recurring/series/:seriesId - Get a recurring series
// ============================================================
router.get('/recurring/series/:seriesId', auth, async (req, res) => {
  try {
    const series = await Activity.findOne({
      seriesId: parseInt(req.params.seriesId),
      isRecurringSeries: true,
    });
    if (!series) {
      return res.status(404).json({ success: false, message: 'Series not found' });
    }

    const data = {
      seriesId: series.seriesId,
      activity: formatActivity(series, req.user.userId),
      recurrenceRule: series.recurrenceRule,
      instances: series.recurringInstances || [],
    };

    res.json({ success: true, data });
  } catch (error) {
    console.error('Get recurring series error:', error);
    res.status(500).json({ success: false, message: 'Failed to get recurring series' });
  }
});

// ============================================================
// GET /recurring/series - Get my recurring series
// ============================================================
router.get('/recurring/series', auth, async (req, res) => {
  try {
    const seriesList = await Activity.find({
      creatorId: req.user.userId,
      isRecurringSeries: true,
    }).sort({ createdAt: -1 });

    const data = seriesList.map((series) => ({
      seriesId: series.seriesId,
      activity: formatActivity(series, req.user.userId),
      recurrenceRule: series.recurrenceRule,
      instanceCount: (series.recurringInstances || []).length,
    }));

    res.json({ success: true, data });
  } catch (error) {
    console.error('Get my recurring series error:', error);
    res.status(500).json({ success: false, message: 'Failed to get recurring series' });
  }
});

// ============================================================
// PUT /recurring/update - Update a recurring series
// ============================================================
router.put('/recurring/update', auth, async (req, res) => {
  try {
    const {
      series_id,
      name,
      description,
      location,
      latitude,
      longitude,
      event_type,
      total_slots,
      recurrence_type,
      interval,
      days_of_week,
      day_of_month,
      end_date,
      max_occurrences,
      time_of_day,
    } = req.body;

    const series = await Activity.findOne({
      seriesId: parseInt(series_id),
      isRecurringSeries: true,
    });
    if (!series) {
      return res.status(404).json({ success: false, message: 'Series not found' });
    }

    if (String(series.creatorId) !== String(req.user.userId)) {
      return res.status(403).json({ success: false, message: 'Only the creator can update this series' });
    }

    if (name !== undefined) series.name = name;
    if (description !== undefined) series.description = description;
    if (location !== undefined) series.location = location;
    if (latitude !== undefined) series.latitude = parseFloat(latitude);
    if (longitude !== undefined) series.longitude = parseFloat(longitude);
    if (event_type !== undefined) series.eventType = event_type;
    if (total_slots !== undefined) {
      const newTotal = parseInt(total_slots);
      if (isNaN(newTotal) || newTotal < 1) {
        return res.status(400).json({ success: false, message: 'total_slots must be a valid positive number' });
      }
      series.totalSlots = newTotal;
      series.remainingSlots = newTotal;
    }

    // Update recurrence rule fields
    if (series.recurrenceRule) {
      if (recurrence_type !== undefined) series.recurrenceRule.recurrenceType = recurrence_type;
      if (interval !== undefined) series.recurrenceRule.interval = parseInt(interval);
      if (days_of_week !== undefined) series.recurrenceRule.daysOfWeek = days_of_week;
      if (day_of_month !== undefined) series.recurrenceRule.dayOfMonth = day_of_month;
      if (end_date !== undefined) series.recurrenceRule.endDate = end_date ? new Date(end_date) : null;
      if (max_occurrences !== undefined) series.recurrenceRule.maxOccurrences = max_occurrences;
      if (time_of_day !== undefined) series.recurrenceRule.timeOfDay = time_of_day;
    }

    await series.save();

    const data = {
      seriesId: series.seriesId,
      activity: formatActivity(series, req.user.userId),
      recurrenceRule: series.recurrenceRule,
    };

    res.json({ success: true, data });
  } catch (error) {
    console.error('Update recurring series error:', error);
    res.status(500).json({ success: false, message: 'Failed to update recurring series' });
  }
});

// ============================================================
// POST /recurring/cancel-instance - Cancel a single instance
// ============================================================
router.post('/recurring/cancel-instance', auth, async (req, res) => {
  try {
    const { series_id, instance_id, cancellation_reason, notify_attendees } = req.body;

    const series = await Activity.findOne({
      seriesId: parseInt(series_id),
      isRecurringSeries: true,
    });
    if (!series) {
      return res.status(404).json({ success: false, message: 'Series not found' });
    }

    if (String(series.creatorId) !== String(req.user.userId)) {
      return res.status(403).json({ success: false, message: 'Only the creator can cancel instances' });
    }

    if (!series.recurringInstances) series.recurringInstances = [];

    const instance = {
      instanceId: String(instance_id || Date.now()),
      seriesId: parseInt(series_id),
      status: 'cancelled',
      cancellationReason: cancellation_reason || '',
      notifyAttendees: notify_attendees || false,
      cancelledAt: new Date(),
      cancelledBy: req.user.userId,
    };

    // Check if instance already exists and update, or add new
    const existingIndex = series.recurringInstances.findIndex(
      (i) => String(i.instanceId) === String(instance.instanceId)
    );
    if (existingIndex !== -1) {
      series.recurringInstances[existingIndex] = instance;
    } else {
      series.recurringInstances.push(instance);
    }

    await series.save();
    res.json({ success: true, data: instance });
  } catch (error) {
    console.error('Cancel instance error:', error);
    res.status(500).json({ success: false, message: 'Failed to cancel instance' });
  }
});

// ============================================================
// DELETE /recurring/delete/:seriesId - Delete entire series
// ============================================================
router.delete('/recurring/delete/:seriesId', auth, async (req, res) => {
  try {
    const series = await Activity.findOne({
      seriesId: parseInt(req.params.seriesId),
      isRecurringSeries: true,
    });
    if (!series) {
      return res.status(404).json({ success: false, message: 'Series not found' });
    }

    if (String(series.creatorId) !== String(req.user.userId)) {
      return res.status(403).json({ success: false, message: 'Only the creator can delete this series' });
    }

    await Activity.deleteOne({ _id: series._id });
    res.json({ success: true });
  } catch (error) {
    console.error('Delete recurring series error:', error);
    res.status(500).json({ success: false, message: 'Failed to delete recurring series' });
  }
});

// ============================================================
// GET /recurring/instances/:seriesId - Get instances of a series
// ============================================================
router.get('/recurring/instances/:seriesId', auth, async (req, res) => {
  try {
    const { limit, from_date, to_date } = req.query;

    const series = await Activity.findOne({
      seriesId: parseInt(req.params.seriesId),
      isRecurringSeries: true,
    });
    if (!series) {
      return res.status(404).json({ success: false, message: 'Series not found' });
    }

    let instances = series.recurringInstances || [];

    // Filter by date range if provided
    if (from_date) {
      const fromDate = new Date(from_date);
      instances = instances.filter((i) => !i.cancelledAt || new Date(i.cancelledAt) >= fromDate);
    }
    if (to_date) {
      const toDate = new Date(to_date);
      instances = instances.filter((i) => !i.cancelledAt || new Date(i.cancelledAt) <= toDate);
    }

    // Limit results
    if (limit) {
      instances = instances.slice(0, parseInt(limit));
    }

    res.json({ success: true, data: instances });
  } catch (error) {
    console.error('Get recurring instances error:', error);
    res.status(500).json({ success: false, message: 'Failed to get recurring instances' });
  }
});

// ============================================================
// GET /trending - Get trending activities (most attendees, upcoming)
// ============================================================
router.get('/trending', auth, async (req, res) => {
  try {
    const limit = Math.min(Math.max(parseInt(req.query.limit) || 10, 1), 50);
    const now = new Date();

    // Find upcoming activities, sort by attendees array length (most popular)
    const activities = await Activity.aggregate([
      {
        $match: {
          dateTime: { $gte: now },
          status: { $ne: 'cancelled' },
        },
      },
      {
        $addFields: {
          attendeeCount: { $size: { $ifNull: ['$attendees', []] } },
        },
      },
      { $sort: { attendeeCount: -1, dateTime: 1 } },
      { $limit: limit },
    ]);

    const data = activities.map((a) => formatActivity(a, req.user.userId));
    res.json({ success: true, data });
  } catch (error) {
    console.error('Get trending activities error:', error);
    res.status(500).json({ success: false, message: 'Failed to get trending activities' });
  }
});

// ============================================================
// GET /suggested - Get suggested activities based on user interests
// ============================================================
router.get('/suggested', auth, async (req, res) => {
  try {
    const limit = Math.min(Math.max(parseInt(req.query.limit) || 10, 1), 50);
    const now = new Date();

    // Get user interests
    const user = await User.findById(req.userId).select('profile.interests');
    const interests = user?.profile?.interests || [];

    let activities;

    if (interests.length > 0) {
      // Find upcoming activities matching user interests
      activities = await Activity.find({
        dateTime: { $gte: now },
        status: { $ne: 'cancelled' },
        eventType: { $in: interests },
        'attendees.userId': { $ne: req.user.userId }, // Not already joined
      })
        .sort({ dateTime: 1 })
        .limit(limit);
    } else {
      // No interests set - return upcoming activities
      activities = await Activity.find({
        dateTime: { $gte: now },
        status: { $ne: 'cancelled' },
        'attendees.userId': { $ne: req.user.userId },
      })
        .sort({ dateTime: 1 })
        .limit(limit);
    }

    const data = activities.map((a) => formatActivity(a, req.user.userId));
    res.json({ success: true, data });
  } catch (error) {
    console.error('Get suggested activities error:', error);
    res.status(500).json({ success: false, message: 'Failed to get suggested activities' });
  }
});

module.exports = router;
