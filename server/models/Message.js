const mongoose = require('mongoose');

const messageSchema = new mongoose.Schema(
  {
    senderId: { type: Number, required: true, index: true },
    receiverId: { type: Number, required: true, index: true },
    senderName: String,
    content: { type: String, maxlength: 5000 },
    imageUrl: String,
    isRead: { type: Boolean, default: false },
    type: { type: String, enum: ['text', 'image', 'system'], default: 'text' },
    groupId: String,
  },
  { timestamps: true }
);

messageSchema.index({ senderId: 1, receiverId: 1, createdAt: -1 });
messageSchema.index({ groupId: 1, createdAt: -1 });

module.exports = mongoose.model('Message', messageSchema);
