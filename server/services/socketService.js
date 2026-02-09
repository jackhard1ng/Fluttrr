const { Server } = require('socket.io');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const config = require('../config/config');

let io;
const onlineUsers = new Map(); // userId -> socketId

const initSocket = (server) => {
  io = new Server(server, {
    cors: { origin: '*', methods: ['GET', 'POST'] },
    pingTimeout: 60000,
    pingInterval: 25000,
  });

  io.use((socket, next) => {
    const token = socket.handshake.auth.token || socket.handshake.query.token;
    if (!token) return next(new Error('Authentication required'));

    try {
      const decoded = jwt.verify(token, config.jwt.secret);
      socket.userId = decoded.userId;
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
      const { receiverId, content, imageUrl, type } = data;

      const message = {
        messageId: uuidv4(),
        senderId: userId,
        receiverId,
        content,
        imageUrl,
        type: type || 'text',
        timestamp: new Date().toISOString(),
      };

      // Send to receiver's room (handles single and multiple connections)
      io.to(`user_${receiverId}`).emit('new_message', message);
    });

    // Typing indicators
    socket.on('typing', (data) => {
      const { receiverId } = data;
      io.to(`user_${receiverId}`).emit('user_typing', { userId, receiverId });
    });

    socket.on('stop_typing', (data) => {
      const { receiverId } = data;
      io.to(`user_${receiverId}`).emit('user_stop_typing', { userId, receiverId });
    });

    // Join group/activity chat rooms
    socket.on('join_room', (data) => {
      const { roomId } = data;
      socket.join(roomId);
    });

    socket.on('leave_room', (data) => {
      const { roomId } = data;
      socket.leave(roomId);
    });

    // Group messages
    socket.on('group_message', (data) => {
      const { roomId, content, imageUrl, type } = data;
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
const isUserOnline = (userId) => onlineUsers.has(userId?.toString());
const getOnlineUsers = () => Array.from(onlineUsers.keys());

module.exports = { initSocket, getIO, isUserOnline, getOnlineUsers };
