const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const config = require('../config/config');
const User = require('../models/User');
const Otp = require('../models/Otp');
const { auth, generateTokens } = require('../middleware/auth');
const crypto = require('crypto');
const { sendOtpEmail } = require('../services/emailService');

// ============================================================
// Helper: generate a cryptographically secure 6-digit OTP
// ============================================================
const generateOtp = () => String(crypto.randomInt(100000, 999999));

// ============================================================
// POST /login
// Email / password login (no auth required)
// ============================================================
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ success: false, message: 'Email and password are required' });
    }

    const user = await User.findOne({ email: email.toLowerCase().trim() }).select('+password');
    if (!user) {
      return res.status(401).json({ success: false, message: 'Invalid email or password' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ success: false, message: 'Invalid email or password' });
    }

    if (user.status === 'suspended' || user.status === 'banned') {
      return res.status(403).json({ success: false, message: `Account ${user.status}` });
    }

    // Update online status
    user.onlineStatus = 'online';
    user.lastSeen = new Date();

    const tokens = generateTokens(user._id);

    // Store refresh token in DB for validation/revocation
    user.refreshToken = tokens.refreshToken;
    await user.save();

    // Determine whether profile setup is still needed
    const requiresProfileSetup = !user.profile || !user.profile.gender;

    return res.json({
      success: true,
      message: 'Login successful',
      token: tokens.token,
      refreshToken: tokens.refreshToken,
      userId: user.userId,
      isNewUser: false,
      requiresProfileSetup,
    });
  } catch (error) {
    console.error('Login error:', error);
    return res.status(500).json({ success: false, message: 'Server error during login' });
  }
});

// ============================================================
// POST /send-otp
// Registration step 1 – send OTP (no auth required)
// ============================================================
router.post('/send-otp', async (req, res) => {
  try {
    const { userName, email, password } = req.body;

    if (!userName || !email || !password) {
      return res.status(400).json({ success: false, message: 'userName, email and password are required' });
    }

    // Validate password strength
    if (typeof password !== 'string' || password.length < 6) {
      return res.status(400).json({ success: false, message: 'Password must be at least 6 characters' });
    }

    // Validate userName
    if (typeof userName !== 'string' || userName.trim().length < 2 || userName.trim().length > 30) {
      return res.status(400).json({ success: false, message: 'Username must be 2-30 characters' });
    }

    // Validate email format
    if (typeof email !== 'string' || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.trim())) {
      return res.status(400).json({ success: false, message: 'Invalid email format' });
    }

    const normalizedEmail = email.toLowerCase().trim();

    // Check if the email is already registered
    const existingUser = await User.findOne({ email: normalizedEmail });
    if (existingUser) {
      return res.status(409).json({ success: false, message: 'Email is already registered' });
    }

    // Pre-hash the password before storing it in the temporary OTP record.
    // The pre-save hook on User model detects bcrypt hashes and skips re-hashing.
    const hashedPassword = await bcrypt.hash(password, 12);

    const otp = generateOtp();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    // Upsert: create or replace existing OTP record for this email
    // Preserve attempts counter across re-requests to prevent brute-force bypass
    const existingOtp = await Otp.findOne({ email: normalizedEmail, type: 'registration' });
    const carriedAttempts = existingOtp ? (existingOtp.attempts || 0) : 0;

    await Otp.findOneAndUpdate(
      { email: normalizedEmail },
      {
        email: normalizedEmail,
        otp,
        type: 'registration',
        expiresAt,
        attempts: carriedAttempts,
        // Store temporary registration data alongside the OTP
        userData: {
          userName,
          password: hashedPassword,
        },
      },
      { upsert: true, new: true },
    );

    // Send OTP email
    await sendOtpEmail(normalizedEmail, otp, 'verification');

    return res.json({ success: true, message: 'OTP sent' });
  } catch (error) {
    console.error('Send OTP error:', error);
    return res.status(500).json({ success: false, message: 'Server error while sending OTP' });
  }
});

// ============================================================
// POST /verify-otp
// Registration step 2 – verify OTP and create account (no auth)
// ============================================================
router.post('/verify-otp', async (req, res) => {
  try {
    const { email, otp } = req.body;

    if (!email || !otp) {
      return res.status(400).json({ success: false, message: 'Email and OTP are required' });
    }
    if (typeof otp !== 'string' || !/^\d{4,6}$/.test(otp.trim())) {
      return res.status(400).json({ success: false, message: 'OTP must be 4-6 digits' });
    }

    const normalizedEmail = email.toLowerCase().trim();

    const otpRecord = await Otp.findOne({
      email: normalizedEmail,
      type: 'registration',
    });

    if (!otpRecord) {
      return res.status(400).json({ success: false, message: 'No OTP found. Please request a new one' });
    }

    if (otpRecord.expiresAt < new Date()) {
      await Otp.deleteOne({ _id: otpRecord._id });
      return res.status(400).json({ success: false, message: 'OTP has expired. Please request a new one' });
    }

    if (otpRecord.otp !== otp.toString()) {
      // Increment attempts and delete OTP if max reached
      otpRecord.attempts = (otpRecord.attempts || 0) + 1;
      if (otpRecord.attempts >= 5) {
        await Otp.deleteOne({ _id: otpRecord._id });
        return res.status(429).json({ success: false, message: 'Too many failed attempts. Please request a new OTP' });
      }
      await otpRecord.save();
      return res.status(400).json({ success: false, message: 'Invalid OTP' });
    }

    // OTP is valid – create the user from stored registration data
    const { userName, password } = otpRecord.userData || {};

    if (!userName || !password) {
      return res.status(400).json({ success: false, message: 'Registration data missing. Please restart registration' });
    }

    // userId is auto-assigned by the pre-save hook via Counter model
    const user = await User.create({
      userName,
      email: normalizedEmail,
      password,
      onlineStatus: 'online',
      accountType: 'regular',
    });

    // Clean up the OTP record
    await Otp.deleteOne({ _id: otpRecord._id });

    const tokens = generateTokens(user._id);

    // Store refresh token in DB for validation/revocation
    user.refreshToken = tokens.refreshToken;
    await user.save();

    return res.json({
      success: true,
      message: 'Account created successfully',
      token: tokens.token,
      refreshToken: tokens.refreshToken,
      userId: user.userId,
      isNewUser: true,
      requiresProfileSetup: true,
    });
  } catch (error) {
    console.error('Verify OTP error:', error);
    return res.status(500).json({ success: false, message: 'Server error during OTP verification' });
  }
});

// ============================================================
// POST /google-login
// Google sign-in (no auth required)
// ============================================================
router.post('/google-login', async (req, res) => {
  try {
    const { idToken } = req.body;

    if (!idToken) {
      return res.status(400).json({ success: false, message: 'idToken is required' });
    }

    // Decode and verify the Google ID token.
    // We verify the JWT signature using Google's public keys to prevent forgery.
    let googlePayload;
    try {
      const { OAuth2Client } = require('google-auth-library');
      const client = new OAuth2Client(config.google.clientId);
      const ticket = await client.verifyIdToken({
        idToken,
        audience: config.google.clientId,
      });
      googlePayload = ticket.getPayload();
    } catch (verifyErr) {
      console.error('Google token verification failed:', verifyErr.message);
      return res.status(401).json({ success: false, message: 'Invalid Google token' });
    }

    const googleEmail = googlePayload?.email;
    const googleName = googlePayload?.name || googlePayload?.given_name || 'User';

    if (!googleEmail) {
      return res.status(400).json({ success: false, message: 'Could not extract email from Google token' });
    }

    // Verify that Google has confirmed the email address
    if (!googlePayload.email_verified) {
      return res.status(400).json({ success: false, message: 'Google email is not verified' });
    }

    const normalizedEmail = googleEmail.toLowerCase().trim();

    // Try to find an existing user by email
    let user = await User.findOne({ email: normalizedEmail });
    let isNewUser = false;

    if (!user) {
      // Create a new account for this Google user
      // userId is auto-assigned by the pre-save hook via Counter model
      user = await User.create({
        userName: googleName,
        email: normalizedEmail,
        password: crypto.randomBytes(32).toString('hex'),
        googleId: googlePayload?.sub || null,
        onlineStatus: 'online',
        accountType: 'regular',
      });
      isNewUser = true;
    } else {
      if (user.status === 'suspended' || user.status === 'banned' || user.status === 'deleted') {
        return res.status(403).json({ success: false, message: `Account ${user.status}` });
      }
      user.onlineStatus = 'online';
      user.lastSeen = new Date();
      await user.save();
    }

    const tokens = generateTokens(user._id);

    // Store refresh token in DB for validation/revocation
    user.refreshToken = tokens.refreshToken;
    await user.save();

    const requiresProfileSetup = !user.profile || !user.profile.gender;

    return res.json({
      success: true,
      message: isNewUser ? 'Account created with Google' : 'Login successful',
      token: tokens.token,
      refreshToken: tokens.refreshToken,
      userId: user.userId,
      isNewUser,
      requiresProfileSetup,
    });
  } catch (error) {
    console.error('Google login error:', error);
    return res.status(500).json({ success: false, message: 'Server error during Google login' });
  }
});

// ============================================================
// POST /request-otp
// Password reset step 1 – send OTP to email (no auth required)
// ============================================================
router.post('/request-otp', async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ success: false, message: 'Email is required' });
    }

    const normalizedEmail = email.toLowerCase().trim();

    const user = await User.findOne({ email: normalizedEmail });
    if (!user) {
      // For security, still return success so we don't reveal if account exists
      return res.json({ success: true, message: 'If the email is registered, an OTP has been sent' });
    }

    const otp = generateOtp();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    // Preserve attempts counter across re-requests to prevent brute-force bypass
    const existingResetOtp = await Otp.findOne({ email: normalizedEmail, type: 'passwordReset' });
    const carriedResetAttempts = existingResetOtp ? (existingResetOtp.attempts || 0) : 0;

    await Otp.findOneAndUpdate(
      { email: normalizedEmail, type: 'passwordReset' },
      {
        email: normalizedEmail,
        otp,
        type: 'passwordReset',
        expiresAt,
        attempts: carriedResetAttempts,
      },
      { upsert: true, new: true },
    );

    await sendOtpEmail(normalizedEmail, otp, 'passwordReset');

    return res.json({ success: true, message: 'If the email is registered, an OTP has been sent' });
  } catch (error) {
    console.error('Request OTP error:', error);
    return res.status(500).json({ success: false, message: 'Server error while requesting OTP' });
  }
});

// ============================================================
// POST /verify-reset-otp
// Password reset step 2 – verify OTP, return temporary reset token
// ============================================================
router.post('/verify-reset-otp', async (req, res) => {
  try {
    const { email, otp } = req.body;

    if (!email || !otp) {
      return res.status(400).json({ success: false, message: 'Email and OTP are required' });
    }
    if (typeof otp !== 'string' || !/^\d{4,6}$/.test(otp.trim())) {
      return res.status(400).json({ success: false, message: 'OTP must be 4-6 digits' });
    }

    const normalizedEmail = email.toLowerCase().trim();

    const otpRecord = await Otp.findOne({
      email: normalizedEmail,
      type: 'passwordReset',
    });

    if (!otpRecord) {
      return res.status(400).json({ success: false, message: 'No OTP found. Please request a new one' });
    }

    if (otpRecord.expiresAt < new Date()) {
      await Otp.deleteOne({ _id: otpRecord._id });
      return res.status(400).json({ success: false, message: 'OTP has expired. Please request a new one' });
    }

    if (otpRecord.otp !== otp.toString()) {
      // Increment attempts and delete OTP if max reached
      otpRecord.attempts = (otpRecord.attempts || 0) + 1;
      if (otpRecord.attempts >= 5) {
        await Otp.deleteOne({ _id: otpRecord._id });
        return res.status(429).json({ success: false, message: 'Too many failed attempts. Please request a new OTP' });
      }
      await otpRecord.save();
      return res.status(400).json({ success: false, message: 'Invalid OTP' });
    }

    // Generate a short-lived reset token (15 minutes)
    const resetToken = jwt.sign(
      { email: normalizedEmail, purpose: 'password-reset' },
      config.jwt.secret,
      { expiresIn: '15m' },
    );

    // Clean up the OTP record
    await Otp.deleteOne({ _id: otpRecord._id });

    return res.json({
      success: true,
      message: 'OTP verified successfully',
      resetToken,
    });
  } catch (error) {
    console.error('Verify reset OTP error:', error);
    return res.status(500).json({ success: false, message: 'Server error during OTP verification' });
  }
});

// ============================================================
// POST /reset-password
// Password reset step 3 – set new password using resetToken or email
// ============================================================
router.post('/reset-password', async (req, res) => {
  try {
    const { newPassword, confirmPassword, resetToken, email } = req.body;

    if (!newPassword || !confirmPassword) {
      return res.status(400).json({ success: false, message: 'newPassword and confirmPassword are required' });
    }

    if (newPassword !== confirmPassword) {
      return res.status(400).json({ success: false, message: 'Passwords do not match' });
    }

    if (newPassword.length < 6) {
      return res.status(400).json({ success: false, message: 'Password must be at least 6 characters' });
    }

    let targetEmail;

    // Only allow password reset with a valid reset token (OTP-verified)
    if (!resetToken) {
      return res.status(400).json({ success: false, message: 'Reset token is required' });
    }

    try {
      const decoded = jwt.verify(resetToken, config.jwt.secret);
      if (decoded.purpose !== 'password-reset') {
        return res.status(400).json({ success: false, message: 'Invalid reset token' });
      }
      targetEmail = decoded.email;
    } catch (_) {
      return res.status(400).json({ success: false, message: 'Reset token is invalid or expired' });
    }

    const user = await User.findOne({ email: targetEmail }).select('+password');
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    // Set plain password - the pre-save hook will hash it
    user.password = newPassword;
    await user.save();

    return res.json({ success: true, message: 'Password reset successfully' });
  } catch (error) {
    console.error('Reset password error:', error);
    return res.status(500).json({ success: false, message: 'Server error during password reset' });
  }
});

// ============================================================
// POST /change-password
// Change password for logged-in user (requires auth)
// ============================================================
router.post('/change-password', auth, async (req, res) => {
  try {
    const { oldPassword, newPassword } = req.body;

    if (!oldPassword || !newPassword) {
      return res.status(400).json({ success: false, message: 'oldPassword and newPassword are required' });
    }

    if (newPassword.length < 6) {
      return res.status(400).json({ success: false, message: 'New password must be at least 6 characters' });
    }

    // Fetch user with password field (normally excluded by select('-password'))
    const user = await User.findById(req.userId).select('+password');
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const isMatch = await bcrypt.compare(oldPassword, user.password);
    if (!isMatch) {
      return res.status(401).json({ success: false, message: 'Current password is incorrect' });
    }

    // Set plain password - the pre-save hook will hash it
    user.password = newPassword;
    // Invalidate refresh token so all existing sessions are revoked
    user.refreshToken = null;
    await user.save();

    return res.json({ success: true, message: 'Password changed successfully' });
  } catch (error) {
    console.error('Change password error:', error);
    return res.status(500).json({ success: false, message: 'Server error during password change' });
  }
});

// ============================================================
// POST /refresh-token
// Refresh JWT tokens (no auth required – uses refresh token)
// ============================================================
router.post('/refresh-token', async (req, res) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({ success: false, message: 'refreshToken is required' });
    }

    let decoded;
    try {
      decoded = jwt.verify(refreshToken, config.jwt.refreshSecret);
    } catch (err) {
      if (err.name === 'TokenExpiredError') {
        return res.status(401).json({ success: false, message: 'Refresh token expired. Please login again' });
      }
      return res.status(401).json({ success: false, message: 'Invalid refresh token' });
    }

    // Verify that the user still exists and is in good standing
    const user = await User.findById(decoded.userId).select('+refreshToken');
    if (!user) {
      return res.status(401).json({ success: false, message: 'User not found' });
    }

    // Validate the refresh token matches the one stored in DB
    if (!user.refreshToken || user.refreshToken !== refreshToken) {
      return res.status(401).json({ success: false, message: 'Refresh token has been revoked' });
    }

    if (user.status === 'suspended' || user.status === 'banned' || user.status === 'deleted') {
      return res.status(403).json({ success: false, message: `Account ${user.status}` });
    }

    const tokens = generateTokens(user._id);

    // Persist the new refresh token so the old one is invalidated
    user.refreshToken = tokens.refreshToken;
    await user.save();

    return res.json({
      success: true,
      token: tokens.token,
      refreshToken: tokens.refreshToken,
    });
  } catch (error) {
    console.error('Refresh token error:', error);
    return res.status(500).json({ success: false, message: 'Server error during token refresh' });
  }
});

module.exports = router;
