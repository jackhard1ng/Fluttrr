const express = require('express');
const router = express.Router();
const User = require('../models/User');
const Activity = require('../models/Activity');
const { auth } = require('../middleware/auth');
const upload = require('../middleware/upload');

// ============================================================
// Helper: format a user document into the shape the Flutter app expects
// (matches UserModel / Profile / ActivityStats in user_model.dart)
// ============================================================
const formatUserForClient = (user) => {
  return {
    userId: user.userId,
    userName: user.userName,
    email: user.email,
    onlineStatus: user.onlineStatus || 'offline',
    profile: {
      age: user.profile?.age || null,
      gender: user.profile?.gender || null,
      bio: user.profile?.bio || null,
      interests: user.profile?.interests || [],
      images: user.profile?.images || [],
      location: user.profile?.location || null,
      coverImage: user.profile?.coverImage || [],
      Language: user.profile?.Language || [],
      latitude: user.profile?.latitude || null,
      longitude: user.profile?.longitude || null,
    },
    activities: {
      created: user.activities?.created || 0,
      joined: user.activities?.joined || 0,
    },
    completionPercentage: user.completionPercentage || 0,
    accountType: user.accountType || 'regular',
    businessName: user.businessName || null,
    isLowProfile: user.isLowProfile || false,
    phoneVerification: user.phoneVerification
      ? {
          phone_number: user.phoneVerification.phone_number || null,
          country_code: user.phoneVerification.country_code || null,
          status: user.phoneVerification.status || 'unverified',
          verified_at: user.phoneVerification.verified_at || null,
          otp_sent_at: user.phoneVerification.otp_sent_at || null,
          otp_attempts: user.phoneVerification.otp_attempts || 0,
        }
      : null,
    averageRating: user.averageRating || 0,
    totalRatings: user.totalRatings || 0,
    followedBusinessIds: user.followedBusinessIds || [],
  };
};

// ============================================================
// Helper: calculate profile completion percentage
// ============================================================
const calculateCompletionPercentage = (user) => {
  const checks = [
    !!user.userName,
    !!user.email,
    !!user.profile?.age,
    !!user.profile?.gender,
    !!user.profile?.bio,
    !!(user.profile?.interests && user.profile.interests.length > 0),
    !!(user.profile?.images && user.profile.images.length > 0),
    !!user.profile?.location,
    !!(user.profile?.Language && user.profile.Language.length > 0),
    !!(user.phoneVerification && user.phoneVerification.status === 'verified'),
  ];

  const completed = checks.filter(Boolean).length;
  return Math.round((completed / checks.length) * 100);
};

// ============================================================
// GET /profile
// Get current user's profile (requires auth)
// ============================================================
router.get('/profile', auth, async (req, res) => {
  try {
    const user = await User.findById(req.userId);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    return res.json({
      success: true,
      data: formatUserForClient(user),
    });
  } catch (error) {
    console.error('Get profile error:', error);
    return res.status(500).json({ success: false, message: 'Server error fetching profile' });
  }
});

// ============================================================
// POST /create-profile
// Create profile after registration (requires auth)
// ============================================================
router.post('/create-profile', auth, async (req, res) => {
  try {
    const { age, gender, bio, interests, location, latitude, longitude } = req.body;

    const user = await User.findById(req.userId);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    // Initialise profile sub-document if it doesn't exist
    if (!user.profile) {
      user.profile = {};
    }

    if (age !== undefined) user.profile.age = age;
    if (gender !== undefined) user.profile.gender = gender;
    if (bio !== undefined) user.profile.bio = bio;
    if (interests !== undefined) user.profile.interests = interests;
    if (location !== undefined) user.profile.location = location;
    if (latitude !== undefined) user.profile.latitude = latitude;
    if (longitude !== undefined) user.profile.longitude = longitude;

    // Recalculate completion
    user.completionPercentage = calculateCompletionPercentage(user);

    await user.save();

    return res.json({ success: true, message: 'Profile created successfully' });
  } catch (error) {
    console.error('Create profile error:', error);
    return res.status(500).json({ success: false, message: 'Server error creating profile' });
  }
});

// ============================================================
// PUT /update
// Update profile (requires auth)
// Note: Flutter sends "Language" (capital L) for languages
// ============================================================
router.put('/update', auth, async (req, res) => {
  try {
    const { userName, age, gender, bio, interests, location, Language } = req.body;

    const user = await User.findById(req.userId);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    if (!user.profile) {
      user.profile = {};
    }

    if (userName !== undefined) user.userName = userName;
    if (age !== undefined) user.profile.age = age;
    if (gender !== undefined) user.profile.gender = gender;
    if (bio !== undefined) user.profile.bio = bio;
    if (interests !== undefined) user.profile.interests = interests;
    if (location !== undefined) user.profile.location = location;
    if (Language !== undefined) user.profile.Language = Language;

    user.completionPercentage = calculateCompletionPercentage(user);

    await user.save();

    return res.json({
      success: true,
      data: formatUserForClient(user),
    });
  } catch (error) {
    console.error('Update profile error:', error);
    return res.status(500).json({ success: false, message: 'Server error updating profile' });
  }
});

// ============================================================
// POST /update-location
// Update user's location (requires auth)
// ============================================================
router.post('/update-location', auth, async (req, res) => {
  try {
    const { latitude, longitude, location } = req.body;

    const user = await User.findById(req.userId);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    if (!user.profile) {
      user.profile = {};
    }

    if (latitude !== undefined) user.profile.latitude = latitude;
    if (longitude !== undefined) user.profile.longitude = longitude;
    if (location !== undefined) user.profile.location = location;

    await user.save();

    return res.json({ success: true });
  } catch (error) {
    console.error('Update location error:', error);
    return res.status(500).json({ success: false, message: 'Server error updating location' });
  }
});

// ============================================================
// POST /token
// Update FCM push notification token (requires auth)
// ============================================================
router.post('/token', auth, async (req, res) => {
  try {
    const { token } = req.body;

    await User.findByIdAndUpdate(req.userId, { fcmToken: token });

    return res.json({ success: true });
  } catch (error) {
    console.error('Update FCM token error:', error);
    return res.status(500).json({ success: false, message: 'Server error updating token' });
  }
});

// ============================================================
// POST /online
// Set user online (requires auth)
// ============================================================
router.post('/online', auth, async (req, res) => {
  try {
    await User.findByIdAndUpdate(req.userId, {
      onlineStatus: 'online',
      lastSeen: new Date(),
    });

    return res.json({ success: true });
  } catch (error) {
    console.error('Set online error:', error);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// ============================================================
// POST /offline
// Set user offline (requires auth)
// ============================================================
router.post('/offline', auth, async (req, res) => {
  try {
    await User.findByIdAndUpdate(req.userId, {
      onlineStatus: 'offline',
      lastSeen: new Date(),
    });

    return res.json({ success: true });
  } catch (error) {
    console.error('Set offline error:', error);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// ============================================================
// POST /low-profile
// Toggle low-profile mode (requires auth)
// ============================================================
router.post('/low-profile', auth, async (req, res) => {
  try {
    const { isLowProfile } = req.body;

    await User.findByIdAndUpdate(req.userId, { isLowProfile: !!isLowProfile });

    return res.json({ success: true });
  } catch (error) {
    console.error('Low profile error:', error);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// ============================================================
// GET /monitoring
// Get profile completion percentage (requires auth)
// ============================================================
router.get('/monitoring', auth, async (req, res) => {
  try {
    const user = await User.findById(req.userId);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const percentage = calculateCompletionPercentage(user);

    return res.json({ success: true, data: percentage });
  } catch (error) {
    console.error('Monitoring error:', error);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// ============================================================
// GET /match
// Get potential matches (users nearby) (requires auth)
// ============================================================
router.get('/match', auth, async (req, res) => {
  try {
    const page = Math.max(parseInt(req.query.page) || 1, 1);
    const limit = Math.min(Math.max(parseInt(req.query.limit) || 20, 1), 100);
    const skip = (page - 1) * limit;

    const currentUser = await User.findById(req.userId);
    if (!currentUser) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    // Build a filter: exclude self, exclude banned/suspended, exclude low-profile users
    const filter = {
      _id: { $ne: req.userId },
      status: { $nin: ['suspended', 'banned'] },
      isLowProfile: { $ne: true },
    };

    // If the current user has a location, try to find nearby users
    // For now this is a simple query; a production system would use $geoNear
    if (currentUser.profile?.latitude && currentUser.profile?.longitude) {
      const lat = currentUser.profile.latitude;
      const lng = currentUser.profile.longitude;
      // Rough bounding box (~50 km)
      const delta = 0.45;
      filter['profile.latitude'] = { $gte: lat - delta, $lte: lat + delta };
      filter['profile.longitude'] = { $gte: lng - delta, $lte: lng + delta };
    }

    const users = await User.find(filter)
      .select('-password')
      .skip(skip)
      .limit(limit)
      .sort({ lastSeen: -1 });

    const total = await User.countDocuments(filter);

    return res.json({
      success: true,
      data: users.map(formatUserForClient),
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    console.error('Match error:', error);
    return res.status(500).json({ success: false, message: 'Server error fetching matches' });
  }
});

// ============================================================
// GET /search
// Search users by name/email (requires auth)
// ============================================================
router.get('/search', auth, async (req, res) => {
  try {
    const { query } = req.query;
    const page = Math.max(parseInt(req.query.page) || 1, 1);
    const limit = Math.min(Math.max(parseInt(req.query.limit) || 20, 1), 100);
    const skip = (page - 1) * limit;

    if (!query || query.trim().length === 0) {
      return res.json({ success: true, data: [] });
    }

    const searchRegex = new RegExp(query.trim(), 'i');

    const filter = {
      _id: { $ne: req.userId },
      status: { $nin: ['suspended', 'banned'] },
      $or: [
        { userName: searchRegex },
        { email: searchRegex },
        { 'profile.bio': searchRegex },
      ],
    };

    const users = await User.find(filter)
      .select('-password')
      .skip(skip)
      .limit(limit)
      .sort({ userName: 1 });

    const total = await User.countDocuments(filter);

    return res.json({
      success: true,
      message: `Found ${total} user(s)`,
      data: users.map(formatUserForClient),
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    console.error('Search error:', error);
    return res.status(500).json({ success: false, message: 'Server error during search' });
  }
});

// ============================================================
// GET /List
// List users (requires auth)
// ============================================================
router.get('/List', auth, async (req, res) => {
  try {
    const page = Math.max(parseInt(req.query.page) || 1, 1);
    const limit = Math.min(Math.max(parseInt(req.query.limit) || 20, 1), 100);
    const skip = (page - 1) * limit;

    const filter = {
      _id: { $ne: req.userId },
      status: { $nin: ['suspended', 'banned'] },
    };

    const users = await User.find(filter)
      .select('-password')
      .skip(skip)
      .limit(limit)
      .sort({ createdAt: -1 });

    const total = await User.countDocuments(filter);

    return res.json({
      success: true,
      data: users.map(formatUserForClient),
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    console.error('List users error:', error);
    return res.status(500).json({ success: false, message: 'Server error listing users' });
  }
});

// ============================================================
// GET /achievement-list
// Get badges list (requires auth)
// ============================================================
router.get('/achievement-list', auth, async (req, res) => {
  try {
    // Try to load Badge model; if it does not exist yet, return placeholder data
    let badges = [];
    try {
      const Badge = require('../models/Badge');
      badges = await Badge.find({ isActive: true }).sort({ order: 1 });
    } catch (_) {
      // Badge model not yet created – return placeholder list
      badges = [
        { _id: 'badge_1', badgeId: 1, name: 'First Steps', description: 'Complete your profile', icon: 'star', requirement: 'profile_complete', isActive: true },
        { _id: 'badge_2', badgeId: 2, name: 'Social Butterfly', description: 'Join 5 activities', icon: 'people', requirement: 'join_5_activities', isActive: true },
        { _id: 'badge_3', badgeId: 3, name: 'Event Creator', description: 'Create your first activity', icon: 'event', requirement: 'create_activity', isActive: true },
        { _id: 'badge_4', badgeId: 4, name: 'Explorer', description: 'Visit 10 different locations', icon: 'explore', requirement: 'visit_10_locations', isActive: true },
        { _id: 'badge_5', badgeId: 5, name: 'Top Rated', description: 'Achieve a 4.5+ average rating', icon: 'thumb_up', requirement: 'rating_4_5', isActive: true },
      ];
    }

    // Check which badges the current user has claimed
    let claimedBadgeIds = [];
    try {
      const UserBadge = require('../models/UserBadge');
      const userBadges = await UserBadge.find({ userId: req.user.userId });
      claimedBadgeIds = userBadges.map((ub) => String(ub.badgeId));
    } catch (_) {
      // UserBadge model not available – no claimed badges
      claimedBadgeIds = [];
    }

    const formattedBadges = badges.map((badge) => ({
      badgeId: badge.badgeId || badge._id,
      name: badge.name,
      description: badge.description,
      icon: badge.icon,
      requirement: badge.requirement,
      claimed: claimedBadgeIds.includes(String(badge.badgeId || badge._id)),
    }));

    return res.json({ success: true, data: formattedBadges });
  } catch (error) {
    console.error('Achievement list error:', error);
    return res.status(500).json({ success: false, message: 'Server error fetching achievements' });
  }
});

// ============================================================
// POST /claimed
// Claim a badge (requires auth)
// ============================================================
router.post('/claimed', auth, async (req, res) => {
  try {
    const { badgeId } = req.body;

    if (!badgeId) {
      return res.status(400).json({ success: false, message: 'badgeId is required' });
    }

    try {
      const UserBadge = require('../models/UserBadge');

      // Prevent duplicate claims
      const existing = await UserBadge.findOne({ userId: req.user.userId, badgeId });
      if (existing) {
        return res.status(409).json({ success: false, message: 'Badge already claimed' });
      }

      await UserBadge.create({
        userId: req.user.userId,
        badgeId,
        claimedAt: new Date(),
      });
    } catch (_) {
      // UserBadge model not yet available – accept the claim silently
    }

    return res.json({ success: true });
  } catch (error) {
    console.error('Claim badge error:', error);
    return res.status(500).json({ success: false, message: 'Server error claiming badge' });
  }
});

// ============================================================
// GET /ranking
// Get leaderboard (requires auth)
// ============================================================
router.get('/ranking', auth, async (req, res) => {
  try {
    // Leaderboard: top users by a composite score (activities + rating)
    const topUsers = await User.find({
      status: { $nin: ['suspended', 'banned'] },
    })
      .select('-password')
      .sort({ averageRating: -1, 'activities.joined': -1 })
      .limit(50);

    const leaderboard = topUsers.map((user, index) => ({
      rank: index + 1,
      userId: user.userId,
      userName: user.userName,
      profileImage: user.profile?.images?.[0] || null,
      averageRating: user.averageRating || 0,
      activitiesJoined: user.activities?.joined || 0,
      activitiesCreated: user.activities?.created || 0,
      score: ((user.averageRating || 0) * 10) + ((user.activities?.joined || 0) * 2) + ((user.activities?.created || 0) * 3),
    }));

    // Find current user's position
    const currentUser = await User.findById(req.userId).select('-password');
    let currentUserEntry = null;
    if (currentUser) {
      const existingEntry = leaderboard.find((e) => e.userId === currentUser.userId);
      if (existingEntry) {
        currentUserEntry = existingEntry;
      } else {
        // User is outside the top 50 – compute their rank
        const score = ((currentUser.averageRating || 0) * 10) +
          ((currentUser.activities?.joined || 0) * 2) +
          ((currentUser.activities?.created || 0) * 3);

        const higherCount = await User.countDocuments({
          status: { $nin: ['suspended', 'banned'] },
          $or: [
            { averageRating: { $gt: currentUser.averageRating || 0 } },
          ],
        });

        currentUserEntry = {
          rank: higherCount + 1,
          userId: currentUser.userId,
          userName: currentUser.userName,
          profileImage: currentUser.profile?.images?.[0] || null,
          averageRating: currentUser.averageRating || 0,
          activitiesJoined: currentUser.activities?.joined || 0,
          activitiesCreated: currentUser.activities?.created || 0,
          score,
        };
      }
    }

    return res.json({
      success: true,
      data: leaderboard,
      currentUser: currentUserEntry,
    });
  } catch (error) {
    console.error('Ranking error:', error);
    return res.status(500).json({ success: false, message: 'Server error fetching rankings' });
  }
});

// ============================================================
// GET /followed-businesses
// Get businesses the user follows (requires auth)
// ============================================================
router.get('/followed-businesses', auth, async (req, res) => {
  try {
    const page = Math.max(parseInt(req.query.page) || 1, 1);
    const limit = Math.min(Math.max(parseInt(req.query.limit) || 20, 1), 100);
    const skip = (page - 1) * limit;

    const user = await User.findById(req.userId).select('followedBusinessIds');
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const businessIds = user.followedBusinessIds || [];

    if (businessIds.length === 0) {
      return res.json({ success: true, data: [], pagination: { page, limit, total: 0, pages: 0 } });
    }

    // Fetch followed business user accounts
    const businesses = await User.find({
      userId: { $in: businessIds },
      accountType: 'business',
    })
      .select('-password')
      .skip(skip)
      .limit(limit);

    const total = await User.countDocuments({
      userId: { $in: businessIds },
      accountType: 'business',
    });

    return res.json({
      success: true,
      data: businesses.map(formatUserForClient),
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    console.error('Followed businesses error:', error);
    return res.status(500).json({ success: false, message: 'Server error fetching followed businesses' });
  }
});

// ============================================================
// POST /register-device
// Register device for push notifications (requires auth)
// ============================================================
router.post('/register-device', auth, async (req, res) => {
  try {
    const { token, platform } = req.body;

    if (!token) {
      return res.status(400).json({ success: false, message: 'token is required' });
    }

    await User.findByIdAndUpdate(req.userId, {
      fcmToken: token,
      devicePlatform: platform || 'unknown',
    });

    return res.json({ success: true });
  } catch (error) {
    console.error('Register device error:', error);
    return res.status(500).json({ success: false, message: 'Server error registering device' });
  }
});

// ============================================================
// POST /send-phone-otp
// Send OTP for phone verification (requires auth)
// ============================================================
router.post('/send-phone-otp', auth, async (req, res) => {
  try {
    const { phone_number, country_code } = req.body;

    if (!phone_number || !country_code) {
      return res.status(400).json({ success: false, message: 'phone_number and country_code are required' });
    }

    const user = await User.findById(req.userId);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    // Generate a 4-digit OTP
    const otp = String(Math.floor(1000 + Math.random() * 9000));

    // Store phone verification data on the user (schema uses snake_case)
    user.phoneVerification = {
      phone_number: phone_number,
      country_code: country_code,
      status: 'pending',
      otp,
      otp_sent_at: new Date(),
      otp_expires_at: new Date(Date.now() + 10 * 60 * 1000), // 10 minutes
      otp_attempts: 0,
    };
    await user.save();

    // In production, send the OTP via SMS service.
    // For now, log it to console.
    console.log(`Phone OTP for ${country_code}${phone_number}: ${otp}`);

    return res.json({ success: true, message: 'OTP sent to phone number' });
  } catch (error) {
    console.error('Send phone OTP error:', error);
    return res.status(500).json({ success: false, message: 'Server error sending phone OTP' });
  }
});

// ============================================================
// POST /verify-phone-otp
// Verify phone OTP (requires auth)
// ============================================================
router.post('/verify-phone-otp', auth, async (req, res) => {
  try {
    const { phone_number, country_code, otp } = req.body;

    if (!phone_number || !country_code || !otp) {
      return res.status(400).json({ success: false, message: 'phone_number, country_code and otp are required' });
    }

    const user = await User.findById(req.userId);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const pv = user.phoneVerification;
    if (!pv || pv.status === 'verified') {
      return res.status(400).json({ success: false, message: 'No pending phone verification' });
    }

    if (pv.phone_number !== phone_number || pv.country_code !== country_code) {
      return res.status(400).json({ success: false, message: 'Phone number does not match' });
    }

    if (pv.otp_expires_at && pv.otp_expires_at < new Date()) {
      return res.status(400).json({ success: false, message: 'OTP has expired. Please request a new one' });
    }

    // Track attempts
    pv.otp_attempts = (pv.otp_attempts || 0) + 1;
    if (pv.otp_attempts > 5) {
      return res.status(429).json({ success: false, message: 'Too many attempts. Please request a new OTP' });
    }

    if (pv.otp !== otp.toString()) {
      await user.save();
      return res.status(400).json({ success: false, message: 'Invalid OTP' });
    }

    // OTP is valid – mark as verified
    user.phoneVerification = {
      phone_number: phone_number,
      country_code: country_code,
      status: 'verified',
      verified_at: new Date(),
      otp_sent_at: pv.otp_sent_at,
      otp_attempts: pv.otp_attempts,
    };

    // Recalculate completion since phone verification affects it
    user.completionPercentage = calculateCompletionPercentage(user);
    await user.save();

    return res.json({
      success: true,
      data: {
        phone_number: user.phoneVerification.phone_number,
        country_code: user.phoneVerification.country_code,
        status: user.phoneVerification.status,
        verified_at: user.phoneVerification.verified_at,
        otp_sent_at: user.phoneVerification.otp_sent_at,
        otp_attempts: user.phoneVerification.otp_attempts,
      },
    });
  } catch (error) {
    console.error('Verify phone OTP error:', error);
    return res.status(500).json({ success: false, message: 'Server error verifying phone OTP' });
  }
});

// ============================================================
// GET /phone-status
// Get phone verification status (requires auth)
// ============================================================
router.get('/phone-status', auth, async (req, res) => {
  try {
    const user = await User.findById(req.userId).select('phoneVerification');
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const pv = user.phoneVerification;

    return res.json({
      success: true,
      data: pv
        ? {
            phone_number: pv.phone_number || null,
            country_code: pv.country_code || null,
            status: pv.status || 'unverified',
            verified_at: pv.verified_at || null,
            otp_sent_at: pv.otp_sent_at || null,
            otp_attempts: pv.otp_attempts || 0,
          }
        : {
            phone_number: null,
            country_code: null,
            status: 'unverified',
            verified_at: null,
            otp_sent_at: null,
            otp_attempts: 0,
          },
    });
  } catch (error) {
    console.error('Phone status error:', error);
    return res.status(500).json({ success: false, message: 'Server error fetching phone status' });
  }
});

// ============================================================
// GET /reminder-preferences
// Get reminder preferences (requires auth)
// ============================================================
router.get('/reminder-preferences', auth, async (req, res) => {
  try {
    const user = await User.findById(req.userId).select('reminderPreferences');
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    return res.json({
      success: true,
      data: user.reminderPreferences || {
        activityReminders: true,
        messageNotifications: true,
        promotionalEmails: false,
        reminderTime: 30, // minutes before activity
      },
    });
  } catch (error) {
    console.error('Get reminder preferences error:', error);
    return res.status(500).json({ success: false, message: 'Server error fetching reminder preferences' });
  }
});

// ============================================================
// PUT /reminder-preferences
// Update reminder preferences (requires auth)
// ============================================================
router.put('/reminder-preferences', auth, async (req, res) => {
  try {
    const { activityReminders, messageNotifications, promotionalEmails, reminderTime } = req.body;

    const update = {};
    if (activityReminders !== undefined) update['reminderPreferences.activityReminders'] = activityReminders;
    if (messageNotifications !== undefined) update['reminderPreferences.messageNotifications'] = messageNotifications;
    if (promotionalEmails !== undefined) update['reminderPreferences.promotionalEmails'] = promotionalEmails;
    if (reminderTime !== undefined) update['reminderPreferences.reminderTime'] = reminderTime;

    const user = await User.findByIdAndUpdate(
      req.userId,
      { $set: update },
      { new: true },
    ).select('reminderPreferences');

    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    return res.json({
      success: true,
      data: user.reminderPreferences || {
        activityReminders: true,
        messageNotifications: true,
        promotionalEmails: false,
        reminderTime: 30,
      },
    });
  } catch (error) {
    console.error('Update reminder preferences error:', error);
    return res.status(500).json({ success: false, message: 'Server error updating reminder preferences' });
  }
});

// ============================================================
// GET /created-activities-count
// Get count of activities the user created (requires auth)
// ============================================================
router.get('/created-activities-count', auth, async (req, res) => {
  try {
    let count = 0;
    try {
      count = await Activity.countDocuments({ creatorId: req.user.userId });
    } catch (_) {
      // Activity model may not exist yet – fall back to user.activities.created
      const user = await User.findById(req.userId).select('activities');
      count = user?.activities?.created || 0;
    }

    return res.json({ success: true, data: count });
  } catch (error) {
    console.error('Created activities count error:', error);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// ============================================================
// GET /joined-activities-count
// Get count of activities the user joined (requires auth)
// ============================================================
router.get('/joined-activities-count', auth, async (req, res) => {
  try {
    let count = 0;
    try {
      count = await Activity.countDocuments({ 'attendees.userId': req.user.userId });
    } catch (_) {
      // Activity model may not exist yet – fall back to user.activities.joined
      const user = await User.findById(req.userId).select('activities');
      count = user?.activities?.joined || 0;
    }

    return res.json({ success: true, data: count });
  } catch (error) {
    console.error('Joined activities count error:', error);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// ============================================================
// GET /user-activities
// Get activities the user has joined (requires auth)
// ============================================================
router.get('/user-activities', auth, async (req, res) => {
  try {
    const page = Math.max(parseInt(req.query.page) || 1, 1);
    const limit = Math.min(Math.max(parseInt(req.query.limit) || 20, 1), 100);
    const skip = (page - 1) * limit;

    let activities = [];
    let total = 0;

    try {
      const filter = { 'attendees.userId': req.user.userId };
      activities = await Activity.find(filter)
        .skip(skip)
        .limit(limit)
        .sort({ dateTime: -1 });
      total = await Activity.countDocuments(filter);
    } catch (_) {
      // Activity model not yet available – return empty list
      activities = [];
      total = 0;
    }

    return res.json({
      success: true,
      data: activities,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    console.error('User activities error:', error);
    return res.status(500).json({ success: false, message: 'Server error fetching activities' });
  }
});

// ============================================================
// POST /upload-profile-photo
// Upload or replace profile photo (requires auth)
// ============================================================
router.post('/upload-profile-photo', auth, upload.single('photo'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: 'No photo provided' });
    }

    const imageUrl = `/uploads/${req.file.filename}`;
    const user = await User.findById(req.userId);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    if (!user.profile) {
      user.profile = {};
    }

    // Set as first image (profile photo)
    if (!user.profile.images || user.profile.images.length === 0) {
      user.profile.images = [imageUrl];
    } else {
      user.profile.images[0] = imageUrl;
    }

    // Recalculate completion
    user.completionPercentage = calculateCompletionPercentage(user);
    await user.save();

    return res.json({
      success: true,
      data: imageUrl,
      message: 'Profile photo updated',
    });
  } catch (error) {
    console.error('Upload profile photo error:', error);
    return res.status(500).json({ success: false, message: 'Failed to upload profile photo' });
  }
});

// ============================================================
// POST /remove-profile-photo
// Remove profile photo (requires auth)
// ============================================================
router.post('/remove-profile-photo', auth, async (req, res) => {
  try {
    const user = await User.findById(req.userId);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    if (user.profile && user.profile.images && user.profile.images.length > 0) {
      user.profile.images.shift(); // Remove first image (profile photo)
    }

    user.completionPercentage = calculateCompletionPercentage(user);
    await user.save();

    return res.json({
      success: true,
      data: null,
      message: 'Profile photo removed',
    });
  } catch (error) {
    console.error('Remove profile photo error:', error);
    return res.status(500).json({ success: false, message: 'Failed to remove profile photo' });
  }
});

// ============================================================
// POST /delete-account
// Soft-delete user account (requires auth + password confirmation)
// ============================================================
router.post('/delete-account', auth, async (req, res) => {
  try {
    const { password } = req.body;

    if (!password) {
      return res.status(400).json({ success: false, message: 'Password is required to delete account' });
    }

    // Fetch user with password for verification
    const user = await User.findById(req.userId).select('+password');
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    // Verify password
    const bcrypt = require('bcryptjs');
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ success: false, message: 'Incorrect password' });
    }

    // Soft delete: mark as deleted, clear sensitive data
    user.status = 'deleted';
    user.fcmToken = null;
    user.refreshToken = null;
    user.onlineStatus = 'offline';
    await user.save();

    return res.json({
      success: true,
      message: 'Account deleted successfully',
    });
  } catch (error) {
    console.error('Delete account error:', error);
    return res.status(500).json({ success: false, message: 'Failed to delete account' });
  }
});

module.exports = router;
