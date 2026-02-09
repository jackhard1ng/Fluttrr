const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');

// GET /api/mate/list_notifications
router.get('/list_notifications', auth, async (req, res) => {
  try {
    const Notification = require('../models/Notification');
    const notifications = await Notification.find({ userId: req.user.numericId })
      .sort({ createdAt: -1 })
      .limit(50);

    const unreadCount = await Notification.countDocuments({
      userId: req.user.numericId,
      isRead: false,
    });

    const data = notifications.map((n) => ({
      notificationId: n.notificationId,
      title: n.title,
      body: n.body,
      type: n.type,
      senderId: n.senderId,
      senderName: n.senderName,
      senderImage: n.senderImage,
      relatedId: n.relatedId,
      relatedType: n.relatedType,
      createdAt: n.createdAt,
      isRead: n.isRead,
    }));

    res.json({ success: true, message: 'Notifications retrieved', data, unreadCount });
  } catch (error) {
    console.error('Get notifications error:', error);
    res.status(500).json({ message: 'Failed to get notifications' });
  }
});

module.exports = router;
