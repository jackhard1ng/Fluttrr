const { Server } = require('socket.io');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const config = require('../config/config');
const User = require('../models/User');

let io;
const onlineUsers = new Map(); // numeric userId -> socketId

const initSocket = (server) => {
  io = new Server(server, {
    cors: {
      origin: function (origin, callback) {
        // Allow requests with no origin (mobile apps, curl, etc.)
        if (!origin) return callback(null, true);
        const allowedOrigins = (process.env.CORS_ORIGINS || 'https://fluttrr.com,https://www.fluttrr.com,https://api.fluttrr.com').split(',');
        if (allowedOrigins.includes(origin)) return callback(null, true);
        callback(new Error('Origin not allowed by CORS'));
      },
      methods: ['GET', 'POST'],
      credentials: true,
    },
    pingTimeout: 60000,
    pingInterval: 25000,
  });

  io.use(async (socket, next) => {
    const token = socket.handshake.auth.token || socket.handshake.query.token;
    if (!token) return next(new Error('Authentication required'));

    try {
      const decoded = jwt.verify(token, config.jwt.secret);
      // decoded.userId is MongoDB _id; resolve to numeric userId for room naming
      const user = await User.findById(decoded.userId).select('userId status');
      if (!user) return next(new Error('User not found'));
      if (user.status === 'suspended' || user.status === 'banned' || user.status === 'deleted') {
        return next(new Error(`Account ${user.status}`));
      }
      socket.userId = user.userId; // Use numeric userId for consistent room naming
      next();
    } catch (err) {
      next(new Error('Invalid token'));
    }
  });

  io.on('connection', (socket) => {
    const userId = socket.userId;
    onlineUsers.set(userId, socket.id);
    console.log(`User connected: ${userId}`);

    // Broadcast online status
    socket.broadcast.emit('user_online', { userId });

    // Join personal room
    socket.join(`user_${userId}`);

    // Handle sending messages
    socket.on('send_message', (data) => {
      if (!data || typeof data !== 'object') return;
      const { receiverId, content, imageUrl, type } = data;

      // Validate receiverId
      if (receiverId == null || (typeof receiverId !== 'number' && typeof receiverId !== 'string')) return;
      const numReceiverId = typeof receiverId === 'string' ? parseInt(receiverId) : receiverId;
      if (isNaN(numReceiverId) || numReceiverId === userId) return;

      // Validate content
      if (!content && !imageUrl) return;
      if (content && (typeof content !== 'string' || content.length > 5000)) return;
      if (imageUrl && (typeof imageUrl !== 'string' || imageUrl.length > 2000)) return;

      // Validate type
      const allowedTypes = ['text', 'image', 'audio', 'video', 'file'];
      const msgType = allowedTypes.includes(type) ? type : 'text';

      const message = {
        messageId: uuidv4(),
        senderId: userId,
        receiverId: numReceiverId,
        content: content ? content.trim() : content,
        imageUrl,
        type: msgType,
        timestamp: new Date().toISOString(),
      };

      // Send to receiver's room (handles single and multiple connections)
      io.to(`user_${numReceiverId}`).emit('new_message', message);
    });

    // Typing indicators
    socket.on('typing', (data) => {
      if (!data || typeof data !== 'object') return;
      const { receiverId } = data;
      if (receiverId == null || (typeof receiverId !== 'number' && typeof receiverId !== 'string')) return;
      const numReceiverId = typeof receiverId === 'string' ? parseInt(receiverId) : receiverId;
      if (isNaN(numReceiverId) || numReceiverId === userId) return;
      io.to(`user_${numReceiverId}`).emit('user_typing', { userId, receiverId: numReceiverId });
    });

    socket.on('stop_typing', (data) => {
      if (!data || typeof data !== 'object') return;
      const { receiverId } = data;
      if (receiverId == null || (typeof receiverId !== 'number' && typeof receiverId !== 'string')) return;
      const numReceiverId = typeof receiverId === 'string' ? parseInt(receiverId) : receiverId;
      if (isNaN(numReceiverId) || numReceiverId === userId) return;
      io.to(`user_${numReceiverId}`).emit('user_stop_typing', { userId, receiverId: numReceiverId });
    });

    // Join group/activity chat rooms (with membership validation)
    socket.on('join_room', async (data) => {
      const { roomId } = data;
      if (!roomId || typeof roomId !== 'string' || roomId.length > 200) return;

      // Validate membership: check if user has sent/received messages in this group
      try {
        const Message = require('../models/Message');
        const isMember = await Message.exists({
          groupId: roomId,
          $or: [
            { senderId: userId },
            { groupMembers: userId },
          ],
        });
        if (!isMember) {
          socket.emit('error', { message: 'Not a member of this group' });
          return;
        }
      } catch (_) {
        // Fail-closed: deny join on error (only allow user's own room)
        if (roomId !== `user_${userId}`) return;
      }

      socket.join(roomId);
    });

    socket.on('leave_room', (data) => {
      const { roomId } = data;
      if (!roomId || typeof roomId !== 'string') return;
      socket.leave(roomId);
    });

    // Group messages (with membership check)
    socket.on('group_message', async (data) => {
      const { roomId, content, imageUrl, type } = data;
      if (!roomId || typeof roomId !== 'string' || roomId.length > 200) return;
      if (!content && !imageUrl) return;

      // Verify sender is in the room before broadcasting
      if (!socket.rooms.has(roomId)) {
        socket.emit('error', { message: 'Must join room before sending messages' });
        return;
      }

      const message = {
        messageId: uuidv4(),
        senderId: userId,
        roomId,
        content,
        imageUrl,
        type: type || 'text',
        timestamp: new Date().toISOString(),
      };
      socket.to(roomId).emit('new_group_message', message);
    });

    socket.on('disconnect', () => {
      onlineUsers.delete(userId);
      socket.broadcast.emit('user_offline', { userId });
      console.log(`User disconnected: ${userId}`);
    });
  });

  return io;
};

const getIO = () => io;
const isUserOnline = (userId) => {
  if (userId == null) return false;
  const numId = typeof userId === 'string' ? parseInt(userId) : userId;
  return onlineUsers.has(numId);
};
const getOnlineUsers = () => Array.from(onlineUsers.keys());

module.exports = { initSocket, getIO, isUserOnline, getOnlineUsers };
