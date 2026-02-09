const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const upload = require('../middleware/upload');
const { v4: uuidv4 } = require('uuid');

// GET /api/memory - placeholder for base route
router.get('/', auth, async (req, res) => {
  res.json({ success: true, data: [] });
});

// GET /api/memory/feed
router.get('/feed', auth, async (req, res) => {
  res.json({ success: true, data: [] });
});

// GET /api/memory/featured
router.get('/featured', auth, async (req, res) => {
  res.json({ success: true, data: [] });
});

// GET /api/memory/event/:eventId (note: mapped from /api/memory path)
router.get('/event', auth, async (req, res) => {
  res.json({ success: true, data: [] });
});

// GET /api/memory/my
router.get('/my', auth, async (req, res) => {
  res.json({ success: true, data: [] });
});

// GET /api/memory/mine
router.get('/mine', auth, async (req, res) => {
  res.json({ success: true, data: [] });
});

// GET /api/memory/events
router.get('/events', auth, async (req, res) => {
  res.json({ success: true, data: [] });
});

// GET /api/memory/tagged
router.get('/tagged', auth, async (req, res) => {
  res.json({ success: true, data: [] });
});

// GET /api/memory/tagged-in
router.get('/tagged-in', auth, async (req, res) => {
  res.json({ success: true, data: [] });
});

// POST /api/memory/upload - Upload memory with photos
router.post('/upload', auth, upload.array('photos', 10), async (req, res) => {
  try {
    const { event_id, caption } = req.body;
    const photos = (req.files || []).map((file) => ({
      photoId: uuidv4(),
      url: `/uploads/${file.filename}`,
      thumbnailUrl: `/uploads/${file.filename}`,
      width: 0,
      height: 0,
      description: '',
      tags: [],
      uploadedAt: new Date(),
    }));

    const memory = {
      memoryId: uuidv4(),
      eventId: event_id,
      eventName: '',
      uploaderId: req.user.userId,
      uploaderName: req.user.userName,
      uploaderAvatar: req.user.profile?.images?.[0] || '',
      photos,
      caption: caption || '',
      likeCount: 0,
      isLikedByMe: false,
      recentComments: [],
      commentCount: 0,
      createdAt: new Date(),
      eventDate: new Date(),
      isApproved: true,
      isFeatured: false,
    };

    res.json({ success: true, data: memory });
  } catch (error) {
    console.error('Upload memory error:', error);
    res.status(500).json({ message: 'Failed to upload memory' });
  }
});

// POST /api/memory - Create memory (alias)
router.post('/', auth, upload.array('photos', 10), async (req, res) => {
  try {
    const { event_id, caption } = req.body;
    const photos = (req.files || []).map((file) => ({
      photoId: uuidv4(),
      url: `/uploads/${file.filename}`,
      thumbnailUrl: `/uploads/${file.filename}`,
      width: 0,
      height: 0,
      tags: [],
      uploadedAt: new Date(),
    }));

    const memory = {
      memoryId: uuidv4(),
      eventId: event_id,
      eventName: '',
      uploaderId: req.user.userId,
      uploaderName: req.user.userName,
      photos,
      caption: caption || '',
      likeCount: 0,
      isLikedByMe: false,
      recentComments: [],
      commentCount: 0,
      createdAt: new Date(),
      eventDate: new Date(),
      isApproved: true,
      isFeatured: false,
    };

    res.json({ success: true, data: memory });
  } catch (error) {
    res.status(500).json({ message: 'Failed to create memory' });
  }
});

// Dynamic routes for specific memories
router.get('/:memoryId', auth, async (req, res) => {
  res.json({ success: true, data: null });
});

router.put('/:memoryId', auth, async (req, res) => {
  res.json({ success: true, data: null });
});

router.delete('/:memoryId', auth, async (req, res) => {
  res.json({ success: true });
});

router.post('/:memoryId/like', auth, async (req, res) => {
  res.json({ success: true, data: null });
});

router.delete('/:memoryId/like', auth, async (req, res) => {
  res.json({ success: true, data: null });
});

router.get('/:memoryId/comments', auth, async (req, res) => {
  res.json({ success: true, data: [] });
});

router.post('/:memoryId/comments', auth, async (req, res) => {
  const { content } = req.body;
  res.json({
    success: true,
    data: {
      commentId: uuidv4(),
      memoryId: req.params.memoryId,
      userId: req.user.userId.toString(),
      userName: req.user.userName,
      content,
      createdAt: new Date(),
      likeCount: 0,
      isLikedByMe: false,
    },
  });
});

router.post('/:memoryId/report', auth, async (req, res) => {
  res.json({ success: true });
});

module.exports = router;
