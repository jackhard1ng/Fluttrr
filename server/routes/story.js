const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const upload = require('../middleware/upload');
const { v4: uuidv4 } = require('uuid');

// GET /api/story - Get all stories
router.get('/', auth, async (req, res) => {
  try {
    res.json({
      success: true,
      data: {
        userStories: [],
        eventStories: [],
      },
    });
  } catch (error) {
    res.status(500).json({ message: 'Failed to get stories' });
  }
});

// GET /api/story/me - My stories
router.get('/me', auth, async (req, res) => {
  res.json({ success: true, data: [] });
});

// GET /api/story/event/:eventId
router.get('/event/:eventId', auth, async (req, res) => {
  res.json({ success: true, data: [] });
});

// GET /api/story/user/:userId
router.get('/user/:userId', auth, async (req, res) => {
  res.json({ success: true, data: [] });
});

// POST /api/story - Create story
router.post('/', auth, upload.single('media'), async (req, res) => {
  try {
    const { type, event_id, caption } = req.body;
    const mediaUrl = req.file ? `/uploads/${req.file.filename}` : '';

    const story = {
      storyId: uuidv4(),
      userId: req.user.userId.toString(),
      userName: req.user.userName,
      userAvatar: req.user.profile?.images?.[0] || '',
      eventId: event_id || null,
      eventName: null,
      type: type || 'image',
      mediaUrl,
      thumbnailUrl: mediaUrl,
      caption: caption || '',
      createdAt: new Date(),
      expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000),
      viewCount: 0,
      viewerIds: [],
      isViewed: false,
      reactions: [],
    };

    res.json({ success: true, data: story });
  } catch (error) {
    res.status(500).json({ message: 'Failed to create story' });
  }
});

// POST /api/story/:storyId/view
router.post('/:storyId/view', auth, async (req, res) => {
  res.json({ success: true });
});

// POST /api/story/:storyId/react
router.post('/:storyId/react', auth, async (req, res) => {
  res.json({ success: true });
});

// DELETE /api/story/:storyId
router.delete('/:storyId', auth, async (req, res) => {
  res.json({ success: true });
});

// GET /api/story/:storyId/viewers
router.get('/:storyId/viewers', auth, async (req, res) => {
  res.json({ success: true, data: [] });
});

module.exports = router;
