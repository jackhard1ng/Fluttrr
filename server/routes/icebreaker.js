const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const Icebreaker = require('../models/Icebreaker');
const { v4: uuidv4 } = require('uuid');

// Seed defaults on first load
Icebreaker.seedDefaults().catch((err) => console.error('Icebreaker seed error:', err));

// GET /api/icebreaker/list
router.get('/list', auth, async (req, res) => {
  try {
    const { page = 1, limit = 20, type, category } = req.query;
    const pageNum = Math.max(parseInt(page) || 1, 1);
    const limitNum = Math.min(Math.max(parseInt(limit) || 20, 1), 100);

    const filter = {};
    if (type) filter.type = type;
    if (category) filter.category = category;

    const icebreakers = await Icebreaker.find(filter)
      .sort({ usageCount: -1, createdAt: -1 })
      .skip((pageNum - 1) * limitNum)
      .limit(limitNum);

    res.json({ success: true, data: icebreakers });
  } catch (error) {
    console.error('Get icebreakers error:', error);
    res.status(500).json({ success: false, message: 'Failed to get icebreakers' });
  }
});

// GET /api/icebreaker/random
router.get('/random', auth, async (req, res) => {
  try {
    const { category } = req.query;
    const match = category ? { category } : {};
    const results = await Icebreaker.aggregate([{ $match: match }, { $sample: { size: 1 } }]);

    if (results.length === 0) {
      return res.status(404).json({ success: false, message: 'No icebreakers found' });
    }

    // Apply toJSON-like transform for the aggregation result
    const ib = results[0];
    res.json({
      success: true,
      data: {
        icebreaker_id: ib.icebreakerId,
        question: ib.question,
        prompt: ib.prompt,
        type: ib.type,
        category: ib.category,
        options: ib.options || [],
        time_limit: ib.timeLimit,
        is_custom: ib.isCustom,
        creator_id: ib.creatorId,
        usage_count: ib.usageCount,
        rating: ib.rating,
      },
    });
  } catch (error) {
    console.error('Get random icebreaker error:', error);
    res.status(500).json({ success: false, message: 'Failed to get random icebreaker' });
  }
});

// POST /api/icebreaker/create
router.post('/create', auth, async (req, res) => {
  try {
    const { question, prompt, type, category, options, time_limit } = req.body;

    if (!question && !prompt) {
      return res.status(400).json({ success: false, message: 'question or prompt is required' });
    }

    // Validate inputs
    const validTypes = ['question', 'game', 'challenge', 'poll', 'wouldYouRather', 'twoTruthsOneLie', 'thisOrThat'];
    const validCategories = ['gettingToKnow', 'funAndSilly', 'deep', 'professional', 'creative', 'physical'];
    if (type && !validTypes.includes(type)) {
      return res.status(400).json({ success: false, message: 'Invalid icebreaker type' });
    }
    if (category && !validCategories.includes(category)) {
      return res.status(400).json({ success: false, message: 'Invalid category' });
    }
    if (options && (!Array.isArray(options) || options.length > 10)) {
      return res.status(400).json({ success: false, message: 'Options must be an array with max 10 items' });
    }
    const safeTimeLimit = parseInt(time_limit) || 60;
    if (safeTimeLimit < 10 || safeTimeLimit > 3600) {
      return res.status(400).json({ success: false, message: 'Time limit must be between 10 and 3600 seconds' });
    }

    const icebreaker = await Icebreaker.create({
      question: question || prompt,
      prompt: prompt || question,
      type: type || 'question',
      category: category || 'gettingToKnow',
      options: options || [],
      timeLimit: safeTimeLimit,
      isCustom: true,
      creatorId: req.user.userId,
    });

    res.json({ success: true, data: icebreaker });
  } catch (error) {
    console.error('Create icebreaker error:', error);
    res.status(500).json({ success: false, message: 'Failed to create icebreaker' });
  }
});

// Session routes - these return stub data for now since icebreaker sessions
// are real-time features that would typically use Socket.io
router.get('/session/:eventId', auth, async (req, res) => {
  res.json({
    success: true,
    data: {
      sessionId: null,
      eventId: req.params.eventId,
      currentIcebreaker: null,
      queue: [],
      responses: [],
      isActive: false,
      participantCount: 0,
    },
  });
});

router.post('/session/start', auth, async (req, res) => {
  const { event_id, count = 5 } = req.body;
  const safeCount = Math.min(Math.max(parseInt(count) || 5, 1), 20);

  const icebreakers = await Icebreaker.aggregate([{ $sample: { size: safeCount } }]);
  const queue = icebreakers.map((ib) => ({
    icebreaker_id: ib.icebreakerId,
    question: ib.question,
    prompt: ib.prompt,
    type: ib.type,
    category: ib.category,
    options: ib.options || [],
  }));

  res.json({
    success: true,
    data: {
      sessionId: uuidv4(),
      eventId: event_id,
      currentIcebreaker: queue[0] || null,
      queue,
      responses: [],
      isActive: true,
      startedAt: new Date(),
      participantCount: 1,
    },
  });
});

router.post('/respond', auth, async (req, res) => {
  const { icebreaker_id, event_id, answer, selected_option_index } = req.body;
  // Increment usage count for this icebreaker
  if (icebreaker_id) {
    await Icebreaker.findOneAndUpdate({ icebreakerId: icebreaker_id }, { $inc: { usageCount: 1 } }).catch(() => {});
  }
  res.json({
    success: true,
    data: {
      responseId: uuidv4(),
      icebreakerId: icebreaker_id,
      eventId: event_id,
      userId: req.user.userId,
      userName: req.user.userName,
      answer,
      selectedOptionIndex: selected_option_index,
      votes: [],
      respondedAt: new Date(),
      reactions: [],
    },
  });
});

router.get('/responses', auth, async (req, res) => {
  res.json({ success: true, data: [] });
});

router.post('/session/next', auth, async (req, res) => {
  res.json({ success: true, data: { sessionId: null, isActive: false } });
});

module.exports = router;
