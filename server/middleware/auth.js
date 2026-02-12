const jwt = require('jsonwebtoken');
const config = require('../config/config');
const User = require('../models/User');

// Authenticate JWT token
const auth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ success: false, message: 'No token provided' });
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, config.jwt.secret, { algorithms: ['HS256'] });

    if (!decoded.userId) {
      return res.status(401).json({ success: false, message: 'Invalid token claims' });
    }

    const user = await User.findById(decoded.userId).select('-password');
    if (!user) {
      return res.status(401).json({ success: false, message: 'User not found' });
    }

    if (user.status === 'suspended' || user.status === 'banned' || user.status === 'deleted') {
      return res.status(403).json({ success: false, message: `Account ${user.status}` });
    }

    req.user = user;
    req.userId = user._id;
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ success: false, message: 'Token expired' });
    }
    return res.status(401).json({ success: false, message: 'Invalid token' });
  }
};

// Optional auth - doesn't fail if no token
const optionalAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.split(' ')[1];
      const decoded = jwt.verify(token, config.jwt.secret, { algorithms: ['HS256'] });
      if (!decoded.userId) return;
      const user = await User.findById(decoded.userId).select('-password');
      if (user) {
        req.user = user;
        req.userId = user._id;
      }
    }
  } catch (_) {
    // Ignore auth errors for optional auth
  }
  next();
};

// Generate tokens
const generateTokens = (userId) => {
  const token = jwt.sign({ userId }, config.jwt.secret, { expiresIn: config.jwt.expiresIn });
  const refreshToken = jwt.sign({ userId }, config.jwt.refreshSecret, { expiresIn: config.jwt.refreshExpiresIn });
  return { token, refreshToken };
};

module.exports = { auth, optionalAuth, generateTokens };
