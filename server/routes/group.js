const express = require('express');
const router = express.Router();
const Group = require('../models/Group');
const { auth } = require('../middleware/auth');

// ============================================================
// Group CRUD
// ============================================================

// POST /api/group/create - Create group
router.post('/create', auth, async (req, res) => {
  try {
    const {
      name,
      description,
      type,
      privacy,
      image,
      cover_image,
      interests,
      tags,
      location,
      latitude,
      longitude,
      settings,
    } = req.body;

    if (!name) {
      return res.status(400).json({ message: 'Group name is required' });
    }

    const userId = req.user.userId;
    const userName = req.user.userName || 'Unknown';

    const group = await Group.create({
      name,
      description: description || '',
      type: type || 'interest',
      privacy: privacy || 'public',
      image: image || null,
      coverImage: cover_image || null,
      interests: interests || [],
      tags: tags || [],
      creatorId: userId,
      creatorName: userName,
      location: location || null,
      latitude: latitude ? parseFloat(latitude) : null,
      longitude: longitude ? parseFloat(longitude) : null,
      settings: settings || {
        allow_member_posts: true,
        allow_member_events: true,
        require_approval: false,
        show_member_list: true,
        allow_invites: true,
        max_members: null,
        blocked_words: [],
        notify_new_members: true,
        notify_new_events: true,
        notify_new_posts: true,
      },
      members: [
        {
          userId,
          userName,
          userImage: req.user.profile?.images?.[0] || null,
          role: 'owner',
          joinedAt: new Date(),
          isActive: true,
        },
      ],
      memberCount: 1,
      eventCount: 0,
      isActive: true,
      joinRequests: [],
    });

    res.status(201).json({
      success: true,
      data: formatGroup(group, userId),
    });
  } catch (error) {
    console.error('Create group error:', error);
    res.status(500).json({ message: 'Failed to create group' });
  }
});

// GET /api/group/list - List groups with filters
router.get('/list', auth, async (req, res) => {
  try {
    const {
      page = 1,
      limit = 20,
      type,
      interest,
      query,
      latitude,
      longitude,
      radius,
    } = req.query;

    const pageNum = parseInt(page);
    const limitNum = parseInt(limit);
    const skip = (pageNum - 1) * limitNum;

    const filter = { isActive: true };

    if (type) {
      filter.type = type;
    }

    if (interest) {
      filter.interests = { $in: [interest] };
    }

    if (query) {
      filter.$or = [
        { name: { $regex: query, $options: 'i' } },
        { description: { $regex: query, $options: 'i' } },
        { tags: { $in: [new RegExp(query, 'i')] } },
      ];
    }

    if (latitude && longitude && radius) {
      const lat = parseFloat(latitude);
      const lng = parseFloat(longitude);
      const rad = parseFloat(radius);
      const latDelta = rad / 69;
      const lngDelta = rad / (69 * Math.cos((lat * Math.PI) / 180));

      filter.latitude = { $gte: lat - latDelta, $lte: lat + latDelta };
      filter.longitude = { $gte: lng - lngDelta, $lte: lng + lngDelta };
    }

    const groups = await Group.find(filter)
      .sort({ memberCount: -1, createdAt: -1 })
      .skip(skip)
      .limit(limitNum);

    const userId = req.user.userId;
    const data = groups.map((group) => formatGroup(group, userId));

    res.json({ success: true, data });
  } catch (error) {
    console.error('List groups error:', error);
    res.status(500).json({ message: 'Failed to list groups' });
  }
});

// GET /api/group/details/:groupId - Get group details
router.get('/details/:groupId', auth, async (req, res) => {
  try {
    const group = await Group.findById(req.params.groupId);
    if (!group) {
      return res.status(404).json({ message: 'Group not found' });
    }

    const userId = req.user.userId;
    res.json({ success: true, data: formatGroup(group, userId) });
  } catch (error) {
    console.error('Get group details error:', error);
    res.status(500).json({ message: 'Failed to get group details' });
  }
});

// PUT /api/group/update - Update group
router.put('/update', auth, async (req, res) => {
  try {
    const { group_id, name, description, privacy, image, cover_image, interests, tags, settings } = req.body;

    if (!group_id) {
      return res.status(400).json({ message: 'Group ID is required' });
    }

    const group = await Group.findById(group_id);
    if (!group) {
      return res.status(404).json({ message: 'Group not found' });
    }

    const userId = req.user.userId;
    const member = (group.members || []).find((m) => m.userId === userId);
    if (!member || (member.role !== 'owner' && member.role !== 'admin')) {
      return res.status(403).json({ message: 'Only owners and admins can update the group' });
    }

    const updateFields = {};
    if (name !== undefined) updateFields.name = name;
    if (description !== undefined) updateFields.description = description;
    if (privacy !== undefined) updateFields.privacy = privacy;
    if (image !== undefined) updateFields.image = image;
    if (cover_image !== undefined) updateFields.coverImage = cover_image;
    if (interests !== undefined) updateFields.interests = interests;
    if (tags !== undefined) updateFields.tags = tags;
    if (settings !== undefined) updateFields.settings = settings;

    const updatedGroup = await Group.findByIdAndUpdate(
      group_id,
      { $set: updateFields },
      { new: true }
    );

    res.json({ success: true, data: formatGroup(updatedGroup, userId) });
  } catch (error) {
    console.error('Update group error:', error);
    res.status(500).json({ message: 'Failed to update group' });
  }
});

// DELETE /api/group/delete/:groupId - Delete group (owner only)
router.delete('/delete/:groupId', auth, async (req, res) => {
  try {
    const group = await Group.findById(req.params.groupId);
    if (!group) {
      return res.status(404).json({ message: 'Group not found' });
    }

    const userId = req.user.userId;
    const member = (group.members || []).find((m) => m.userId === userId);
    if (!member || member.role !== 'owner') {
      return res.status(403).json({ message: 'Only the group owner can delete the group' });
    }

    await Group.findByIdAndDelete(req.params.groupId);

    res.json({ success: true, message: 'Group deleted successfully' });
  } catch (error) {
    console.error('Delete group error:', error);
    res.status(500).json({ message: 'Failed to delete group' });
  }
});

// ============================================================
// Membership
// ============================================================

// POST /api/group/join - Join group
router.post('/join', auth, async (req, res) => {
  try {
    const { group_id, message } = req.body;
    if (!group_id) {
      return res.status(400).json({ message: 'Group ID is required' });
    }

    const group = await Group.findById(group_id);
    if (!group) {
      return res.status(404).json({ message: 'Group not found' });
    }

    const userId = req.user.userId;
    const existingMember = (group.members || []).find((m) => m.userId === userId);
    if (existingMember) {
      return res.status(400).json({ message: 'Already a member of this group' });
    }

    const settings = group.settings || {};
    const requireApproval = settings.require_approval || settings.requireApproval || false;

    if (requireApproval) {
      const existingRequest = (group.joinRequests || []).find((r) => r.userId === userId);
      if (existingRequest) {
        return res.status(400).json({ message: 'Join request already pending' });
      }

      await Group.findByIdAndUpdate(group_id, {
        $push: {
          joinRequests: {
            userId,
            userName: req.user.userName || 'Unknown',
            userImage: req.user.profile?.images?.[0] || null,
            message: message || null,
            requestedAt: new Date(),
            isPending: true,
          },
        },
      });

      res.json({
        success: true,
        data: {
          member_id: null,
          group_id,
          user_id: userId,
          user_name: req.user.userName || 'Unknown',
          user_image: req.user.profile?.images?.[0] || null,
          role: 'pending',
          joined_at: new Date().toISOString(),
          is_active: false,
        },
        message: 'Join request submitted for approval',
      });
    } else {
      const newMember = {
        userId,
        userName: req.user.userName || 'Unknown',
        userImage: req.user.profile?.images?.[0] || null,
        role: 'member',
        joinedAt: new Date(),
        isActive: true,
      };

      await Group.findByIdAndUpdate(group_id, {
        $push: { members: newMember },
        $inc: { memberCount: 1 },
      });

      res.json({
        success: true,
        data: {
          member_id: null,
          group_id,
          user_id: userId,
          user_name: newMember.userName,
          user_image: newMember.userImage,
          role: 'member',
          joined_at: newMember.joinedAt.toISOString(),
          is_active: true,
        },
      });
    }
  } catch (error) {
    console.error('Join group error:', error);
    res.status(500).json({ message: 'Failed to join group' });
  }
});

// POST /api/group/leave - Leave group
router.post('/leave', auth, async (req, res) => {
  try {
    const { group_id } = req.body;
    if (!group_id) {
      return res.status(400).json({ message: 'Group ID is required' });
    }

    const group = await Group.findById(group_id);
    if (!group) {
      return res.status(404).json({ message: 'Group not found' });
    }

    const userId = req.user.userId;
    const member = (group.members || []).find((m) => m.userId === userId);
    if (!member) {
      return res.status(400).json({ message: 'Not a member of this group' });
    }

    if (member.role === 'owner') {
      return res.status(400).json({ message: 'Owner cannot leave the group. Transfer ownership or delete the group.' });
    }

    await Group.findByIdAndUpdate(group_id, {
      $pull: { members: { userId } },
      $inc: { memberCount: -1 },
    });

    res.json({ success: true, message: 'Left group successfully' });
  } catch (error) {
    console.error('Leave group error:', error);
    res.status(500).json({ message: 'Failed to leave group' });
  }
});

// GET /api/group/members/:groupId - Get group members
router.get('/members/:groupId', auth, async (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;
    const pageNum = parseInt(page);
    const limitNum = parseInt(limit);

    const group = await Group.findById(req.params.groupId);
    if (!group) {
      return res.status(404).json({ message: 'Group not found' });
    }

    const members = (group.members || [])
      .filter((m) => m.isActive !== false)
      .slice((pageNum - 1) * limitNum, pageNum * limitNum)
      .map((m) => ({
        member_id: m._id || null,
        group_id: req.params.groupId,
        user_id: m.userId,
        user_name: m.userName,
        user_image: m.userImage,
        role: m.role,
        joined_at: m.joinedAt ? m.joinedAt.toISOString() : null,
        is_active: m.isActive !== false,
        bio: m.bio || null,
      }));

    res.json({ success: true, data: members });
  } catch (error) {
    console.error('Get group members error:', error);
    res.status(500).json({ message: 'Failed to get group members' });
  }
});

// GET /api/group/events/:groupId - Get group events
router.get('/events/:groupId', auth, async (req, res) => {
  try {
    const { page = 1, limit = 20, upcoming_only } = req.query;
    const pageNum = parseInt(page);
    const limitNum = parseInt(limit);

    const group = await Group.findById(req.params.groupId);
    if (!group) {
      return res.status(404).json({ message: 'Group not found' });
    }

    const filter = { groupId: req.params.groupId };
    if (upcoming_only === 'true') {
      filter.startDate = { $gte: new Date() };
    }

    // Try to load events from an Activity/Event model if it exists
    try {
      const Activity = require('../models/Activity');
      const events = await Activity.find(filter)
        .sort({ startDate: 1 })
        .skip((pageNum - 1) * limitNum)
        .limit(limitNum);

      res.json({ success: true, data: events });
    } catch (_) {
      // If Activity model doesn't exist or query fails, return group events array
      const events = group.events || [];
      const sliced = events.slice((pageNum - 1) * limitNum, pageNum * limitNum);
      res.json({ success: true, data: sliced });
    }
  } catch (error) {
    console.error('Get group events error:', error);
    res.status(500).json({ message: 'Failed to get group events' });
  }
});

// ============================================================
// Join Requests
// ============================================================

// GET /api/group/requests/:groupId - Get join requests (admin only)
router.get('/requests/:groupId', auth, async (req, res) => {
  try {
    const group = await Group.findById(req.params.groupId);
    if (!group) {
      return res.status(404).json({ message: 'Group not found' });
    }

    const userId = req.user.userId;
    const member = (group.members || []).find((m) => m.userId === userId);
    if (!member || (member.role !== 'owner' && member.role !== 'admin')) {
      return res.status(403).json({ message: 'Only admins can view join requests' });
    }

    const requests = (group.joinRequests || [])
      .filter((r) => r.isPending !== false)
      .map((r) => ({
        request_id: r._id || null,
        group_id: req.params.groupId,
        user_id: r.userId,
        user_name: r.userName,
        user_image: r.userImage,
        message: r.message,
        requested_at: r.requestedAt ? r.requestedAt.toISOString() : null,
        is_pending: r.isPending !== false,
      }));

    res.json({ success: true, data: requests });
  } catch (error) {
    console.error('Get join requests error:', error);
    res.status(500).json({ message: 'Failed to get join requests' });
  }
});

// POST /api/group/respond-request - Respond to join request
router.post('/respond-request', auth, async (req, res) => {
  try {
    const { request_id, approve } = req.body;
    if (request_id === undefined || approve === undefined) {
      return res.status(400).json({ message: 'Request ID and approve flag are required' });
    }

    // Find the group containing this join request
    const group = await Group.findOne({ 'joinRequests._id': request_id });
    if (!group) {
      return res.status(404).json({ message: 'Join request not found' });
    }

    const userId = req.user.userId;
    const adminMember = (group.members || []).find((m) => m.userId === userId);
    if (!adminMember || (adminMember.role !== 'owner' && adminMember.role !== 'admin')) {
      return res.status(403).json({ message: 'Only admins can respond to join requests' });
    }

    const request = (group.joinRequests || []).find(
      (r) => r._id && r._id.toString() === request_id.toString()
    );
    if (!request) {
      return res.status(404).json({ message: 'Join request not found' });
    }

    if (approve) {
      const newMember = {
        userId: request.userId,
        userName: request.userName,
        userImage: request.userImage,
        role: 'member',
        joinedAt: new Date(),
        isActive: true,
      };

      await Group.findByIdAndUpdate(group._id, {
        $push: { members: newMember },
        $pull: { joinRequests: { _id: request._id } },
        $inc: { memberCount: 1 },
      });

      res.json({
        success: true,
        data: {
          member_id: null,
          group_id: group._id,
          user_id: request.userId,
          user_name: request.userName,
          user_image: request.userImage,
          role: 'member',
          joined_at: new Date().toISOString(),
          is_active: true,
        },
        message: 'Join request approved',
      });
    } else {
      await Group.findByIdAndUpdate(group._id, {
        $pull: { joinRequests: { _id: request._id } },
      });

      res.json({
        success: true,
        data: {
          member_id: null,
          group_id: group._id,
          user_id: request.userId,
          user_name: request.userName,
          user_image: request.userImage,
          role: null,
          joined_at: null,
          is_active: false,
        },
        message: 'Join request rejected',
      });
    }
  } catch (error) {
    console.error('Respond to join request error:', error);
    res.status(500).json({ message: 'Failed to respond to join request' });
  }
});

// ============================================================
// Search & Discovery
// ============================================================

// GET /api/group/search - Search groups
router.get('/search', auth, async (req, res) => {
  try {
    const { query, page = 1, limit = 20 } = req.query;
    const pageNum = parseInt(page);
    const limitNum = parseInt(limit);

    if (!query) {
      return res.status(400).json({ message: 'Search query is required' });
    }

    const filter = {
      isActive: true,
      $or: [
        { name: { $regex: query, $options: 'i' } },
        { description: { $regex: query, $options: 'i' } },
        { tags: { $in: [new RegExp(query, 'i')] } },
        { interests: { $in: [new RegExp(query, 'i')] } },
      ],
    };

    const groups = await Group.find(filter)
      .sort({ memberCount: -1 })
      .skip((pageNum - 1) * limitNum)
      .limit(limitNum);

    const userId = req.user.userId;
    const data = groups.map((group) => formatGroup(group, userId));

    res.json({ success: true, data });
  } catch (error) {
    console.error('Search groups error:', error);
    res.status(500).json({ message: 'Failed to search groups' });
  }
});

// GET /api/group/suggested - Suggested groups based on user interests
router.get('/suggested', auth, async (req, res) => {
  try {
    const { limit = 10 } = req.query;
    const limitNum = parseInt(limit);
    const userId = req.user.userId;

    // Get user interests from profile
    const userInterests = req.user.profile?.interests || req.user.interests || [];

    let groups;
    if (userInterests.length > 0) {
      groups = await Group.find({
        isActive: true,
        interests: { $in: userInterests },
        'members.userId': { $ne: userId },
      })
        .sort({ memberCount: -1 })
        .limit(limitNum);
    } else {
      // Fallback: return popular groups the user is not a member of
      groups = await Group.find({
        isActive: true,
        'members.userId': { $ne: userId },
      })
        .sort({ memberCount: -1 })
        .limit(limitNum);
    }

    const data = groups.map((group) => formatGroup(group, userId));

    res.json({ success: true, data });
  } catch (error) {
    console.error('Get suggested groups error:', error);
    res.status(500).json({ message: 'Failed to get suggested groups' });
  }
});

// GET /api/group/my-groups - User's groups
router.get('/my-groups', auth, async (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;
    const pageNum = parseInt(page);
    const limitNum = parseInt(limit);

    const userId = req.user.userId;

    const groups = await Group.find({
      isActive: true,
      'members.userId': userId,
    })
      .sort({ createdAt: -1 })
      .skip((pageNum - 1) * limitNum)
      .limit(limitNum);

    const data = groups.map((group) => formatGroup(group, userId));

    res.json({ success: true, data });
  } catch (error) {
    console.error('Get my groups error:', error);
    res.status(500).json({ message: 'Failed to get your groups' });
  }
});

// GET /api/group/by-interest - Groups by interest
router.get('/by-interest', auth, async (req, res) => {
  try {
    const { interest, page = 1, limit = 20 } = req.query;
    const pageNum = parseInt(page);
    const limitNum = parseInt(limit);

    if (!interest) {
      return res.status(400).json({ message: 'Interest parameter is required' });
    }

    const groups = await Group.find({
      isActive: true,
      interests: { $in: [interest] },
    })
      .sort({ memberCount: -1 })
      .skip((pageNum - 1) * limitNum)
      .limit(limitNum);

    const userId = req.user.userId;
    const data = groups.map((group) => formatGroup(group, userId));

    res.json({ success: true, data });
  } catch (error) {
    console.error('Get groups by interest error:', error);
    res.status(500).json({ message: 'Failed to get groups by interest' });
  }
});

// ============================================================
// Member Management
// ============================================================

// PUT /api/group/members/:groupId/role - Update member role
router.put('/members/:groupId/role', auth, async (req, res) => {
  try {
    const { user_id, role } = req.body;
    if (!user_id || !role) {
      return res.status(400).json({ message: 'User ID and role are required' });
    }

    const validRoles = ['admin', 'moderator', 'member'];
    if (!validRoles.includes(role)) {
      return res.status(400).json({ message: 'Invalid role. Must be admin, moderator, or member' });
    }

    const group = await Group.findById(req.params.groupId);
    if (!group) {
      return res.status(404).json({ message: 'Group not found' });
    }

    const userId = req.user.userId;
    const adminMember = (group.members || []).find((m) => m.userId === userId);
    if (!adminMember || (adminMember.role !== 'owner' && adminMember.role !== 'admin')) {
      return res.status(403).json({ message: 'Only owners and admins can update member roles' });
    }

    const targetMember = (group.members || []).find((m) => m.userId === parseInt(user_id));
    if (!targetMember) {
      return res.status(404).json({ message: 'Member not found in group' });
    }

    if (targetMember.role === 'owner') {
      return res.status(403).json({ message: 'Cannot change the owner role' });
    }

    await Group.updateOne(
      { _id: req.params.groupId, 'members.userId': parseInt(user_id) },
      { $set: { 'members.$.role': role } }
    );

    res.json({
      success: true,
      data: {
        member_id: targetMember._id || null,
        group_id: req.params.groupId,
        user_id: targetMember.userId,
        user_name: targetMember.userName,
        user_image: targetMember.userImage,
        role,
        joined_at: targetMember.joinedAt ? targetMember.joinedAt.toISOString() : null,
        is_active: true,
      },
    });
  } catch (error) {
    console.error('Update member role error:', error);
    res.status(500).json({ message: 'Failed to update member role' });
  }
});

// DELETE /api/group/members/:groupId/:userId - Remove member
router.delete('/members/:groupId/:userId', auth, async (req, res) => {
  try {
    const group = await Group.findById(req.params.groupId);
    if (!group) {
      return res.status(404).json({ message: 'Group not found' });
    }

    const requesterId = req.user.userId;
    const adminMember = (group.members || []).find((m) => m.userId === requesterId);
    if (!adminMember || (adminMember.role !== 'owner' && adminMember.role !== 'admin')) {
      return res.status(403).json({ message: 'Only owners and admins can remove members' });
    }

    const targetUserId = parseInt(req.params.userId);
    const targetMember = (group.members || []).find((m) => m.userId === targetUserId);
    if (!targetMember) {
      return res.status(404).json({ message: 'Member not found in group' });
    }

    if (targetMember.role === 'owner') {
      return res.status(403).json({ message: 'Cannot remove the group owner' });
    }

    await Group.findByIdAndUpdate(req.params.groupId, {
      $pull: { members: { userId: targetUserId } },
      $inc: { memberCount: -1 },
    });

    res.json({ success: true, message: 'Member removed from group' });
  } catch (error) {
    console.error('Remove member error:', error);
    res.status(500).json({ message: 'Failed to remove member' });
  }
});

// ============================================================
// Helper: Format group for response
// ============================================================

function formatGroup(group, userId) {
  const members = group.members || [];
  const userMember = members.find((m) => m.userId === userId);

  return {
    group_id: group._id ? group._id.toString() : null,
    name: group.name,
    description: group.description,
    type: group.type || 'interest',
    privacy: group.privacy || 'public',
    image: group.image || null,
    cover_image: group.coverImage || null,
    interests: group.interests || [],
    tags: group.tags || [],
    creator_id: group.creatorId,
    creator_name: group.creatorName,
    member_count: group.memberCount || members.length,
    event_count: group.eventCount || 0,
    is_active: group.isActive !== false,
    user_is_member: !!userMember,
    user_role: userMember ? userMember.role : null,
    created_at: group.createdAt ? group.createdAt.toISOString() : null,
    location: group.location || null,
    latitude: group.latitude || null,
    longitude: group.longitude || null,
    settings: group.settings || {},
  };
}

module.exports = router;
