const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');

// ---------------------------------------------------------------------------
// Sub-schemas
// ---------------------------------------------------------------------------

// Flutter StoryReaction.fromJson reads (snake_case):
//   reaction_id (or id), user_id, user_name, user_avatar, emoji, created_at
const reactionSchema = new mongoose.Schema(
  {
    reactionId: { type: String, default: uuidv4 },
    userId: { type: String, required: true },
    userName: { type: String, default: 'Unknown' },
    userAvatar: { type: String, default: null },
    emoji: { type: String, required: true },
    createdAt: { type: Date, default: Date.now },
  },
  { _id: false }
);

// ---------------------------------------------------------------------------
// Story schema
// ---------------------------------------------------------------------------
// Flutter StoryModel.fromJson reads (snake_case with camelCase fallback):
//   story_id (or id), user_id, user_name, user_avatar,
//   event_id, event_name, type, media_url, thumbnail_url, caption,
//   created_at, expires_at, view_count, viewer_ids, is_viewed, reactions

const storySchema = new mongoose.Schema({
  storyId: { type: String, default: uuidv4, unique: true, index: true },
  userId: { type: Number, required: true, index: true },
  userName: { type: String, default: 'Unknown' },
  userAvatar: { type: String, default: null },
  eventId: { type: String, default: null, index: true },
  eventName: { type: String, default: null },
  type: {
    type: String,
    enum: ['image', 'video', 'text'],
    default: 'image',
  },
  mediaUrl: { type: String, required: [true, 'Media URL is required'] },
  thumbnailUrl: { type: String, default: null },
  caption: { type: String, default: null, maxlength: 500 },
  createdAt: { type: Date, default: Date.now },
  expiresAt: {
    type: Date,
    default: function () {
      return new Date(Date.now() + 24 * 60 * 60 * 1000); // 24 hours
    },
    index: { expires: 0 }, // TTL: auto-delete when expired
  },
  viewCount: { type: Number, default: 0, min: 0 },
  viewerIds: { type: [String], default: [] },
  reactions: { type: [reactionSchema], default: [] },
});

// ---------------------------------------------------------------------------
// Indexes
// ---------------------------------------------------------------------------
storySchema.index({ userId: 1, createdAt: -1 });
storySchema.index({ eventId: 1, createdAt: -1 });
storySchema.index({ expiresAt: 1 });

// ---------------------------------------------------------------------------
// toJSON – convert to snake_case matching Flutter StoryModel.fromJson
// ---------------------------------------------------------------------------
storySchema.set('toJSON', {
  transform: function (doc, ret) {
    return {
      story_id: ret.storyId,
      id: ret.storyId,
      user_id: ret.userId,
      user_name: ret.userName,
      userName: ret.userName,
      user_avatar: ret.userAvatar,
      userAvatar: ret.userAvatar,
      event_id: ret.eventId,
      eventId: ret.eventId,
      event_name: ret.eventName,
      eventName: ret.eventName,
      type: ret.type,
      media_url: ret.mediaUrl,
      mediaUrl: ret.mediaUrl,
      thumbnail_url: ret.thumbnailUrl,
      thumbnailUrl: ret.thumbnailUrl,
      caption: ret.caption,
      created_at: ret.createdAt,
      expires_at: ret.expiresAt,
      view_count: ret.viewCount,
      viewCount: ret.viewCount,
      viewer_ids: ret.viewerIds,
      viewerIds: ret.viewerIds,
      reactions: (ret.reactions || []).map(function (r) {
        return {
          reaction_id: r.reactionId,
          id: r.reactionId,
          user_id: r.userId,
          user_name: r.userName,
          userName: r.userName,
          user_avatar: r.userAvatar,
          userAvatar: r.userAvatar,
          emoji: r.emoji,
          created_at: r.createdAt,
        };
      }),
    };
  },
});

module.exports = mongoose.model('Story', storySchema);
