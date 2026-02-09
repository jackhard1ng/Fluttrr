const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');

// ---------------------------------------------------------------------------
// Message schema
// ---------------------------------------------------------------------------
// Flutter ChatMessage.fromJson reads (snake_case with camelCase fallback):
//   message_id, sender_id, receiver_id, sender_name, content,
//   image_url, timestamp, is_read, type, groupId

const messageSchema = new mongoose.Schema(
  {
    messageId: { type: String, default: uuidv4, unique: true, index: true },
    senderId: { type: Number, required: true, index: true },
    receiverId: { type: Number, default: null, index: true },
    senderName: { type: String, default: null },
    content: { type: String, maxlength: 5000, default: null },
    imageUrl: { type: String, default: null },
    timestamp: { type: Date, default: Date.now, index: true },
    isRead: { type: Boolean, default: false },
    type: {
      type: String,
      enum: ['text', 'image', 'system'],
      default: 'text',
    },
    groupId: { type: String, default: null, index: true },
  },
  { timestamps: false }
);

// ---------------------------------------------------------------------------
// Indexes
// ---------------------------------------------------------------------------
messageSchema.index({ senderId: 1, receiverId: 1, timestamp: -1 });
messageSchema.index({ groupId: 1, timestamp: -1 });
messageSchema.index({ receiverId: 1, isRead: 1 });

// ---------------------------------------------------------------------------
// toJSON – convert to snake_case matching Flutter ChatMessage.fromJson
// ---------------------------------------------------------------------------
messageSchema.set('toJSON', {
  transform: function (doc, ret) {
    return {
      message_id: ret.messageId,
      sender_id: ret.senderId,
      receiver_id: ret.receiverId,
      sender_name: ret.senderName,
      content: ret.content,
      image_url: ret.imageUrl,
      timestamp: ret.timestamp,
      is_read: ret.isRead,
      type: ret.type,
      group_id: ret.groupId,
    };
  },
});

module.exports = mongoose.model('Message', messageSchema);
