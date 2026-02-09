const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');

const memberSchema = new mongoose.Schema(
  {
    userId: { type: Number, required: true },
    userName: String,
    userImage: String,
    role: { type: String, enum: ['owner', 'admin', 'moderator', 'member'], default: 'member' },
    joinedAt: { type: Date, default: Date.now },
    isActive: { type: Boolean, default: true },
    bio: String,
  },
  { _id: false }
);

const joinRequestSchema = new mongoose.Schema(
  {
    requestId: { type: String, default: uuidv4 },
    userId: { type: Number, required: true },
    userName: String,
    userImage: String,
    message: String,
    requestedAt: { type: Date, default: Date.now },
    isPending: { type: Boolean, default: true },
  },
  { _id: false }
);

const groupSchema = new mongoose.Schema(
  {
    groupId: { type: String, default: uuidv4, unique: true, index: true },
    name: { type: String, required: true, trim: true },
    description: String,
    type: { type: String, enum: ['interest', 'activity', 'event', 'social', 'custom'], default: 'interest' },
    privacy: { type: String, enum: ['public', 'private', 'secret'], default: 'public' },
    image: String,
    coverImage: String,
    interests: [String],
    tags: [String],
    creatorId: { type: Number, required: true },
    creatorName: String,
    members: [memberSchema],
    memberCount: { type: Number, default: 0 },
    eventCount: { type: Number, default: 0 },
    isActive: { type: Boolean, default: true },
    location: String,
    latitude: Number,
    longitude: Number,
    settings: {
      allowMemberPosts: { type: Boolean, default: true },
      allowMemberEvents: { type: Boolean, default: true },
      requireApproval: { type: Boolean, default: false },
      showMemberList: { type: Boolean, default: true },
      allowInvites: { type: Boolean, default: true },
      maxMembers: Number,
      blockedWords: [String],
      notifyNewMembers: { type: Boolean, default: true },
      notifyNewEvents: { type: Boolean, default: true },
      notifyNewPosts: { type: Boolean, default: true },
    },
    joinRequests: [joinRequestSchema],
  },
  { timestamps: true }
);

module.exports = mongoose.model('Group', groupSchema);
