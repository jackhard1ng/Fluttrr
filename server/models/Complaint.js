const mongoose = require('mongoose');

const complaintSchema = new mongoose.Schema({
  userId: { type: Number, required: true },
  subject: { type: String, required: true },
  description: { type: String, required: true },
  category: String,
  status: { type: String, enum: ['pending', 'reviewing', 'resolved'], default: 'pending' },
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Complaint', complaintSchema);
