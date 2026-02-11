const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const upload = require('../middleware/upload');
const Story = require('../models/Story');

// GET /api/story - Get all non-expired stories
router.get('/', auth, async (req, res) => {
  try {
    const now = new Date();
    const stories = await Story.find({ expiresAt: { $gt: now } })
      .sort({ createdAt: -1 })
      .limit(100);

    // Group by user and event
    const userStories = [];
    const eventStories = [];
    const seenUsers = new Set();
    const seenEvents = new Set();

    stories.forEach((s) => {
      const json = s.toJSON();
      json.is_viewed = (s.viewerIds || []).includes(String(req.user.userId));

      if (s.eventId && !seenEvents.has(s.eventId)) {
        seenEvents.add(s.eventId);
        eventStories.push(json);
      } else if (!s.eventId && !seenUsers.has(String(s.userId))) {
        seenUsers.add(String(s.userId));
        userStories.push(json);
      }
    });

    res.json({ success: true, data: { userStories, eventStories } });
  } catch (error) {
    console.error('Get stories error:', error);
    res.status(500).json({ success: false, message: 'Failed to get stories' });
  }
});

// GET /api/story/me - My stories
router.get('/me', auth, async (req, res) => {
  try {
    const stories = await Story.find({ userId: req.user.userId })
      .sort({ createdAt: -1 })
      .limit(50);
    res.json({ success: true, data: stories });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to get my stories' });
  }
});

// GET /api/story/event/:eventId
router.get('/event/:eventId', auth, async (req, res) => {
  try {
    const stories = await Story.find({
      eventId: req.params.eventId,
      expiresAt: { $gt: new Date() },
    }).sort({ createdAt: -1 });
    res.json({ success: true, data: stories });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to get event stories' });
  }
});

// GET /api/story/user/:userId
router.get('/user/:userId', auth, async (req, res) => {
  try {
    const stories = await Story.find({
      userId: parseInt(req.params.userId),
      expiresAt: { $gt: new Date() },
    }).sort({ createdAt: -1 });
    res.json({ success: true, data: stories });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to get user stories' });
  }
});

// POST /api/story - Create story
router.post('/', auth, upload.single('media'), async (req, res) => {
  try {
    const { type, event_id, caption } = req.body;
    const mediaUrl = req.file ? `/uploads/${req.file.filename}` : '';

    if (!mediaUrl && type !== 'text') {
      return res.status(400).json({ success: false, message: 'Media file is required' });
    }

    const story = await Story.create({
      userId: req.user.userId,
      userName: req.user.userName,
      userAvatar: req.user.profile?.images?.[0] || '',
      eventId: event_id || null,
      type: type || 'image',
      mediaUrl,
      thumbnailUrl: mediaUrl,
      caption: caption || '',
    });

    res.json({ success: true, data: story });
  } catch (error) {
    console.error('Create story error:', error);
    res.status(500).json({ success: false, message: 'Failed to create story' });
  }
});

// POST /api/story/:storyId/view
router.post('/:storyId/view', auth, async (req, res) => {
  try {
    const story = await Story.findOne({ storyId: req.params.storyId });
    if (!story) return res.status(404).json({ success: false, message: 'Story not found' });

    const viewerId = String(req.user.userId);
    if (!story.viewerIds.includes(viewerId)) {
      story.viewerIds.push(viewerId);
      story.viewCount = story.viewerIds.length;
      await story.save();
    }

    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to record view' });
  }
});

// POST /api/story/:storyId/react
router.post('/:storyId/react', auth, async (req, res) => {
  try {
    const { emoji } = req.body;
    if (!emoji) return res.status(400).json({ success: false, message: 'emoji is required' });

    const story = await Story.findOne({ storyId: req.params.storyId });
    if (!story) return res.status(404).json({ success: false, message: 'Story not found' });

    const alreadyReacted = story.reactions.some(
      (r) => String(r.userId) === String(req.user.userId) && r.emoji === emoji
    );
    if (alreadyReacted) {
      return res.status(400).json({ success: false, message: 'Already reacted with this emoji' });
    }

    story.reactions.push({
      userId: req.user.userId,
      userName: req.user.userName,
      userAvatar: req.user.profile?.images?.[0] || null,
      emoji,
    });
    await story.save();

    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to add reaction' });
  }
});

// DELETE /api/story/:storyId
router.delete('/:storyId', auth, async (req, res) => {
  try {
    const story = await Story.findOneAndDelete({
      storyId: req.params.storyId,
      userId: req.user.userId,
    });
    if (!story) return res.status(404).json({ success: false, message: 'Story not found or not yours' });
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to delete story' });
  }
});

// GET /api/story/:storyId/viewers
router.get('/:storyId/viewers', auth, async (req, res) => {
  try {
    const story = await Story.findOne({ storyId: req.params.storyId });
    if (!story) return res.status(404).json({ success: false, message: 'Story not found' });
    res.json({ success: true, data: story.viewerIds || [] });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to get viewers' });
  }
});

module.exports = router;
