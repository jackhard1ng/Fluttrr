const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');

// ---------------------------------------------------------------------------
// Icebreaker schema
// ---------------------------------------------------------------------------
// Flutter IcebreakerModel.fromJson reads (snake_case):
//   icebreaker_id, question, prompt, type, category,
//   options, time_limit, is_custom, creator_id, usage_count, rating

const icebreakerSchema = new mongoose.Schema({
  icebreakerId: { type: String, default: uuidv4, unique: true, index: true },
  question: { type: String, default: null },
  prompt: { type: String, default: null },
  type: {
    type: String,
    enum: ['question', 'game', 'challenge', 'poll', 'wouldYouRather', 'twoTruthsOneLie', 'thisOrThat'],
    default: 'question',
  },
  category: {
    type: String,
    enum: ['gettingToKnow', 'funAndSilly', 'deep', 'professional', 'creative', 'physical'],
    default: 'gettingToKnow',
  },
  options: { type: [String], default: [] },
  timeLimit: { type: Number, default: null, min: 0 },
  isCustom: { type: Boolean, default: false },
  creatorId: { type: Number, default: null, index: true },
  usageCount: { type: Number, default: 0, min: 0 },
  rating: { type: Number, default: 0, min: 0, max: 5 },
  createdAt: { type: Date, default: Date.now },
});

// ---------------------------------------------------------------------------
// Indexes
// ---------------------------------------------------------------------------
icebreakerSchema.index({ type: 1, category: 1 });
icebreakerSchema.index({ isCustom: 1 });
icebreakerSchema.index({ usageCount: -1 });

// ---------------------------------------------------------------------------
// toJSON – convert to snake_case matching Flutter IcebreakerModel.fromJson
// ---------------------------------------------------------------------------
icebreakerSchema.set('toJSON', {
  transform: function (doc, ret) {
    return {
      icebreaker_id: ret.icebreakerId,
      question: ret.question,
      prompt: ret.prompt,
      type: ret.type,
      category: ret.category,
      options: ret.options,
      time_limit: ret.timeLimit,
      is_custom: ret.isCustom,
      creator_id: ret.creatorId,
      usage_count: ret.usageCount,
      rating: ret.rating,
      created_at: ret.createdAt,
    };
  },
});

// ---------------------------------------------------------------------------
// Static: seed default icebreakers
// ---------------------------------------------------------------------------
icebreakerSchema.statics.seedDefaults = async function () {
  var Icebreaker = this;
  var count = await Icebreaker.countDocuments({ isCustom: false });
  if (count > 0) return;

  var defaults = [
    // Getting to Know
    { question: 'What\'s one thing you\'re passionate about that might surprise people?', type: 'question', category: 'gettingToKnow' },
    { question: 'If you could have dinner with anyone, dead or alive, who would it be?', type: 'question', category: 'gettingToKnow' },
    { question: 'What\'s your go-to karaoke song?', type: 'question', category: 'gettingToKnow' },
    { question: 'What\'s the best trip you\'ve ever taken?', type: 'question', category: 'gettingToKnow' },
    { question: 'What\'s your hidden talent?', type: 'question', category: 'gettingToKnow' },
    // Would You Rather
    { question: 'Would you rather travel back in time or into the future?', type: 'wouldYouRather', category: 'funAndSilly', options: ['Back in time', 'Into the future'] },
    { question: 'Would you rather have unlimited money or unlimited time?', type: 'wouldYouRather', category: 'deep', options: ['Unlimited money', 'Unlimited time'] },
    { question: 'Would you rather be able to fly or be invisible?', type: 'wouldYouRather', category: 'funAndSilly', options: ['Fly', 'Be invisible'] },
    // This or That
    { question: 'Morning person or night owl?', type: 'thisOrThat', category: 'gettingToKnow', options: ['Morning person', 'Night owl'] },
    { question: 'Coffee or tea?', type: 'thisOrThat', category: 'gettingToKnow', options: ['Coffee', 'Tea'] },
    { question: 'Beach or mountains?', type: 'thisOrThat', category: 'gettingToKnow', options: ['Beach', 'Mountains'] },
    { question: 'Books or movies?', type: 'thisOrThat', category: 'gettingToKnow', options: ['Books', 'Movies'] },
    // Challenges
    { prompt: 'Introduce yourself in exactly 10 words', type: 'challenge', category: 'creative', timeLimit: 60 },
    { prompt: 'Share your best dad joke', type: 'challenge', category: 'funAndSilly' },
    { prompt: 'Describe your ideal weekend in one sentence', type: 'challenge', category: 'gettingToKnow' },
  ];

  await Icebreaker.insertMany(defaults);
};

module.exports = mongoose.model('Icebreaker', icebreakerSchema);
