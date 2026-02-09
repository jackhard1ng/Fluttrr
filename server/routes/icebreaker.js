const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const { v4: uuidv4 } = require('uuid');

// In-memory default icebreakers (will be seeded to DB later)
const defaultIcebreakers = [
  { question: "What's a hobby you've always wanted to try?", type: 'question', category: 'gettingToKnow' },
  { question: "If you could have dinner with anyone, who would it be?", type: 'question', category: 'funAndSilly' },
  { question: "What's the best trip you've ever taken?", type: 'question', category: 'gettingToKnow' },
  { question: "Would you rather travel to the past or the future?", type: 'wouldYouRather', category: 'funAndSilly', options: ['Past', 'Future'] },
  { question: "What's your go-to comfort food?", type: 'question', category: 'gettingToKnow' },
  { question: "Coffee or tea?", type: 'thisOrThat', category: 'funAndSilly', options: ['Coffee', 'Tea'] },
  { question: "What's a skill you're proud of?", type: 'question', category: 'gettingToKnow' },
  { question: "What's your favorite way to spend a weekend?", type: 'question', category: 'gettingToKnow' },
  { question: "Would you rather have the ability to fly or be invisible?", type: 'wouldYouRather', category: 'funAndSilly', options: ['Fly', 'Be invisible'] },
  { question: "What's something on your bucket list?", type: 'question', category: 'deep' },
];

// GET /api/icebreaker/list
router.get('/list', auth, async (req, res) => {
  try {
    const { page = 1, limit = 20, type, category } = req.query;
    let filtered = [...defaultIcebreakers];
    if (type) filtered = filtered.filter((i) => i.type === type);
    if (category) filtered = filtered.filter((i) => i.category === category);

    const data = filtered.slice(0, parseInt(limit)).map((ib, idx) => ({
      icebreakerId: `ib_${idx}`,
      question: ib.question,
      prompt: ib.question,
      type: ib.type,
      category: ib.category,
      options: ib.options || [],
      timeLimit: 60,
      isCustom: false,
      creatorId: null,
      usageCount: Math.floor(Math.random() * 100),
      rating: 4.0 + Math.random(),
    }));

    res.json({ success: true, data });
  } catch (error) {
    res.status(500).json({ message: 'Failed to get icebreakers' });
  }
});

// GET /api/icebreaker/random
router.get('/random', auth, async (req, res) => {
  try {
    const ib = defaultIcebreakers[Math.floor(Math.random() * defaultIcebreakers.length)];
    res.json({
      success: true,
      data: {
        icebreakerId: `ib_${uuidv4()}`,
        question: ib.question,
        prompt: ib.question,
        type: ib.type,
        category: ib.category,
        options: ib.options || [],
        timeLimit: 60,
        isCustom: false,
        usageCount: 0,
        rating: 4.5,
      },
    });
  } catch (error) {
    res.status(500).json({ message: 'Failed to get random icebreaker' });
  }
});

// POST /api/icebreaker/create
router.post('/create', auth, async (req, res) => {
  try {
    const { question, prompt, type, category, options, time_limit } = req.body;
    const icebreaker = {
      icebreakerId: uuidv4(),
      question: question || prompt,
      prompt: prompt || question,
      type: type || 'question',
      category: category || 'gettingToKnow',
      options: options || [],
      timeLimit: time_limit || 60,
      isCustom: true,
      creatorId: req.user.userId,
      usageCount: 0,
      rating: 0,
    };
    res.json({ success: true, data: icebreaker });
  } catch (error) {
    res.status(500).json({ message: 'Failed to create icebreaker' });
  }
});

// Session routes
router.get('/session/:eventId', auth, async (req, res) => {
  res.json({ success: true, data: { sessionId: null, eventId: req.params.eventId, currentIcebreaker: null, queue: [], responses: [], isActive: false, participantCount: 0 } });
});

router.post('/session/start', auth, async (req, res) => {
  const { event_id, count = 5 } = req.body;
  const queue = defaultIcebreakers.slice(0, count).map((ib, idx) => ({
    icebreakerId: `ib_${idx}`,
    question: ib.question,
    prompt: ib.question,
    type: ib.type,
    category: ib.category,
    options: ib.options || [],
  }));
  res.json({ success: true, data: { sessionId: uuidv4(), eventId: event_id, currentIcebreaker: queue[0] || null, queue, responses: [], isActive: true, startedAt: new Date(), participantCount: 1 } });
});

router.post('/respond', auth, async (req, res) => {
  const { icebreaker_id, event_id, answer, selected_option_index } = req.body;
  res.json({ success: true, data: { responseId: uuidv4(), icebreakerId: icebreaker_id, eventId: event_id, userId: req.user.userId, userName: req.user.userName, answer, selectedOptionIndex: selected_option_index, votes: [], respondedAt: new Date(), reactions: [] } });
});

router.get('/responses', auth, async (req, res) => {
  res.json({ success: true, data: [] });
});

router.post('/session/next', auth, async (req, res) => {
  res.json({ success: true, data: { sessionId: null, isActive: false } });
});

module.exports = router;
