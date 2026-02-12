const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const Message = require('../models/Message');
const User = require('../models/User');
const mongoose = require('mongoose');
const { isUserOnline } = require('../services/socketService');

// ============================================================
// POST /send - Send a message
// ============================================================
router.post('/send', auth, async (req, res) => {
  try {
    const { receiverId, content, imageUrl } = req.body;

    if (!receiverId || isNaN(parseInt(receiverId))) {
      return res.status(400).json({ success: false, message: 'receiverId must be a valid number' });
    }
    if (parseInt(receiverId) === req.user.userId) {
      return res.status(400).json({ success: false, message: 'Cannot send messages to yourself' });
    }
    if (!content && !imageUrl) {
      return res.status(400).json({ success: false, message: 'content or imageUrl is required' });
    }
    if (content && typeof content !== 'string') {
      return res.status(400).json({ success: false, message: 'content must be a string' });
    }
    if (content && content.length > 5000) {
      return res.status(400).json({ success: false, message: 'Message content exceeds 5000 character limit' });
    }

    // Verify receiver exists
    const receiver = await User.findOne({ userId: parseInt(receiverId), status: { $ne: 'deleted' } });
    if (!receiver) {
      return res.status(404).json({ success: false, message: 'Receiver not found' });
    }

    const message = new Message({
      senderId: req.user.userId,
      receiverId: parseInt(receiverId),
      senderName: req.user.userName || 'Unknown',
      content: content || '',
      imageUrl: imageUrl || '',
      type: imageUrl ? 'image' : 'text',
      isRead: false,
      isSent: true,
      timestamp: new Date(),
    });

    await message.save();

    const messageData = {
      messageId: message._id,
      senderId: message.senderId,
      receiverId: message.receiverId,
      senderName: message.senderName,
      content: message.content,
      imageUrl: message.imageUrl,
      timestamp: message.timestamp.toISOString(),
      isRead: message.isRead,
      isSent: message.isSent,
      type: message.type,
    };

    // Emit via Socket.io if receiver is online
    const io = req.app.get('io');
    if (io) {
      io.to(`user_${receiverId}`).emit('new_message', messageData);
    }

    res.json({ success: true, data: messageData });
  } catch (error) {
    console.error('Send message error:', error);
    res.status(500).json({ success: false, message: 'Failed to send message' });
  }
});

// ============================================================
// GET /chatlist - Get chat conversations
// ============================================================
router.get('/chatlist', auth, async (req, res) => {
  try {
    const userId = req.user.userId;

    // Aggregate messages to get last message per conversation partner
    const conversations = await Message.aggregate([
      {
        $match: {
          $or: [{ senderId: userId }, { receiverId: userId }],
          isGroup: { $ne: true },
        },
      },
      {
        // Determine the other user in the conversation
        $addFields: {
          otherUserId: {
            $cond: {
              if: { $eq: ['$senderId', userId] },
              then: '$receiverId',
              else: '$senderId',
            },
          },
        },
      },
      {
        $sort: { timestamp: -1 },
      },
      {
        // Group by other user to get last message per conversation
        // Count unread inline instead of collecting all messages (avoids unbounded memory)
        $group: {
          _id: '$otherUserId',
          lastMessage: { $first: '$content' },
          lastMessageTime: { $first: '$timestamp' },
          lastMessageType: { $first: '$type' },
          otherUserId: { $first: '$otherUserId' },
          otherUserName: { $first: '$senderName' },
          unreadCount: {
            $sum: {
              $cond: [
                { $and: [{ $eq: ['$receiverId', userId] }, { $eq: ['$isRead', false] }] },
                1,
                0,
              ],
            },
          },
        },
      },
      {
        $sort: { lastMessageTime: -1 },
      },
      {
        $limit: 100,
      },
      {
        $project: {
          _id: 0,
          conversationId: { $concat: [{ $toString: userId }, '_', { $toString: '$otherUserId' }] },
          otherUserId: 1,
          otherUserName: 1,
          otherUserImages: { $literal: [] },
          lastMessage: 1,
          lastMessageTime: 1,
          unreadCount: 1,
          isOnline: { $literal: false },
          isGroup: { $literal: false },
        },
      },
    ]);

    // Enrich with online status
    const data = conversations.map((conv) => ({
      ...conv,
      isOnline: isUserOnline(String(conv.otherUserId)),
    }));

    // Try to enrich with user info from the User model
    try {
      const User = require('../models/User');
      for (const conv of data) {
        const otherUser = await User.findOne({ userId: conv.otherUserId }).select(
          'userName profile.images'
        );
        if (otherUser) {
          conv.otherUserName = otherUser.userName || conv.otherUserName;
          conv.otherUserImages = otherUser.profile?.images || [];
        }
      }
    } catch (_) {
      // User model enrichment is optional; continue with aggregated data
    }

    res.json({ success: true, data });
  } catch (error) {
    console.error('Get chatlist error:', error);
    res.status(500).json({ success: false, message: 'Failed to get chat list' });
  }
});

// ============================================================
// GET /grouplist - Get group chats
// ============================================================
router.get('/grouplist', auth, async (req, res) => {
  try {
    const userId = req.user.userId;

    const groupConversations = await Message.aggregate([
      {
        $match: {
          isGroup: true,
          $or: [{ senderId: userId }, { groupMembers: userId }],
        },
      },
      {
        $sort: { timestamp: -1 },
      },
      {
        // Count unread inline instead of collecting all messages (avoids unbounded memory)
        $group: {
          _id: '$groupId',
          lastMessage: { $first: '$content' },
          lastMessageTime: { $first: '$timestamp' },
          groupName: { $first: '$groupName' },
          groupImage: { $first: '$groupImage' },
          unreadCount: {
            $sum: {
              $cond: [
                {
                  $and: [
                    { $ne: ['$senderId', userId] },
                    { $not: { $in: [userId, { $ifNull: ['$readBy', []] }] } },
                  ],
                },
                1,
                0,
              ],
            },
          },
        },
      },
      {
        $sort: { lastMessageTime: -1 },
      },
      {
        $limit: 100,
      },
      {
        $project: {
          _id: 0,
          conversationId: { $toString: '$_id' },
          groupId: '$_id',
          groupName: 1,
          groupImage: { $ifNull: ['$groupImage', ''] },
          lastMessage: 1,
          lastMessageTime: 1,
          unreadCount: 1,
          isGroup: { $literal: true },
        },
      },
    ]);

    res.json({ success: true, data: groupConversations });
  } catch (error) {
    console.error('Get group list error:', error);
    res.status(500).json({ success: false, message: 'Failed to get group list' });
  }
});

// ============================================================
// POST /markAsRead - Mark messages as read
// ============================================================
router.post('/markAsRead', auth, async (req, res) => {
  try {
    const { senderId } = req.body;

    if (!senderId || isNaN(parseInt(senderId))) {
      return res.status(400).json({ success: false, message: 'senderId must be a valid number' });
    }

    await Message.updateMany(
      {
        senderId: parseInt(senderId),
        receiverId: req.user.userId,
        isRead: false,
      },
      { $set: { isRead: true } }
    );

    // Notify sender via Socket.io that their messages were read
    const io = req.app.get('io');
    if (io) {
      io.to(`user_${senderId}`).emit('messages_read', {
        readBy: req.user.userId,
        senderId: parseInt(senderId),
      });
    }

    res.json({ success: true });
  } catch (error) {
    console.error('Mark as read error:', error);
    res.status(500).json({ success: false, message: 'Failed to mark messages as read' });
  }
});

// ============================================================
// GET /getChatList - Business chat list (same format as chatlist)
// ============================================================
router.get('/getChatList', auth, async (req, res) => {
  try {
    const userId = req.user.userId;

    const conversations = await Message.aggregate([
      {
        $match: {
          $or: [{ senderId: userId }, { receiverId: userId }],
          isBusiness: true,
        },
      },
      {
        $addFields: {
          otherUserId: {
            $cond: {
              if: { $eq: ['$senderId', userId] },
              then: '$receiverId',
              else: '$senderId',
            },
          },
        },
      },
      {
        $sort: { timestamp: -1 },
      },
      {
        // Count unread inline instead of collecting all messages (avoids unbounded memory)
        $group: {
          _id: '$otherUserId',
          lastMessage: { $first: '$content' },
          lastMessageTime: { $first: '$timestamp' },
          otherUserId: { $first: '$otherUserId' },
          otherUserName: { $first: '$senderName' },
          unreadCount: {
            $sum: {
              $cond: [
                { $and: [{ $eq: ['$receiverId', userId] }, { $eq: ['$isRead', false] }] },
                1,
                0,
              ],
            },
          },
        },
      },
      {
        $sort: { lastMessageTime: -1 },
      },
      {
        $project: {
          _id: 0,
          conversationId: { $concat: ['business_', { $toString: userId }, '_', { $toString: '$otherUserId' }] },
          otherUserId: 1,
          otherUserName: 1,
          otherUserImages: { $literal: [] },
          lastMessage: 1,
          lastMessageTime: 1,
          unreadCount: 1,
          isOnline: { $literal: false },
          isGroup: { $literal: false },
        },
      },
    ]);

    // Enrich with online status
    const data = conversations.map((conv) => ({
      ...conv,
      isOnline: isUserOnline(String(conv.otherUserId)),
    }));

    res.json({ success: true, data });
  } catch (error) {
    console.error('Get business chat list error:', error);
    res.status(500).json({ success: false, message: 'Failed to get business chat list' });
  }
});

// ============================================================
// POST /sendB - Send business message
// ============================================================
router.post('/sendB', auth, async (req, res) => {
  try {
    const { businessId, content, imageUrl } = req.body;

    if (!businessId || isNaN(parseInt(businessId))) {
      return res.status(400).json({ success: false, message: 'businessId must be a valid number' });
    }
    if (!content && !imageUrl) {
      return res.status(400).json({ success: false, message: 'content or imageUrl is required' });
    }
    if (content && typeof content !== 'string') {
      return res.status(400).json({ success: false, message: 'content must be a string' });
    }
    if (content && content.length > 5000) {
      return res.status(400).json({ success: false, message: 'Message content exceeds 5000 character limit' });
    }

    // Verify business receiver exists
    const Business = require('../models/Business');
    const business = await Business.findOne({ businessId: parseInt(businessId) });
    if (!business) {
      return res.status(404).json({ success: false, message: 'Business not found' });
    }

    const message = new Message({
      senderId: req.user.userId,
      receiverId: parseInt(businessId),
      senderName: req.user.userName || 'Unknown',
      content: content || '',
      imageUrl: imageUrl || '',
      type: imageUrl ? 'image' : 'text',
      isRead: false,
      isSent: true,
      isBusiness: true,
      timestamp: new Date(),
    });

    await message.save();

    const messageData = {
      messageId: message._id,
      senderId: message.senderId,
      receiverId: message.receiverId,
      senderName: message.senderName,
      content: message.content,
      imageUrl: message.imageUrl,
      timestamp: message.timestamp.toISOString(),
      isRead: message.isRead,
      isSent: message.isSent,
      type: message.type,
    };

    // Emit via Socket.io if receiver is online
    const io = req.app.get('io');
    if (io) {
      io.to(`user_${businessId}`).emit('new_message', messageData);
    }

    res.json({ success: true, data: messageData });
  } catch (error) {
    console.error('Send business message error:', error);
    res.status(500).json({ success: false, message: 'Failed to send business message' });
  }
});

module.exports = router;
