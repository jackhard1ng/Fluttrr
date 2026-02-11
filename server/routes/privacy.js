const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');

// GET /api/privacy/getPrivacySettings
router.get('/getPrivacySettings', auth, async (req, res) => {
  try {
    const Privacy = require('../models/Privacy');
    let settings = await Privacy.findOne({ userId: req.user.userId });

    if (!settings) {
      settings = await Privacy.create({ userId: req.user.userId });
    }

    res.json({
      success: true,
      data: {
        showOnlineStatus: settings.showOnlineStatus,
        showLastSeen: settings.showLastSeen,
        showLocation: settings.showLocation,
        showAge: settings.showAge,
        showDistance: settings.showDistance,
        profileVisibility: settings.profileVisibility,
        allowMessages: settings.allowMessages,
        allowActivityInvites: settings.allowActivityInvites,
        showInNearby: settings.showInNearby,
        showInSearch: settings.showInSearch,
        pushEnabled: settings.pushEnabled,
        emailEnabled: settings.emailEnabled,
        newMatchNotifications: settings.newMatchNotifications,
        messageNotifications: settings.messageNotifications,
        activityNotifications: settings.activityNotifications,
        activityReminderNotifications: settings.activityReminderNotifications,
        likeNotifications: settings.likeNotifications,
        commentNotifications: settings.commentNotifications,
        marketingNotifications: settings.marketingNotifications,
      },
    });
  } catch (error) {
    console.error('Get privacy settings error:', error);
    res.status(500).json({ success: false, message: 'Failed to get privacy settings' });
  }
});

// POST /api/privacy/updatePrivacy
router.post('/updatePrivacy', auth, async (req, res) => {
  try {
    const Privacy = require('../models/Privacy');

    // Whitelist allowed fields to prevent NoSQL injection via arbitrary $set
    const allowedFields = [
      'showOnlineStatus', 'showLastSeen', 'showLocation', 'showAge',
      'showDistance', 'profileVisibility', 'allowMessages',
      'allowActivityInvites', 'showInNearby', 'showInSearch',
      'pushEnabled', 'emailEnabled', 'newMatchNotifications',
      'messageNotifications', 'activityNotifications',
      'activityReminderNotifications', 'likeNotifications',
      'commentNotifications', 'marketingNotifications',
    ];
    const update = {};
    for (const key of Object.keys(req.body)) {
      if (allowedFields.includes(key)) {
        update[key] = req.body[key];
      }
    }

    const settings = await Privacy.findOneAndUpdate(
      { userId: req.user.userId },
      { $set: update },
      { new: true, upsert: true }
    );

    res.json({ success: true, data: settings });
  } catch (error) {
    console.error('Update privacy settings error:', error);
    res.status(500).json({ success: false, message: 'Failed to update privacy settings' });
  }
});

// GET /api/privacy/profile
router.get('/profile', auth, async (req, res) => {
  try {
    const Privacy = require('../models/Privacy');
    let settings = await Privacy.findOne({ userId: req.user.userId });
    if (!settings) {
      settings = await Privacy.create({ userId: req.user.userId });
    }
    res.json({ success: true, data: settings });
  } catch (error) {
    console.error('Get privacy profile error:', error);
    res.status(500).json({ success: false, message: 'Failed to get privacy profile' });
  }
});

module.exports = router;
