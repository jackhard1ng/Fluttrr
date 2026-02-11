const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const upload = require('../middleware/upload');
const Memory = require('../models/Memory');

// GET /api/memory - List all memories
router.get('/', auth, async (req, res) => {
  try {
    const page = Math.max(parseInt(req.query.page) || 1, 1);
    const limit = Math.min(parseInt(req.query.limit) || 20, 100);
    const skip = (page - 1) * limit;

    const memories = await Memory.find({ isApproved: true })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const data = memories.map((m) => m.toApiResponse(req.user.userId));
    res.json({ success: true, data });
  } catch (error) {
    console.error('List memories error:', error);
    res.status(500).json({ success: false, message: 'Failed to get memories' });
  }
});

// GET /api/memory/feed - Memory feed
router.get('/feed', auth, async (req, res) => {
  try {
    const page = Math.max(parseInt(req.query.page) || 1, 1);
    const limit = Math.min(parseInt(req.query.limit) || 20, 100);
    const skip = (page - 1) * limit;

    const memories = await Memory.find({ isApproved: true })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const data = memories.map((m) => m.toApiResponse(req.user.userId));
    res.json({ success: true, data });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to get memory feed' });
  }
});

// GET /api/memory/featured
router.get('/featured', auth, async (req, res) => {
  try {
    const memories = await Memory.find({ isApproved: true, isFeatured: true })
      .sort({ createdAt: -1 })
      .limit(20);

    const data = memories.map((m) => m.toApiResponse(req.user.userId));
    res.json({ success: true, data });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to get featured memories' });
  }
});

// GET /api/memory/event?event_id=xxx
router.get('/event', auth, async (req, res) => {
  try {
    const eventId = req.query.event_id || req.query.eventId;
    const filter = { isApproved: true };
    if (eventId) filter.eventId = eventId;

    const memories = await Memory.find(filter).sort({ createdAt: -1 });
    const data = memories.map((m) => m.toApiResponse(req.user.userId));
    res.json({ success: true, data });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to get event memories' });
  }
});

// GET /api/memory/my - My uploaded memories
router.get('/my', auth, async (req, res) => {
  try {
    const memories = await Memory.find({ uploaderId: req.user.userId })
      .sort({ createdAt: -1 });
    const data = memories.map((m) => m.toApiResponse(req.user.userId));
    res.json({ success: true, data });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to get my memories' });
  }
});

// GET /api/memory/mine - Alias for /my
router.get('/mine', auth, async (req, res) => {
  try {
    const memories = await Memory.find({ uploaderId: req.user.userId })
      .sort({ createdAt: -1 });
    const data = memories.map((m) => m.toApiResponse(req.user.userId));
    res.json({ success: true, data });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to get my memories' });
  }
});

// GET /api/memory/events - Memories grouped by event
router.get('/events', auth, async (req, res) => {
  try {
    const memories = await Memory.find({ isApproved: true, eventId: { $ne: null } })
      .sort({ createdAt: -1 })
      .limit(50);
    const data = memories.map((m) => m.toApiResponse(req.user.userId));
    res.json({ success: true, data });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to get event memories' });
  }
});

// GET /api/memory/tagged - Memories where user is tagged
router.get('/tagged', auth, async (req, res) => {
  try {
    const memories = await Memory.find({
      'photos.tags.userId': String(req.user.userId),
    }).sort({ createdAt: -1 });
    const data = memories.map((m) => m.toApiResponse(req.user.userId));
    res.json({ success: true, data });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to get tagged memories' });
  }
});

// GET /api/memory/tagged-in - Alias for /tagged
router.get('/tagged-in', auth, async (req, res) => {
  try {
    const memories = await Memory.find({
      'photos.tags.userId': String(req.user.userId),
    }).sort({ createdAt: -1 });
    const data = memories.map((m) => m.toApiResponse(req.user.userId));
    res.json({ success: true, data });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to get tagged memories' });
  }
});

// POST /api/memory/upload - Upload memory with photos
router.post('/upload', auth, upload.array('photos', 10), async (req, res) => {
  try {
    const { event_id, caption } = req.body;
    const photos = (req.files || []).map((file) => ({
      url: `/uploads/${file.filename}`,
      thumbnailUrl: `/uploads/${file.filename}`,
      description: '',
      tags: [],
    }));

    const memory = await Memory.create({
      eventId: event_id || null,
      uploaderId: req.user.userId,
      uploaderName: req.user.userName,
      uploaderAvatar: req.user.profile?.images?.[0] || '',
      photos,
      caption: caption || '',
    });

    res.json({ success: true, data: memory.toApiResponse(req.user.userId) });
  } catch (error) {
    console.error('Upload memory error:', error);
    res.status(500).json({ success: false, message: 'Failed to upload memory' });
  }
});

// POST /api/memory - Create memory (alias for /upload)
router.post('/', auth, upload.array('photos', 10), async (req, res) => {
  try {
    const { event_id, caption } = req.body;
    const photos = (req.files || []).map((file) => ({
      url: `/uploads/${file.filename}`,
      thumbnailUrl: `/uploads/${file.filename}`,
      description: '',
      tags: [],
    }));

    const memory = await Memory.create({
      eventId: event_id || null,
      uploaderId: req.user.userId,
      uploaderName: req.user.userName,
      uploaderAvatar: req.user.profile?.images?.[0] || '',
      photos,
      caption: caption || '',
    });

    res.json({ success: true, data: memory.toApiResponse(req.user.userId) });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to create memory' });
  }
});

// GET /api/memory/:memoryId
router.get('/:memoryId', auth, async (req, res) => {
  try {
    const memory = await Memory.findOne({ memoryId: req.params.memoryId });
    if (!memory) return res.status(404).json({ success: false, message: 'Memory not found' });
    res.json({ success: true, data: memory.toApiResponse(req.user.userId) });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to get memory' });
  }
});

// PUT /api/memory/:memoryId
router.put('/:memoryId', auth, async (req, res) => {
  try {
    const { caption } = req.body;
    const memory = await Memory.findOneAndUpdate(
      { memoryId: req.params.memoryId, uploaderId: req.user.userId },
      { $set: { caption } },
      { new: true }
    );
    if (!memory) return res.status(404).json({ success: false, message: 'Memory not found or not yours' });
    res.json({ success: true, data: memory.toApiResponse(req.user.userId) });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to update memory' });
  }
});

// DELETE /api/memory/:memoryId
router.delete('/:memoryId', auth, async (req, res) => {
  try {
    const memory = await Memory.findOneAndDelete({
      memoryId: req.params.memoryId,
      uploaderId: req.user.userId,
    });
    if (!memory) return res.status(404).json({ success: false, message: 'Memory not found or not yours' });
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to delete memory' });
  }
});

// POST /api/memory/:memoryId/like (atomic to prevent race conditions)
router.post('/:memoryId/like', auth, async (req, res) => {
  try {
    const userIdStr = String(req.user.userId);

    // Atomic: only add if not already liked
    const memory = await Memory.findOneAndUpdate(
      { memoryId: req.params.memoryId, likedBy: { $ne: userIdStr } },
      { $addToSet: { likedBy: userIdStr }, $inc: { likeCount: 1 } },
      { new: true }
    );

    if (!memory) {
      // Either not found or already liked - check which
      const existing = await Memory.findOne({ memoryId: req.params.memoryId });
      if (!existing) return res.status(404).json({ success: false, message: 'Memory not found' });
      return res.json({ success: true, data: existing.toApiResponse(req.user.userId) });
    }

    res.json({ success: true, data: memory.toApiResponse(req.user.userId) });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to like memory' });
  }
});

// DELETE /api/memory/:memoryId/like (atomic to prevent race conditions)
router.delete('/:memoryId/like', auth, async (req, res) => {
  try {
    const userIdStr = String(req.user.userId);

    // Atomic: only remove if currently liked
    const memory = await Memory.findOneAndUpdate(
      { memoryId: req.params.memoryId, likedBy: userIdStr },
      { $pull: { likedBy: userIdStr }, $inc: { likeCount: -1 } },
      { new: true }
    );

    if (!memory) {
      const existing = await Memory.findOne({ memoryId: req.params.memoryId });
      if (!existing) return res.status(404).json({ success: false, message: 'Memory not found' });
      return res.json({ success: true, data: existing.toApiResponse(req.user.userId) });
    }

    res.json({ success: true, data: memory.toApiResponse(req.user.userId) });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to unlike memory' });
  }
});

// GET /api/memory/:memoryId/comments
router.get('/:memoryId/comments', auth, async (req, res) => {
  try {
    const memory = await Memory.findOne({ memoryId: req.params.memoryId });
    if (!memory) return res.status(404).json({ success: false, message: 'Memory not found' });
    res.json({ success: true, data: memory.comments || [] });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to get comments' });
  }
});

// POST /api/memory/:memoryId/comments (atomic to prevent race conditions)
router.post('/:memoryId/comments', auth, async (req, res) => {
  try {
    const { content } = req.body;
    if (!content) return res.status(400).json({ success: false, message: 'content is required' });

    const comment = {
      userId: String(req.user.userId),
      userName: req.user.userName,
      userAvatar: req.user.profile?.images?.[0] || '',
      content,
      createdAt: new Date(),
    };

    const memory = await Memory.findOneAndUpdate(
      { memoryId: req.params.memoryId },
      { $push: { comments: comment }, $inc: { commentCount: 1 } },
      { new: true }
    );

    if (!memory) return res.status(404).json({ success: false, message: 'Memory not found' });

    const saved = memory.comments[memory.comments.length - 1];
    res.json({ success: true, data: saved });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to add comment' });
  }
});

// POST /api/memory/:memoryId/report
router.post('/:memoryId/report', auth, async (req, res) => {
  try {
    const { reason } = req.body;
    const Complaint = require('../models/Complaint');
    await Complaint.create({
      userId: req.user.userId,
      subject: `Memory report: ${req.params.memoryId}`,
      description: reason || 'Reported by user',
      category: 'memory_report',
    });
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to report memory' });
  }
});

module.exports = router;
