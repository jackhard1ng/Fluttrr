const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');

// GET /api/mate/list_notifications
router.get('/list_notifications', auth, async (req, res) => {
  try {
    const Notification = require('../models/Notification');
    const notifications = await Notification.find({ userId: req.user.userId })
      .sort({ createdAt: -1 })
      .limit(50);

    const unreadCount = await Notification.countDocuments({
      userId: req.user.userId,
      isRead: false,
    });

    // Use toJSON() to get snake_case field names matching Flutter
    const data = notifications.map((n) => n.toJSON());

    res.json({ success: true, message: 'Notifications retrieved', data, unread_count: unreadCount, unreadCount });
  } catch (error) {
    console.error('Get notifications error:', error);
    res.status(500).json({ success: false, message: 'Failed to get notifications' });
  }
});

module.exports = router;
