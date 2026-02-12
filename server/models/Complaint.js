const mongoose = require('mongoose');

const complaintSchema = new mongoose.Schema(
  {
    userId: { type: Number, required: true },
    subject: { type: String, required: true },
    description: { type: String, required: true },
    category: {
      type: String,
      enum: ['abuse', 'spam', 'fraud', 'inappropriate_content', 'harassment', 'safety', 'other'],
      default: 'other',
    },
    status: {
      type: String,
      enum: ['pending', 'open', 'reviewing', 'resolved', 'dismissed'],
      default: 'pending',
    },
    assignedTo: { type: String, default: null },
  },
  { timestamps: true }
);

// Performance indexes for admin queries
complaintSchema.index({ userId: 1 });
complaintSchema.index({ status: 1, createdAt: -1 });

module.exports = mongoose.model('Complaint', complaintSchema);
