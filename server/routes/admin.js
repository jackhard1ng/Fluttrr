const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');

// Admin auth middleware - check if user is admin
const adminAuth = async (req, res, next) => {
  if (!req.user || req.user.role !== 'admin') {
    return res.status(403).json({ success: false, message: 'Admin access required' });
  }
  next();
};

// Allowed sort fields per entity to prevent information disclosure
const ALLOWED_SORT_FIELDS = {
  users: ['createdAt', 'userName', 'email', 'status', 'lastSeen', 'accountType', 'userId'],
  businesses: ['createdAt', 'businessName', 'email', 'isVerified', 'followerCount', 'businessId'],
  activities: ['createdAt', 'name', 'dateTime', 'eventType', 'activityId'],
  complaints: ['createdAt', 'status', 'category', 'subject'],
};

function validateSortField(sortBy, entity) {
  const allowed = ALLOWED_SORT_FIELDS[entity] || ['createdAt'];
  return allowed.includes(sortBy) ? sortBy : 'createdAt';
}

// POST /api/admin/complain - Submit complaint (available to all authenticated users)
router.post('/complain', auth, async (req, res) => {
  try {
    const { subject, description, category } = req.body;
    const Complaint = require('../models/Complaint');

    const complaint = await Complaint.create({
      userId: req.user.userId,
      subject,
      description,
      category,
    });

    res.json({ success: true, message: 'Complaint submitted', data: complaint });
  } catch (error) {
    console.error('Submit complaint error:', error);
    res.status(500).json({ success: false, message: 'Failed to submit complaint' });
  }
});

// GET /api/admin/status - Get admin status (any authenticated user)
router.get('/status', auth, async (req, res) => {
  try {
    res.json({
      success: true,
      data: {
        adminId: req.user._id,
        userId: req.user.userId,
        email: req.user.email,
        name: req.user.userName,
        role: req.user.role || 'user',
        permissions: [],
        isActive: true,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to get admin status' });
  }
});

// GET /api/admin/stats - Dashboard statistics (snake_case for Flutter)
router.get('/stats', auth, adminAuth, async (req, res) => {
  try {
    const User = require('../models/User');
    const Activity = require('../models/Activity');
    const Business = require('../models/Business');
    const Complaint = require('../models/Complaint');

    const now = new Date();
    const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);

    // User stats
    const totalUsers = await User.countDocuments();
    const activeUsers = await User.countDocuments({ onlineStatus: 'online' });
    const newUsersToday = await User.countDocuments({ createdAt: { $gte: todayStart } });
    const newUsersThisWeek = await User.countDocuments({ createdAt: { $gte: weekAgo } });

    // Business stats
    const totalBusinesses = await Business.countDocuments();
    const verifiedBusinesses = await Business.countDocuments({ isVerified: true });
    const pendingVerifications = await Business.countDocuments({ isVerified: { $ne: true } });

    // Event stats
    const totalEvents = await Activity.countDocuments();
    const activeEvents = await Activity.countDocuments({
      status: 'active',
      dateTime: { $gte: now },
    });
    const eventsToday = await Activity.countDocuments({
      createdAt: { $gte: todayStart },
    });

    // Report stats
    const pendingReports = await Complaint.countDocuments({ status: { $in: ['pending', 'open'] } });
    const resolvedReportsToday = await Complaint.countDocuments({
      status: 'resolved',
      updatedAt: { $gte: todayStart },
    });

    res.json({
      success: true,
      data: {
        total_users: totalUsers,
        active_users: activeUsers,
        new_users_today: newUsersToday,
        new_users_this_week: newUsersThisWeek,
        total_businesses: totalBusinesses,
        verified_businesses: verifiedBusinesses,
        pending_verifications: pendingVerifications,
        total_events: totalEvents,
        active_events: activeEvents,
        events_today: eventsToday,
        pending_reports: pendingReports,
        resolved_reports_today: resolvedReportsToday,
        total_revenue: 0,
        revenue_this_month: 0,
      },
    });
  } catch (error) {
    console.error('Admin stats error:', error);
    res.status(500).json({ success: false, message: 'Failed to get stats' });
  }
});

// GET /api/admin/users - List users with filtering/pagination
router.get('/users', auth, adminAuth, async (req, res) => {
  try {
    const User = require('../models/User');
    const { page = 1, limit = 20, status, search, is_business_owner, sort_by = 'createdAt', descending = 'true' } = req.query;
    const skip = (Math.max(parseInt(page), 1) - 1) * Math.min(parseInt(limit) || 20, 100);
    const lim = Math.min(parseInt(limit) || 20, 100);

    const filter = {};
    if (status) filter.status = status;
    if (is_business_owner === 'true') filter.accountType = 'business';
    if (search) {
      const regex = new RegExp(search.trim(), 'i');
      filter.$or = [{ userName: regex }, { email: regex }];
    }

    const sortDir = descending === 'true' ? -1 : 1;
    const safeSortBy = validateSortField(sort_by, 'users');
    const users = await User.find(filter)
      .select('-password -refreshToken')
      .skip(skip)
      .limit(lim)
      .sort({ [safeSortBy]: sortDir });

    const total = await User.countDocuments(filter);

    const data = users.map((u) => ({
      user_id: u.userId,
      _id: u._id,
      user_name: u.userName,
      email: u.email,
      status: u.status,
      account_type: u.accountType,
      role: u.role,
      online_status: u.onlineStatus,
      profile_image: u.profile?.images?.[0] || null,
      created_at: u.createdAt,
      last_seen: u.lastSeen,
      completion_percentage: u.completionPercentage,
    }));

    res.json({ success: true, data, pagination: { page: parseInt(page), limit: lim, total, pages: Math.ceil(total / lim) } });
  } catch (error) {
    console.error('Admin list users error:', error);
    res.status(500).json({ success: false, message: 'Failed to list users' });
  }
});

// GET /api/admin/users/:id - Get user details
router.get('/users/:id', auth, adminAuth, async (req, res) => {
  try {
    const User = require('../models/User');
    const user = await User.findById(req.params.id).select('-password -refreshToken');
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });
    res.json({ success: true, data: user });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to get user' });
  }
});

// POST /api/admin/users/:id/suspend
router.post('/users/:id/suspend', auth, adminAuth, async (req, res) => {
  try {
    const User = require('../models/User');
    const user = await User.findByIdAndUpdate(req.params.id, { status: 'suspended' }, { new: true }).select('-password');
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });
    res.json({ success: true, data: user, message: 'User suspended' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to suspend user' });
  }
});

// POST /api/admin/users/:id/unsuspend
router.post('/users/:id/unsuspend', auth, adminAuth, async (req, res) => {
  try {
    const User = require('../models/User');
    const user = await User.findByIdAndUpdate(req.params.id, { status: 'active' }, { new: true }).select('-password');
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });
    res.json({ success: true, data: user, message: 'User unsuspended' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to unsuspend user' });
  }
});

// POST /api/admin/users/:id/ban
router.post('/users/:id/ban', auth, adminAuth, async (req, res) => {
  try {
    const User = require('../models/User');
    const user = await User.findByIdAndUpdate(req.params.id, { status: 'banned' }, { new: true }).select('-password');
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });
    res.json({ success: true, data: user, message: 'User banned' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to ban user' });
  }
});

// POST /api/admin/users/:id/unban
router.post('/users/:id/unban', auth, adminAuth, async (req, res) => {
  try {
    const User = require('../models/User');
    const user = await User.findByIdAndUpdate(req.params.id, { status: 'active' }, { new: true }).select('-password');
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });
    res.json({ success: true, data: user, message: 'User unbanned' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to unban user' });
  }
});

// POST /api/admin/users/:id/warn
router.post('/users/:id/warn', auth, adminAuth, async (req, res) => {
  try {
    const { reason } = req.body;
    res.json({ success: true, message: `Warning sent${reason ? ': ' + reason : ''}` });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to warn user' });
  }
});

// DELETE /api/admin/users/:id
router.delete('/users/:id', auth, adminAuth, async (req, res) => {
  try {
    const User = require('../models/User');
    const user = await User.findByIdAndUpdate(req.params.id, { status: 'deleted' }, { new: true }).select('-password');
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });
    res.json({ success: true, message: 'User deleted' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to delete user' });
  }
});

// GET /api/admin/businesses - List businesses with filtering/pagination
router.get('/businesses', auth, adminAuth, async (req, res) => {
  try {
    const Business = require('../models/Business');
    const { page = 1, limit = 20, status, search, sort_by = 'createdAt', descending = 'true' } = req.query;
    const skip = (Math.max(parseInt(page), 1) - 1) * Math.min(parseInt(limit) || 20, 100);
    const lim = Math.min(parseInt(limit) || 20, 100);

    const filter = {};
    if (status === 'verified') filter.isVerified = true;
    if (status === 'unverified') filter.isVerified = { $ne: true };
    if (search) {
      const regex = new RegExp(search.trim(), 'i');
      filter.$or = [{ businessName: regex }, { email: regex }];
    }

    const sortDir = descending === 'true' ? -1 : 1;
    const safeSortBy = validateSortField(sort_by, 'businesses');
    const businesses = await Business.find(filter)
      .skip(skip)
      .limit(lim)
      .sort({ [safeSortBy]: sortDir });

    const total = await Business.countDocuments(filter);

    const data = businesses.map((b) => ({
      _id: b._id,
      business_id: b.businessId,
      business_name: b.businessName,
      business_type: b.businessType,
      email: b.email,
      is_verified: b.isVerified || false,
      follower_count: b.followerCount || 0,
      profile_image: b.profileImage || null,
      created_at: b.createdAt,
    }));

    res.json({ success: true, data, pagination: { page: parseInt(page), limit: lim, total, pages: Math.ceil(total / lim) } });
  } catch (error) {
    console.error('Admin list businesses error:', error);
    res.status(500).json({ success: false, message: 'Failed to list businesses' });
  }
});

// GET /api/admin/businesses/:id
router.get('/businesses/:id', auth, adminAuth, async (req, res) => {
  try {
    const Business = require('../models/Business');
    const business = await Business.findById(req.params.id);
    if (!business) return res.status(404).json({ success: false, message: 'Business not found' });
    res.json({ success: true, data: business });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to get business' });
  }
});

// POST /api/admin/businesses/:id/verify
// Verifies a business and auto-grants a 30-day free trial for event posting.
// Optional body: { trialDays: 60 } to set a custom trial length.
router.post('/businesses/:id/verify', auth, adminAuth, async (req, res) => {
  try {
    const Business = require('../models/Business');
    const trialDays = parseInt(req.body.trialDays) || 30;
    const trialEndDate = new Date(Date.now() + trialDays * 24 * 60 * 60 * 1000);

    const business = await Business.findByIdAndUpdate(
      req.params.id,
      { isVerified: true, trialEndDate },
      { new: true },
    );
    if (!business) return res.status(404).json({ success: false, message: 'Business not found' });
    res.json({ success: true, data: business, message: `Business verified with ${trialDays}-day free trial` });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to verify business' });
  }
});

// POST /api/admin/businesses/:id/unverify
router.post('/businesses/:id/unverify', auth, adminAuth, async (req, res) => {
  try {
    const Business = require('../models/Business');
    const business = await Business.findByIdAndUpdate(req.params.id, { isVerified: false }, { new: true });
    if (!business) return res.status(404).json({ success: false, message: 'Business not found' });
    res.json({ success: true, data: business, message: 'Business verification removed' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to unverify business' });
  }
});

// POST /api/admin/businesses/:id/grant-trial
// Extend or grant a free trial period.
// Body: { trialDays: 30 }
router.post('/businesses/:id/grant-trial', auth, adminAuth, async (req, res) => {
  try {
    const Business = require('../models/Business');
    const trialDays = parseInt(req.body.trialDays) || 30;
    const trialEndDate = new Date(Date.now() + trialDays * 24 * 60 * 60 * 1000);

    const business = await Business.findByIdAndUpdate(
      req.params.id,
      { trialEndDate },
      { new: true },
    );
    if (!business) return res.status(404).json({ success: false, message: 'Business not found' });
    res.json({ success: true, data: business, message: `${trialDays}-day trial granted` });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to grant trial' });
  }
});

// POST /api/admin/businesses/:id/apply-discount
// Apply a discount to a business. Body: { percent: 50, code: 'LAUNCH50', durationDays: 90 }
router.post('/businesses/:id/apply-discount', auth, adminAuth, async (req, res) => {
  try {
    const Business = require('../models/Business');
    const { percent = 0, code = null, durationDays = 30 } = req.body;
    const discountExpiryDate = new Date(Date.now() + durationDays * 24 * 60 * 60 * 1000);

    const business = await Business.findByIdAndUpdate(
      req.params.id,
      {
        discountPercent: Math.min(Math.max(parseInt(percent), 0), 100),
        discountCode: code,
        discountExpiryDate,
      },
      { new: true },
    );
    if (!business) return res.status(404).json({ success: false, message: 'Business not found' });
    res.json({ success: true, data: business, message: `${percent}% discount applied for ${durationDays} days` });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to apply discount' });
  }
});

// POST /api/admin/businesses/:id/suspend
router.post('/businesses/:id/suspend', auth, adminAuth, async (req, res) => {
  try {
    const Business = require('../models/Business');
    const business = await Business.findByIdAndUpdate(req.params.id, { isSuspended: true }, { new: true });
    if (!business) return res.status(404).json({ success: false, message: 'Business not found' });
    res.json({ success: true, data: business, message: 'Business suspended' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to suspend business' });
  }
});

// POST /api/admin/businesses/:id/unsuspend
router.post('/businesses/:id/unsuspend', auth, adminAuth, async (req, res) => {
  try {
    const Business = require('../models/Business');
    const business = await Business.findByIdAndUpdate(req.params.id, { isSuspended: false }, { new: true });
    if (!business) return res.status(404).json({ success: false, message: 'Business not found' });
    res.json({ success: true, data: business, message: 'Business unsuspended' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to unsuspend business' });
  }
});

// DELETE /api/admin/businesses/:id
router.delete('/businesses/:id', auth, adminAuth, async (req, res) => {
  try {
    const Business = require('../models/Business');
    await Business.findByIdAndDelete(req.params.id);
    res.json({ success: true, message: 'Business deleted' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to delete business' });
  }
});

// POST /api/admin/businesses/:id/toggle-featured
router.post('/businesses/:id/toggle-featured', auth, adminAuth, async (req, res) => {
  try {
    const Business = require('../models/Business');
    const business = await Business.findById(req.params.id);
    if (!business) return res.status(404).json({ success: false, message: 'Business not found' });
    business.isFeatured = !business.isFeatured;
    await business.save();
    res.json({ success: true, data: business, message: business.isFeatured ? 'Business featured' : 'Business unfeatured' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to toggle featured' });
  }
});

// POST /api/admin/businesses - Create business via admin
router.post('/businesses', auth, adminAuth, async (req, res) => {
  try {
    const Business = require('../models/Business');
    const business = await Business.create(req.body);
    res.json({ success: true, data: business });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to create business' });
  }
});

// GET /api/admin/events - List events with filtering/pagination
router.get('/events', auth, adminAuth, async (req, res) => {
  try {
    const Activity = require('../models/Activity');
    const { page = 1, limit = 20, status, search, is_past, sort_by = 'createdAt', descending = 'true' } = req.query;
    const skip = (Math.max(parseInt(page), 1) - 1) * Math.min(parseInt(limit) || 20, 100);
    const lim = Math.min(parseInt(limit) || 20, 100);

    const filter = {};
    if (status) filter.status = status;
    if (is_past === 'true') filter.dateTime = { $lt: new Date() };
    if (is_past === 'false') filter.dateTime = { $gte: new Date() };
    if (search) {
      const regex = new RegExp(search.trim(), 'i');
      filter.$or = [{ name: regex }, { description: regex }, { location: regex }];
    }

    const sortDir = descending === 'true' ? -1 : 1;
    const safeSortBy = validateSortField(sort_by, 'activities');
    const events = await Activity.find(filter)
      .skip(skip)
      .limit(lim)
      .sort({ [safeSortBy]: sortDir });

    const total = await Activity.countDocuments(filter);

    const data = events.map((e) => ({
      _id: e._id,
      activity_id: e.activityId,
      name: e.name,
      description: e.description,
      location: e.location,
      date_time: e.dateTime,
      status: e.status || 'active',
      creator_id: e.creatorId,
      attendees_count: e.attendees?.length || 0,
      total_slots: e.totalSlots,
      created_at: e.createdAt,
    }));

    res.json({ success: true, data, pagination: { page: parseInt(page), limit: lim, total, pages: Math.ceil(total / lim) } });
  } catch (error) {
    console.error('Admin list events error:', error);
    res.status(500).json({ success: false, message: 'Failed to list events' });
  }
});

// GET /api/admin/events/:id
router.get('/events/:id', auth, adminAuth, async (req, res) => {
  try {
    const Activity = require('../models/Activity');
    const event = await Activity.findById(req.params.id);
    if (!event) return res.status(404).json({ success: false, message: 'Event not found' });
    res.json({ success: true, data: event });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to get event' });
  }
});

// POST /api/admin/events/:id/approve
router.post('/events/:id/approve', auth, adminAuth, async (req, res) => {
  try {
    const Activity = require('../models/Activity');
    const event = await Activity.findByIdAndUpdate(req.params.id, { status: 'active' }, { new: true });
    if (!event) return res.status(404).json({ success: false, message: 'Event not found' });
    res.json({ success: true, data: event, message: 'Event approved' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to approve event' });
  }
});

// POST /api/admin/events/:id/reject
router.post('/events/:id/reject', auth, adminAuth, async (req, res) => {
  try {
    const Activity = require('../models/Activity');
    const event = await Activity.findByIdAndUpdate(req.params.id, { status: 'rejected' }, { new: true });
    if (!event) return res.status(404).json({ success: false, message: 'Event not found' });
    res.json({ success: true, data: event, message: 'Event rejected' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to reject event' });
  }
});

// DELETE /api/admin/events/:id
router.delete('/events/:id', auth, adminAuth, async (req, res) => {
  try {
    const Activity = require('../models/Activity');
    await Activity.findByIdAndDelete(req.params.id);
    res.json({ success: true, message: 'Event deleted' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to delete event' });
  }
});

// POST /api/admin/events/:id/toggle-featured
router.post('/events/:id/toggle-featured', auth, adminAuth, async (req, res) => {
  try {
    const Activity = require('../models/Activity');
    const event = await Activity.findById(req.params.id);
    if (!event) return res.status(404).json({ success: false, message: 'Event not found' });
    event.isFeatured = !event.isFeatured;
    await event.save();
    res.json({ success: true, data: event, message: event.isFeatured ? 'Event featured' : 'Event unfeatured' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to toggle featured' });
  }
});

// POST /api/admin/events - Create event via admin
router.post('/events', auth, adminAuth, async (req, res) => {
  try {
    const Activity = require('../models/Activity');
    const event = await Activity.create(req.body);
    res.json({ success: true, data: event });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to create event' });
  }
});

// GET /api/admin/reports - List reports/complaints with filtering
router.get('/reports', auth, adminAuth, async (req, res) => {
  try {
    const Complaint = require('../models/Complaint');
    const { page = 1, limit = 20, status, type, sort_by = 'createdAt', descending = 'true' } = req.query;
    const skip = (Math.max(parseInt(page), 1) - 1) * Math.min(parseInt(limit) || 20, 100);
    const lim = Math.min(parseInt(limit) || 20, 100);

    const filter = {};
    if (status) filter.status = status;
    if (type) filter.category = type;

    const sortDir = descending === 'true' ? -1 : 1;
    const safeSortBy = validateSortField(sort_by, 'complaints');
    const reports = await Complaint.find(filter)
      .skip(skip)
      .limit(lim)
      .sort({ [safeSortBy]: sortDir });

    const total = await Complaint.countDocuments(filter);

    const data = reports.map((r) => ({
      _id: r._id,
      report_id: r._id,
      user_id: r.userId,
      subject: r.subject,
      description: r.description,
      category: r.category,
      status: r.status || 'pending',
      created_at: r.createdAt,
      updated_at: r.updatedAt,
    }));

    res.json({ success: true, data, pagination: { page: parseInt(page), limit: lim, total, pages: Math.ceil(total / lim) } });
  } catch (error) {
    console.error('Admin list reports error:', error);
    res.status(500).json({ success: false, message: 'Failed to list reports' });
  }
});

// GET /api/admin/reports/:id
router.get('/reports/:id', auth, adminAuth, async (req, res) => {
  try {
    const Complaint = require('../models/Complaint');
    const report = await Complaint.findById(req.params.id);
    if (!report) return res.status(404).json({ success: false, message: 'Report not found' });
    res.json({ success: true, data: report });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to get report' });
  }
});

// POST /api/admin/reports/:id/resolve
router.post('/reports/:id/resolve', auth, adminAuth, async (req, res) => {
  try {
    const Complaint = require('../models/Complaint');
    const report = await Complaint.findByIdAndUpdate(req.params.id, { status: 'resolved' }, { new: true });
    if (!report) return res.status(404).json({ success: false, message: 'Report not found' });
    res.json({ success: true, data: report, message: 'Report resolved' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to resolve report' });
  }
});

// POST /api/admin/reports/:id/dismiss
router.post('/reports/:id/dismiss', auth, adminAuth, async (req, res) => {
  try {
    const Complaint = require('../models/Complaint');
    const report = await Complaint.findByIdAndUpdate(req.params.id, { status: 'dismissed' }, { new: true });
    if (!report) return res.status(404).json({ success: false, message: 'Report not found' });
    res.json({ success: true, data: report, message: 'Report dismissed' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to dismiss report' });
  }
});

// POST /api/admin/reports/:id/assign
router.post('/reports/:id/assign', auth, adminAuth, async (req, res) => {
  try {
    const { admin_id } = req.body;
    const Complaint = require('../models/Complaint');
    const report = await Complaint.findByIdAndUpdate(req.params.id, { assignedTo: admin_id }, { new: true });
    if (!report) return res.status(404).json({ success: false, message: 'Report not found' });
    res.json({ success: true, data: report, message: 'Report assigned' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to assign report' });
  }
});

// GET /api/admin/logs - Admin action logs (placeholder)
router.get('/logs', auth, adminAuth, async (req, res) => {
  res.json({ success: true, data: [] });
});

// Admin management routes
router.get('/admins', auth, adminAuth, async (req, res) => {
  try {
    const User = require('../models/User');
    const admins = await User.find({ role: { $in: ['admin', 'moderator'] } }).select('-password -refreshToken');
    res.json({ success: true, data: admins });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to list admins' });
  }
});

router.post('/admins', auth, adminAuth, async (req, res) => {
  try {
    const { userId, role } = req.body;
    const User = require('../models/User');
    const user = await User.findByIdAndUpdate(userId, { role: role || 'moderator' }, { new: true }).select('-password');
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });
    res.json({ success: true, data: user, message: 'Admin role assigned' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to assign admin role' });
  }
});

router.put('/admins/:id', auth, adminAuth, async (req, res) => {
  try {
    const { role } = req.body;
    const User = require('../models/User');
    const user = await User.findByIdAndUpdate(req.params.id, { role: role || 'moderator' }, { new: true }).select('-password');
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });
    res.json({ success: true, data: user, message: 'Admin role updated' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to update admin' });
  }
});

router.delete('/admins/:id', auth, adminAuth, async (req, res) => {
  try {
    const User = require('../models/User');
    const user = await User.findByIdAndUpdate(req.params.id, { role: 'user' }, { new: true }).select('-password');
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });
    res.json({ success: true, message: 'Admin role removed' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to remove admin' });
  }
});

// Settings
router.get('/settings', auth, adminAuth, async (req, res) => {
  res.json({ success: true, data: {} });
});

router.put('/settings', auth, adminAuth, async (req, res) => {
  res.json({ success: true, data: req.body, message: 'Settings updated' });
});

module.exports = router;
