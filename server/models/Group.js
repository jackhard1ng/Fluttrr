const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');

// ---------------------------------------------------------------------------
// Sub-schemas
// ---------------------------------------------------------------------------

// Flutter GroupMemberModel.fromJson reads (snake_case):
//   member_id, group_id, user_id, user_name, user_image, role, joined_at, is_active, bio
const memberSchema = new mongoose.Schema(
  {
    userId: { type: Number, required: true },
    userName: { type: String, default: null },
    userImage: { type: String, default: null },
    role: {
      type: String,
      enum: ['owner', 'admin', 'moderator', 'member'],
      default: 'member',
    },
    joinedAt: { type: Date, default: Date.now },
    isActive: { type: Boolean, default: true },
    bio: { type: String, default: null },
  },
  { _id: false }
);

// Flutter GroupJoinRequest.fromJson reads (snake_case):
//   request_id, group_id, user_id, user_name, user_image, message, requested_at, is_pending
const joinRequestSchema = new mongoose.Schema(
  {
    requestId: { type: String, default: uuidv4 },
    userId: { type: Number, required: true },
    userName: { type: String, default: null },
    userImage: { type: String, default: null },
    message: { type: String, default: null },
    requestedAt: { type: Date, default: Date.now },
    isPending: { type: Boolean, default: true },
  },
  { _id: false }
);

// Flutter GroupSettings.fromJson reads (snake_case):
//   allow_member_posts, allow_member_events, require_approval, show_member_list,
//   allow_invites, max_members, blocked_words, notify_new_members,
//   notify_new_events, notify_new_posts
const settingsSchema = new mongoose.Schema(
  {
    allowMemberPosts: { type: Boolean, default: true },
    allowMemberEvents: { type: Boolean, default: true },
    requireApproval: { type: Boolean, default: false },
    showMemberList: { type: Boolean, default: true },
    allowInvites: { type: Boolean, default: true },
    maxMembers: { type: Number, default: null },
    blockedWords: { type: [String], default: [] },
    notifyNewMembers: { type: Boolean, default: true },
    notifyNewEvents: { type: Boolean, default: true },
    notifyNewPosts: { type: Boolean, default: true },
  },
  { _id: false }
);

// ---------------------------------------------------------------------------
// Group schema
// ---------------------------------------------------------------------------
// Flutter GroupModel.fromJson reads (snake_case):
//   group_id, name, description, type, privacy, image, cover_image,
//   interests, tags, creator_id, creator_name, member_count, event_count,
//   is_active, user_is_member, user_role, created_at, location, latitude, longitude, settings

const groupSchema = new mongoose.Schema(
  {
    groupId: { type: String, default: uuidv4, unique: true, index: true },
    name: {
      type: String,
      required: [true, 'Group name is required'],
      trim: true,
      maxlength: 100,
    },
    description: { type: String, default: null, maxlength: 2000 },
    type: {
      type: String,
      enum: ['interest', 'activity', 'event', 'social', 'custom'],
      default: 'interest',
    },
    privacy: {
      type: String,
      enum: ['public', 'private', 'secret'],
      default: 'public',
    },
    image: { type: String, default: null },
    coverImage: { type: String, default: null },
    interests: { type: [String], default: [] },
    tags: { type: [String], default: [] },
    creatorId: { type: Number, required: true, index: true },
    creatorName: { type: String, default: null },
    members: { type: [memberSchema], default: [] },
    memberCount: { type: Number, default: 0, min: 0 },
    eventCount: { type: Number, default: 0, min: 0 },
    isActive: { type: Boolean, default: true },
    location: { type: String, default: null },
    latitude: { type: Number, default: null },
    longitude: { type: Number, default: null },
    settings: { type: settingsSchema, default: () => ({}) },
    joinRequests: { type: [joinRequestSchema], default: [] },
    createdAt: { type: Date, default: Date.now },
  },
  { timestamps: false }
);

// ---------------------------------------------------------------------------
// Indexes
// ---------------------------------------------------------------------------
groupSchema.index({ type: 1 });
groupSchema.index({ privacy: 1 });
groupSchema.index({ isActive: 1 });
groupSchema.index({ 'members.userId': 1 });
groupSchema.index({ latitude: 1, longitude: 1 });

// ---------------------------------------------------------------------------
// toJSON – convert to snake_case matching Flutter GroupModel.fromJson
// ---------------------------------------------------------------------------
groupSchema.set('toJSON', {
  transform: function (doc, ret) {
    var s = ret.settings || {};
    return {
      group_id: ret.groupId,
      name: ret.name,
      description: ret.description,
      type: ret.type,
      privacy: ret.privacy,
      image: ret.image,
      cover_image: ret.coverImage,
      interests: ret.interests,
      tags: ret.tags,
      creator_id: ret.creatorId,
      creator_name: ret.creatorName,
      member_count: ret.memberCount,
      event_count: ret.eventCount,
      is_active: ret.isActive,
      location: ret.location,
      latitude: ret.latitude,
      longitude: ret.longitude,
      created_at: ret.createdAt,
      settings: {
        allow_member_posts: s.allowMemberPosts,
        allow_member_events: s.allowMemberEvents,
        require_approval: s.requireApproval,
        show_member_list: s.showMemberList,
        allow_invites: s.allowInvites,
        max_members: s.maxMembers,
        blocked_words: s.blockedWords,
        notify_new_members: s.notifyNewMembers,
        notify_new_events: s.notifyNewEvents,
        notify_new_posts: s.notifyNewPosts,
      },
      members: (ret.members || []).map(function (m) {
        return {
          user_id: m.userId,
          user_name: m.userName,
          user_image: m.userImage,
          role: m.role,
          joined_at: m.joinedAt,
          is_active: m.isActive,
          bio: m.bio,
        };
      }),
      join_requests: (ret.joinRequests || []).map(function (r) {
        return {
          request_id: r.requestId,
          user_id: r.userId,
          user_name: r.userName,
          user_image: r.userImage,
          message: r.message,
          requested_at: r.requestedAt,
          is_pending: r.isPending,
        };
      }),
    };
  },
});

// ---------------------------------------------------------------------------
// Convenience: API response with user-specific membership info
// ---------------------------------------------------------------------------
groupSchema.methods.toApiResponse = function (requestingUserId) {
  var json = this.toJSON();
  if (requestingUserId) {
    var member = this.members.find(function (m) {
      return m.userId === requestingUserId && m.isActive;
    });
    json.user_is_member = !!member;
    json.user_role = member ? member.role : null;
  } else {
    json.user_is_member = false;
    json.user_role = null;
  }
  return json;
};

module.exports = mongoose.model('Group', groupSchema);
