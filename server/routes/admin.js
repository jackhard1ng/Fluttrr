const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');

// Admin auth middleware - check if user is admin
const adminAuth = async (req, res, next) => {
  if (!req.user || req.user.role !== 'admin') {
    return res.status(403).json({ message: 'Admin access required' });
  }
  next();
};

// POST /api/admin/complain - Submit complaint (available to all authenticated users)
router.post('/complain', auth, async (req, res) => {
  try {
    const { subject, description, category } = req.body;
    const Complaint = require('../models/Complaint');

    const complaint = await Complaint.create({
      userId: req.user.numericId,
      subject,
      description,
      category,
    });

    res.json({ success: true, message: 'Complaint submitted', data: complaint });
  } catch (error) {
    console.error('Submit complaint error:', error);
    res.status(500).json({ message: 'Failed to submit complaint' });
  }
});

// GET /api/admin/status
router.get('/status', auth, async (req, res) => {
  try {
    res.json({
      success: true,
      data: {
        adminId: req.user._id,
        userId: req.user._id.toString(),
        email: req.user.email,
        name: req.user.userName,
        role: req.user.role || 'user',
        permissions: [],
        isActive: true,
      },
    });
  } catch (error) {
    res.status(500).json({ message: 'Failed to get admin status' });
  }
});

// GET /api/admin/stats
router.get('/stats', auth, adminAuth, async (req, res) => {
  try {
    const User = require('../models/User');
    const Activity = require('../models/Activity');

    const totalUsers = await User.countDocuments();
    const activeUsers = await User.countDocuments({ onlineStatus: 'online' });
    const totalEvents = await Activity.countDocuments();

    res.json({
      success: true,
      data: {
        totalUsers,
        activeUsers,
        newUsersToday: 0,
        newUsersThisWeek: 0,
        totalBusinesses: 0,
        verifiedBusinesses: 0,
        pendingVerifications: 0,
        totalEvents,
        activeEvents: 0,
        eventsToday: 0,
        pendingReports: 0,
        resolvedReportsToday: 0,
        totalRevenue: 0,
        revenueThisMonth: 0,
      },
    });
  } catch (error) {
    res.status(500).json({ message: 'Failed to get stats' });
  }
});

// Placeholder admin routes
const placeholderRoutes = [
  { method: 'get', path: '/logs' },
  { method: 'get', path: '/businesses' },
  { method: 'get', path: '/businesses/:id' },
  { method: 'post', path: '/businesses/:id/verify' },
  { method: 'post', path: '/businesses/:id/suspend' },
  { method: 'post', path: '/businesses/:id/unsuspend' },
  { method: 'delete', path: '/businesses/:id' },
  { method: 'post', path: '/businesses/:id/toggle-featured' },
  { method: 'post', path: '/businesses' },
  { method: 'get', path: '/events' },
  { method: 'get', path: '/events/:id' },
  { method: 'post', path: '/events/:id/approve' },
  { method: 'post', path: '/events/:id/reject' },
  { method: 'delete', path: '/events/:id' },
  { method: 'post', path: '/events/:id/toggle-featured' },
  { method: 'post', path: '/events' },
  { method: 'get', path: '/users' },
  { method: 'get', path: '/users/:id' },
  { method: 'post', path: '/users/:id/suspend' },
  { method: 'post', path: '/users/:id/unsuspend' },
  { method: 'post', path: '/users/:id/ban' },
  { method: 'post', path: '/users/:id/unban' },
  { method: 'post', path: '/users/:id/warn' },
  { method: 'delete', path: '/users/:id' },
  { method: 'get', path: '/reports' },
  { method: 'get', path: '/reports/:id' },
  { method: 'post', path: '/reports/:id/assign' },
  { method: 'post', path: '/reports/:id/resolve' },
  { method: 'post', path: '/reports/:id/dismiss' },
  { method: 'get', path: '/admins' },
  { method: 'post', path: '/admins' },
  { method: 'put', path: '/admins/:id' },
  { method: 'delete', path: '/admins/:id' },
  { method: 'get', path: '/settings' },
  { method: 'put', path: '/settings' },
];

placeholderRoutes.forEach(({ method, path: routePath }) => {
  router[method](routePath, auth, adminAuth, async (req, res) => {
    res.json({ success: true, data: [], message: 'Admin endpoint placeholder' });
  });
});

module.exports = router;
