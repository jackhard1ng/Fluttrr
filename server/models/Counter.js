const mongoose = require('mongoose');

const counterSchema = new mongoose.Schema({
  _id: { type: String, required: true },
  seq: { type: Number, default: 0 },
});

/**
 * Atomically increment and return the next sequence value.
 * Creates the counter document if it does not exist (upsert).
 * @param {string} name - Counter identifier (e.g. 'userId', 'activityId')
 * @returns {Promise<number>} Next sequence number
 */
counterSchema.statics.getNextSequence = async function (name) {
  const counter = await this.findByIdAndUpdate(
    name,
    { $inc: { seq: 1 } },
    { new: true, upsert: true }
  );
  return counter.seq;
};

module.exports = mongoose.model('Counter', counterSchema);
