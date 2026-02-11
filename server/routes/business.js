const express = require('express');
const router = express.Router();
const Business = require('../models/Business');
const BusinessEvent = require('../models/BusinessEvent');
const { auth } = require('../middleware/auth');
const upload = require('../middleware/upload');

// ============================================================
// Authentication
// ============================================================

// POST /api/business/login - Business login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ success: false, message: 'Email and password are required' });
    }

    const business = await Business.findOne({ email: email.toLowerCase() });
    if (!business) {
      return res.status(404).json({ success: false, message: 'Business not found' });
    }

    const User = require('../models/User');
    const user = await User.findOne({ userId: business.userId }).select('+password');
    if (!user) {
      return res.status(404).json({ success: false, message: 'User account not found' });
    }

    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }

    const { generateTokens } = require('../middleware/auth');
    const { token, refreshToken } = generateTokens(user._id);

    res.json({
      success: true,
      token,
      refreshToken,
      userId: user.userId,
      message: 'Business login successful',
    });
  } catch (error) {
    console.error('Business login error:', error);
    res.status(500).json({ success: false, message: 'Failed to login' });
  }
});

// POST /api/business/register - Business registration
router.post('/register', async (req, res) => {
  try {
    const { businessName, businessType, email, phone, password } = req.body;
    if (!businessName || !email || !password) {
      return res.status(400).json({ success: false, message: 'Business name, email, and password are required' });
    }

    const User = require('../models/User');
    const existingUser = await User.findOne({ email: email.toLowerCase() });
    if (existingUser) {
      return res.status(409).json({ success: false, message: 'Email already registered' });
    }

    const user = await User.create({
      email: email.toLowerCase(),
      password,
      userName: businessName,
      phone,
      accountType: 'business',
    });

    const business = await Business.create({
      userId: user.userId,
      businessName,
      businessType: businessType || 'general',
      email: email.toLowerCase(),
      phone,
    });

    const { generateTokens } = require('../middleware/auth');
    const { token, refreshToken } = generateTokens(user._id);

    res.status(201).json({
      success: true,
      token,
      refreshToken,
      userId: user.userId,
      message: 'Business registered successfully',
    });
  } catch (error) {
    console.error('Business register error:', error);
    res.status(500).json({ success: false, message: 'Failed to register business' });
  }
});

// ============================================================
// Profile
// ============================================================

// GET /api/business/profile - Get business profile
router.get('/profile', auth, async (req, res) => {
  try {
    const business = await Business.findOne({ userId: req.user.userId });
    if (!business) {
      return res.status(404).json({ success: false, message: 'Business profile not found' });
    }

    res.json({ success: true, data: business });
  } catch (error) {
    console.error('Get business profile error:', error);
    res.status(500).json({ success: false, message: 'Failed to get business profile' });
  }
});

// POST /api/business/create-profile - Create business profile
router.post(
  '/create-profile',
  auth,
  upload.fields([
    { name: 'profileImage', maxCount: 1 },
    { name: 'coverImage', maxCount: 1 },
  ]),
  async (req, res) => {
    try {
      const existing = await Business.findOne({ userId: req.user.userId });
      if (existing) {
        return res.status(409).json({ success: false, message: 'Business profile already exists' });
      }

      const profileData = { ...req.body, userId: req.user.userId };

      if (req.files) {
        if (req.files.profileImage && req.files.profileImage[0]) {
          profileData.profileImage = `/uploads/${req.files.profileImage[0].filename}`;
        }
        if (req.files.coverImage && req.files.coverImage[0]) {
          profileData.coverImage = `/uploads/${req.files.coverImage[0].filename}`;
        }
      }

      const business = await Business.create(profileData);
      res.status(201).json({ success: true, data: business });
    } catch (error) {
      console.error('Create business profile error:', error);
      res.status(500).json({ success: false, message: 'Failed to create business profile' });
    }
  }
);

// PUT /api/business/update/:businessId - Update business profile
router.put('/update/:businessId', auth, async (req, res) => {
  try {
    const business = await Business.findOneAndUpdate(
      { _id: req.params.businessId, userId: req.user.userId },
      { $set: req.body },
      { new: true }
    );

    if (!business) {
      return res.status(404).json({ success: false, message: 'Business not found or not authorized' });
    }

    res.json({ success: true, data: business });
  } catch (error) {
    console.error('Update business profile error:', error);
    res.status(500).json({ success: false, message: 'Failed to update business profile' });
  }
});

// POST /api/business/upload-profile-image - Upload profile image
router.post('/upload-profile-image', auth, upload.single('profileImage'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: 'No image provided' });
    }

    const imageUrl = `/uploads/${req.file.filename}`;
    const business = await Business.findOneAndUpdate(
      { userId: req.user.userId },
      { $set: { profileImage: imageUrl } },
      { new: true }
    );

    if (!business) {
      return res.status(404).json({ success: false, message: 'Business profile not found' });
    }

    res.json({ success: true, data: business });
  } catch (error) {
    console.error('Upload profile image error:', error);
    res.status(500).json({ success: false, message: 'Failed to upload profile image' });
  }
});

// POST /api/business/upload-cover-image - Upload cover image
router.post('/upload-cover-image', auth, upload.single('coverImage'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: 'No image provided' });
    }

    const imageUrl = `/uploads/${req.file.filename}`;
    const business = await Business.findOneAndUpdate(
      { userId: req.user.userId },
      { $set: { coverImage: imageUrl } },
      { new: true }
    );

    if (!business) {
      return res.status(404).json({ success: false, message: 'Business profile not found' });
    }

    res.json({ success: true, data: business });
  } catch (error) {
    console.error('Upload cover image error:', error);
    res.status(500).json({ success: false, message: 'Failed to upload cover image' });
  }
});

// ============================================================
// Verification
// ============================================================

// POST /api/business/request-otp - Request business verification OTP
router.post('/request-otp', auth, async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) {
      return res.status(400).json({ success: false, message: 'Email is required' });
    }

    const otp = Math.floor(100000 + Math.random() * 900000).toString();

    const business = await Business.findOneAndUpdate(
      { userId: req.user.userId },
      { $set: { verificationOtp: otp, otpExpiresAt: new Date(Date.now() + 10 * 60 * 1000) } }
    );

    if (!business) {
      return res.status(404).json({ success: false, message: 'Business not found' });
    }

    const { sendOtpEmail } = require('../services/emailService');
    await sendOtpEmail(email, otp, 'businessVerification');

    res.json({ success: true, message: 'OTP sent to email' });
  } catch (error) {
    console.error('Request OTP error:', error);
    res.status(500).json({ success: false, message: 'Failed to send OTP' });
  }
});

// POST /api/business/verify - Verify business with OTP
router.post('/verify', auth, async (req, res) => {
  try {
    const { email, otp } = req.body;
    if (!email || !otp) {
      return res.status(400).json({ success: false, message: 'Email and OTP are required' });
    }

    const business = await Business.findOne({ userId: req.user.userId });
    if (!business) {
      return res.status(404).json({ success: false, message: 'Business not found' });
    }

    if (business.verificationOtp !== otp) {
      return res.status(400).json({ success: false, message: 'Invalid OTP' });
    }

    if (business.otpExpiresAt && business.otpExpiresAt < new Date()) {
      return res.status(400).json({ success: false, message: 'OTP has expired' });
    }

    business.isVerified = true;
    business.verificationOtp = undefined;
    business.otpExpiresAt = undefined;
    await business.save();

    res.json({ success: true, message: 'Business verified successfully' });
  } catch (error) {
    console.error('Verify business error:', error);
    res.status(500).json({ success: false, message: 'Failed to verify business' });
  }
});

// GET /api/business/status - Get business status
router.get('/status', auth, async (req, res) => {
  try {
    const business = await Business.findOne({ userId: req.user.userId });
    if (!business) {
      return res.status(404).json({ success: false, message: 'Business not found' });
    }

    res.json({
      success: true,
      data: {
        isVerified: business.isVerified || false,
        subscriptionStatus: business.subscriptionStatus || null,
      },
    });
  } catch (error) {
    console.error('Get business status error:', error);
    res.status(500).json({ success: false, message: 'Failed to get business status' });
  }
});

// ============================================================
// Business Events
// ============================================================

// GET /api/business/list - List all business events (public)
router.get('/list', auth, async (req, res) => {
  try {
    const events = await BusinessEvent.find({ privacy: { $ne: 'private' } })
      .sort({ startDate: -1 })
      .limit(50);

    const userId = req.user.userId;
    const data = events.map((event) => formatBusinessEvent(event, userId));

    res.json({ success: true, data });
  } catch (error) {
    console.error('List business events error:', error);
    res.status(500).json({ success: false, message: 'Failed to list business events' });
  }
});

// GET /api/business/event-list - Get MY business events
router.get('/event-list', auth, async (req, res) => {
  try {
    const business = await Business.findOne({ userId: req.user.userId });
    if (!business) {
      return res.status(404).json({ success: false, message: 'Business not found' });
    }

    const events = await BusinessEvent.find({ businessId: business._id })
      .sort({ startDate: -1 });

    const userId = req.user.userId;
    const data = events.map((event) => formatBusinessEvent(event, userId));

    res.json({ success: true, data });
  } catch (error) {
    console.error('Get my business events error:', error);
    res.status(500).json({ success: false, message: 'Failed to get business events' });
  }
});

// POST /api/business/create-event - Create business event
router.post('/create-event', auth, async (req, res) => {
  try {
    const business = await Business.findOne({ userId: req.user.userId });
    if (!business) {
      return res.status(404).json({ success: false, message: 'Business profile not found. Please set up your business profile first.' });
    }

    if (!business.isVerified) {
      return res.status(403).json({ success: false, message: 'Your business must be verified before you can create events. Please contact support or wait for admin verification.' });
    }

    const {
      name,
      description,
      location,
      latitude,
      longitude,
      startTime,
      endTime,
      eventType,
      totalSlots,
      price,
      currency,
    } = req.body;

    if (!name || !location) {
      return res.status(400).json({ success: false, message: 'Name and location are required' });
    }

    // Use != null instead of truthy checks to handle 0 values correctly
    const parsedSlots = totalSlots != null ? parseInt(totalSlots) : undefined;

    const event = await BusinessEvent.create({
      businessId: business._id,
      name,
      description: description || '',
      location,
      latitude: latitude != null ? parseFloat(latitude) : undefined,
      longitude: longitude != null ? parseFloat(longitude) : undefined,
      startDate: startTime ? new Date(startTime) : new Date(),
      endDate: endTime ? new Date(endTime) : undefined,
      eventType: eventType || 'Free',
      totalSlots: parsedSlots,
      maxAttendees: parsedSlots,
      remainingSlots: parsedSlots,
      price: price != null ? parseFloat(price) : 0,
      currency: currency || 'USD',
      attendees: [],
      savedBy: [],
      views: 0,
      clicks: 0,
    });

    res.status(201).json({ success: true, data: formatBusinessEvent(event, req.user.userId) });
  } catch (error) {
    console.error('Create business event error:', error);
    res.status(500).json({ success: false, message: 'Failed to create business event' });
  }
});

// PUT /api/business/update-event/:eventId - Update business event
router.put('/update-event/:eventId', auth, async (req, res) => {
  try {
    const business = await Business.findOne({ userId: req.user.userId });
    if (!business) {
      return res.status(404).json({ success: false, message: 'Business not found' });
    }

    const updateData = { ...req.body };
    if (updateData.startTime) {
      updateData.startDate = new Date(updateData.startTime);
      delete updateData.startTime;
    }
    if (updateData.endTime) {
      updateData.endDate = new Date(updateData.endTime);
      delete updateData.endTime;
    }

    const event = await BusinessEvent.findOneAndUpdate(
      { _id: req.params.eventId, businessId: business._id },
      { $set: updateData },
      { new: true }
    );

    if (!event) {
      return res.status(404).json({ success: false, message: 'Event not found or not authorized' });
    }

    res.json({ success: true, data: formatBusinessEvent(event, req.user.userId) });
  } catch (error) {
    console.error('Update business event error:', error);
    res.status(500).json({ success: false, message: 'Failed to update business event' });
  }
});

// GET /api/business/event/:eventId - Get business event details
router.get('/event/:eventId', auth, async (req, res) => {
  try {
    const event = await BusinessEvent.findById(req.params.eventId);
    if (!event) {
      return res.status(404).json({ success: false, message: 'Event not found' });
    }

    res.json({ success: true, data: formatBusinessEvent(event, req.user.userId) });
  } catch (error) {
    console.error('Get business event details error:', error);
    res.status(500).json({ success: false, message: 'Failed to get event details' });
  }
});

// DELETE /api/business/delete-event/:eventId - Delete business event
router.delete('/delete-event/:eventId', auth, async (req, res) => {
  try {
    const business = await Business.findOne({ userId: req.user.userId });
    if (!business) {
      return res.status(404).json({ success: false, message: 'Business not found' });
    }

    const event = await BusinessEvent.findOneAndDelete({
      _id: req.params.eventId,
      businessId: business._id,
    });

    if (!event) {
      return res.status(404).json({ success: false, message: 'Event not found or not authorized' });
    }

    res.json({ success: true, message: 'Event deleted successfully' });
  } catch (error) {
    console.error('Delete business event error:', error);
    res.status(500).json({ success: false, message: 'Failed to delete event' });
  }
});

// ============================================================
// Event Participation
// ============================================================

// POST /api/business/join-event - Join business event
router.post('/join-event', auth, async (req, res) => {
  try {
    const { eventId } = req.body;
    if (!eventId) {
      return res.status(400).json({ success: false, message: 'Event ID is required' });
    }

    const event = await BusinessEvent.findById(eventId);
    if (!event) {
      return res.status(404).json({ success: false, message: 'Event not found' });
    }

    const userId = req.user.userId;
    if (event.attendees && event.attendees.includes(userId)) {
      return res.status(400).json({ success: false, message: 'Already joined this event' });
    }

    if (event.remainingSlots !== undefined && event.remainingSlots !== null && event.remainingSlots <= 0) {
      return res.status(400).json({ success: false, message: 'Event is full' });
    }

    await BusinessEvent.findByIdAndUpdate(eventId, {
      $addToSet: { attendees: userId },
      $inc: { attendeesCount: 1, remainingSlots: event.remainingSlots != null ? -1 : 0 },
    });

    res.json({ success: true, message: 'Joined event successfully' });
  } catch (error) {
    console.error('Join business event error:', error);
    res.status(500).json({ success: false, message: 'Failed to join event' });
  }
});

// POST /api/business/leave-event - Leave business event
router.post('/leave-event', auth, async (req, res) => {
  try {
    const { eventId } = req.body;
    if (!eventId) {
      return res.status(400).json({ success: false, message: 'Event ID is required' });
    }

    const event = await BusinessEvent.findById(eventId);
    if (!event) {
      return res.status(404).json({ success: false, message: 'Event not found' });
    }

    const userId = req.user.userId;
    await BusinessEvent.findByIdAndUpdate(eventId, {
      $pull: { attendees: userId },
      $inc: { attendeesCount: -1, remainingSlots: event.remainingSlots != null ? 1 : 0 },
    });

    res.json({ success: true, message: 'Left event successfully' });
  } catch (error) {
    console.error('Leave business event error:', error);
    res.status(500).json({ success: false, message: 'Failed to leave event' });
  }
});

// POST /api/business/save-event - Toggle save event
router.post('/save-event', auth, async (req, res) => {
  try {
    const { eventId } = req.body;
    if (!eventId) {
      return res.status(400).json({ success: false, message: 'Event ID is required' });
    }

    const event = await BusinessEvent.findById(eventId);
    if (!event) {
      return res.status(404).json({ success: false, message: 'Event not found' });
    }

    const userId = req.user.userId;
    const isSaved = event.savedBy && event.savedBy.includes(userId);

    if (isSaved) {
      await BusinessEvent.findByIdAndUpdate(eventId, {
        $pull: { savedBy: userId },
        $inc: { saves: -1 },
      });
    } else {
      await BusinessEvent.findByIdAndUpdate(eventId, {
        $addToSet: { savedBy: userId },
        $inc: { saves: 1 },
      });
    }

    res.json({ success: true, message: isSaved ? 'Event unsaved' : 'Event saved' });
  } catch (error) {
    console.error('Save business event error:', error);
    res.status(500).json({ success: false, message: 'Failed to save event' });
  }
});

// GET /api/business/saved-list - Get saved events
router.get('/saved-list', auth, async (req, res) => {
  try {
    const userId = req.user.userId;
    const events = await BusinessEvent.find({ savedBy: userId }).sort({ createdAt: -1 });

    const data = events.map((event) => formatBusinessEvent(event, userId));
    res.json({ success: true, data });
  } catch (error) {
    console.error('Get saved events error:', error);
    res.status(500).json({ success: false, message: 'Failed to get saved events' });
  }
});

// GET /api/business/top-events - Top events by views/clicks
router.get('/top-events', auth, async (req, res) => {
  try {
    const events = await BusinessEvent.find()
      .sort({ views: -1, clicks: -1 })
      .limit(20);

    const userId = req.user.userId;
    const data = events.map((event) => formatBusinessEvent(event, userId));

    res.json({ success: true, data });
  } catch (error) {
    console.error('Get top events error:', error);
    res.status(500).json({ success: false, message: 'Failed to get top events' });
  }
});

// POST /api/business/events/:eventId/click - Record event click
router.post('/events/:eventId/click', auth, async (req, res) => {
  try {
    await BusinessEvent.findByIdAndUpdate(req.params.eventId, {
      $inc: { clicks: 1 },
    });

    res.json({ success: true, message: 'Click recorded' });
  } catch (error) {
    console.error('Record event click error:', error);
    res.status(500).json({ success: false, message: 'Failed to record click' });
  }
});

// POST /api/business/events/:eventId/view - Record event view
router.post('/events/:eventId/view', auth, async (req, res) => {
  try {
    await BusinessEvent.findByIdAndUpdate(req.params.eventId, {
      $inc: { views: 1 },
    });

    res.json({ success: true, message: 'View recorded' });
  } catch (error) {
    console.error('Record event view error:', error);
    res.status(500).json({ success: false, message: 'Failed to record view' });
  }
});

// ============================================================
// Follow / Unfollow
// ============================================================

// POST /api/business/follow - Follow business
router.post('/follow', auth, async (req, res) => {
  try {
    const { businessId } = req.body;
    if (!businessId) {
      return res.status(400).json({ success: false, message: 'Business ID is required' });
    }

    const business = await Business.findById(businessId);
    if (!business) {
      return res.status(404).json({ success: false, message: 'Business not found' });
    }

    const userId = req.user.userId;
    if (business.followers && business.followers.includes(userId)) {
      return res.status(400).json({ success: false, message: 'Already following this business' });
    }

    await Business.findByIdAndUpdate(businessId, {
      $addToSet: { followers: userId },
      $inc: { followerCount: 1 },
    });

    res.json({ success: true, message: 'Now following business' });
  } catch (error) {
    console.error('Follow business error:', error);
    res.status(500).json({ success: false, message: 'Failed to follow business' });
  }
});

// POST /api/business/unfollow - Unfollow business
router.post('/unfollow', auth, async (req, res) => {
  try {
    const { businessId } = req.body;
    if (!businessId) {
      return res.status(400).json({ success: false, message: 'Business ID is required' });
    }

    const userId = req.user.userId;
    await Business.findByIdAndUpdate(businessId, {
      $pull: { followers: userId },
      $inc: { followerCount: -1 },
    });

    res.json({ success: true, message: 'Unfollowed business' });
  } catch (error) {
    console.error('Unfollow business error:', error);
    res.status(500).json({ success: false, message: 'Failed to unfollow business' });
  }
});

// ============================================================
// Subscriptions
// ============================================================

// POST /api/business/create - Create subscription
router.post('/create', auth, async (req, res) => {
  try {
    const { planId, paymentMethodId } = req.body;
    if (!planId || !paymentMethodId) {
      return res.status(400).json({ success: false, message: 'Plan ID and payment method are required' });
    }

    const business = await Business.findOneAndUpdate(
      { userId: req.user.userId },
      {
        $set: {
          subscriptionStatus: {
            planId,
            planName: planId,
            status: 'active',
            startDate: new Date(),
            expiryDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
            isActive: true,
          },
        },
      },
      { new: true }
    );

    if (!business) {
      return res.status(404).json({ success: false, message: 'Business not found' });
    }

    res.json({ success: true, data: business, message: 'Subscription created successfully' });
  } catch (error) {
    console.error('Create subscription error:', error);
    res.status(500).json({ success: false, message: 'Failed to create subscription' });
  }
});

// POST /api/business/cancel - Cancel subscription
router.post('/cancel', auth, async (req, res) => {
  try {
    const business = await Business.findOneAndUpdate(
      { userId: req.user.userId },
      {
        $set: {
          'subscriptionStatus.status': 'cancelled',
          'subscriptionStatus.isActive': false,
        },
      },
      { new: true }
    );

    if (!business) {
      return res.status(404).json({ success: false, message: 'Business not found' });
    }

    res.json({ success: true, message: 'Subscription cancelled' });
  } catch (error) {
    console.error('Cancel subscription error:', error);
    res.status(500).json({ success: false, message: 'Failed to cancel subscription' });
  }
});

// GET /api/business/subscription-status - Get subscription status
router.get('/subscription-status', auth, async (req, res) => {
  try {
    const business = await Business.findOne({ userId: req.user.userId });
    if (!business) {
      return res.status(404).json({ success: false, message: 'Business not found' });
    }

    res.json({
      success: true,
      data: business.subscriptionStatus || {
        planId: null,
        planName: null,
        status: 'none',
        startDate: null,
        expiryDate: null,
        isActive: false,
      },
    });
  } catch (error) {
    console.error('Get subscription status error:', error);
    res.status(500).json({ success: false, message: 'Failed to get subscription status' });
  }
});

// ============================================================
// Analytics
// ============================================================

// GET /api/business/analytics - Business analytics with period filtering
router.get('/analytics', auth, async (req, res) => {
  try {
    const business = await Business.findOne({ userId: req.user.userId });
    if (!business) {
      return res.status(404).json({ success: false, message: 'Business not found' });
    }

    // Support period filtering: 7d, 30d, 90d, all (default: all)
    const period = req.query.period || 'all';
    const now = new Date();
    let periodStart = null;
    let daysInPeriod = 7;

    if (period === '7d') {
      periodStart = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
      daysInPeriod = 7;
    } else if (period === '30d') {
      periodStart = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
      daysInPeriod = 30;
    } else if (period === '90d') {
      periodStart = new Date(now.getTime() - 90 * 24 * 60 * 60 * 1000);
      daysInPeriod = 90;
    }

    // Build event query with optional date filter
    const eventQuery = { businessId: business._id };
    if (periodStart) {
      eventQuery.createdAt = { $gte: periodStart };
    }

    const events = await BusinessEvent.find(eventQuery);
    const allEvents = await BusinessEvent.find({ businessId: business._id });

    const totalViews = events.reduce((sum, e) => sum + (e.views || 0), 0);
    const totalClicks = events.reduce((sum, e) => sum + (e.clicks || 0), 0);
    const totalAttendees = events.reduce((sum, e) => sum + (e.attendeesCount || 0), 0);
    const totalFollowers = business.followerCount || 0;
    const totalEvents = events.length;

    const topEvents = [...events]
      .sort((a, b) => (b.views || 0) - (a.views || 0))
      .slice(0, 5)
      .map((e) => ({
        event_id: e.eventId || e._id,
        name: e.name,
        views: e.views || 0,
        clicks: e.clicks || 0,
        attendees: e.attendeesCount || 0,
      }));

    // Build views_by_day for the period
    const viewsByDay = {};
    const viewDays = Math.min(daysInPeriod, 30); // Cap chart at 30 days
    for (let i = viewDays - 1; i >= 0; i--) {
      const date = new Date(now);
      date.setDate(date.getDate() - i);
      const key = date.toISOString().split('T')[0];
      viewsByDay[key] = 0;
    }

    // Populate views_by_day from events (based on event creation date)
    events.forEach((e) => {
      if (e.createdAt) {
        const key = new Date(e.createdAt).toISOString().split('T')[0];
        if (viewsByDay[key] !== undefined) {
          viewsByDay[key] += e.views || 0;
        }
      }
    });

    res.json({
      success: true,
      data: {
        total_views: totalViews,
        total_clicks: totalClicks,
        total_followers: totalFollowers,
        total_events: allEvents.length,
        total_attendees: totalAttendees,
        view_rate: totalViews > 0 ? parseFloat(((totalClicks / totalViews) * 100).toFixed(2)) : 0,
        click_rate: totalViews > 0 ? parseFloat(((totalClicks / totalViews) * 100).toFixed(2)) : 0,
        conversion_rate: totalClicks > 0 ? parseFloat(((totalAttendees / totalClicks) * 100).toFixed(2)) : 0,
        followers: totalFollowers,
        followers_growth: 0,
        events_created_this_period: totalEvents,
        events_growth: 0,
        total_engagement: totalViews + totalClicks,
        engagement_growth: 0,
        top_events: topEvents,
        views_by_day: viewsByDay,
      },
    });
  } catch (error) {
    console.error('Get business analytics error:', error);
    res.status(500).json({ success: false, message: 'Failed to get analytics' });
  }
});

// ============================================================
// Rewards (placeholder)
// ============================================================

// GET /api/business/rewards/summary - Rewards summary
router.get('/rewards/summary', auth, async (req, res) => {
  try {
    res.json({
      success: true,
      data: {
        business_id: req.user.userId,
        total_points: 0,
        total_cash_earned: 0,
        pending_rewards: 0,
        claimed_rewards: 0,
        users_referred: 0,
        events_hosted: 0,
        total_attendees: 0,
        tier: 'Bronze',
        tier_progress: 0,
        points_to_next_tier: 1000,
        recent_rewards: [],
      },
    });
  } catch (error) {
    console.error('Get rewards summary error:', error);
    res.status(500).json({ success: false, message: 'Failed to get rewards summary' });
  }
});

// GET /api/business/rewards/list - Rewards list
router.get('/rewards/list', auth, async (req, res) => {
  try {
    res.json({ success: true, data: [] });
  } catch (error) {
    console.error('Get rewards list error:', error);
    res.status(500).json({ success: false, message: 'Failed to get rewards list' });
  }
});

// POST /api/business/rewards/claim - Claim reward
router.post('/rewards/claim', auth, async (req, res) => {
  try {
    const { reward_id } = req.body;
    if (!reward_id) {
      return res.status(400).json({ success: false, message: 'Reward ID is required' });
    }

    res.json({ success: true, message: 'Reward claimed successfully' });
  } catch (error) {
    console.error('Claim reward error:', error);
    res.status(500).json({ success: false, message: 'Failed to claim reward' });
  }
});

// ============================================================
// Referrals (placeholder)
// ============================================================

// GET /api/business/referrals - Get referrals list
router.get('/referrals', auth, async (req, res) => {
  try {
    res.json({ success: true, data: [] });
  } catch (error) {
    console.error('Get referrals error:', error);
    res.status(500).json({ success: false, message: 'Failed to get referrals' });
  }
});

// GET /api/business/referral-code - Get referral code
router.get('/referral-code', auth, async (req, res) => {
  try {
    res.json({
      success: true,
      data: {
        code: null,
        message: 'No referral code generated yet',
      },
    });
  } catch (error) {
    console.error('Get referral code error:', error);
    res.status(500).json({ success: false, message: 'Failed to get referral code' });
  }
});

// POST /api/business/referral-code - Generate referral code
router.post('/referral-code', auth, async (req, res) => {
  try {
    const code = 'FLUTTRR-' + Math.random().toString(36).substring(2, 6).toUpperCase();

    res.json({
      success: true,
      data: { code },
    });
  } catch (error) {
    console.error('Generate referral code error:', error);
    res.status(500).json({ success: false, message: 'Failed to generate referral code' });
  }
});

// ============================================================
// Helper: Format business event for response
// ============================================================

function formatBusinessEvent(event, userId) {
  const attendees = event.attendees || [];
  const savedBy = event.savedBy || [];

  return {
    eventId: event.eventId || event._id,
    businessId: event.businessId,
    name: event.name,
    description: event.description,
    location: event.location,
    locationName: event.locationName || event.location,
    latitude: event.latitude,
    longitude: event.longitude,
    startDate: event.startDate ? event.startDate.toISOString() : null,
    endDate: event.endDate ? event.endDate.toISOString() : null,
    eventType: event.eventType,
    privacy: event.privacy || 'public',
    image: event.image || null,
    images: event.images || [],
    totalSlots: event.totalSlots || null,
    maxAttendees: event.maxAttendees || event.totalSlots || null,
    remainingSlots: event.remainingSlots != null ? event.remainingSlots : event.totalSlots,
    price: event.price || 0,
    currency: event.currency || 'USD',
    ticketUrl: event.ticketUrl || null,
    attendeesCount: event.attendeesCount || attendees.length,
    views: event.views || 0,
    clicks: event.clicks || 0,
    saves: event.saves || savedBy.length,
    user_joined: userId ? attendees.includes(userId) : false,
    user_saved: userId ? savedBy.includes(userId) : false,
  };
}

module.exports = router;
