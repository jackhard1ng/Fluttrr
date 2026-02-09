const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');

// ---------------------------------------------------------------------------
// Sub-schemas
// ---------------------------------------------------------------------------

// Flutter PhotoTagModel.fromJson reads (snake_case):
//   tag_id, user_id, user_name, user_avatar, x_position, y_position
const photoTagSchema = new mongoose.Schema(
  {
    tagId: { type: String, default: uuidv4 },
    userId: { type: String, required: true },
    userName: { type: String, default: '' },
    userAvatar: { type: String, default: null },
    xPosition: { type: Number, default: 0.5, min: 0, max: 1 },
    yPosition: { type: Number, default: 0.5, min: 0, max: 1 },
  },
  { _id: false }
);

// Flutter MemoryPhotoModel.fromJson reads (snake_case):
//   photo_id (or id), url, thumbnail_url, width, height, description, tags, uploaded_at
const photoSchema = new mongoose.Schema(
  {
    photoId: { type: String, default: uuidv4 },
    url: { type: String, required: true },
    thumbnailUrl: { type: String, default: null },
    width: { type: Number, default: 0 },
    height: { type: Number, default: 0 },
    description: { type: String, default: null },
    tags: { type: [photoTagSchema], default: [] },
    uploadedAt: { type: Date, default: Date.now },
  },
  { _id: false }
);

// Flutter MemoryCommentModel.fromJson reads (snake_case):
//   comment_id (or id), memory_id, user_id, user_name, user_avatar,
//   content, created_at, like_count, is_liked_by_me
const commentSchema = new mongoose.Schema(
  {
    commentId: { type: String, default: uuidv4 },
    memoryId: { type: String, default: null },
    userId: { type: String, required: true },
    userName: { type: String, default: '' },
    userAvatar: { type: String, default: null },
    content: { type: String, required: true, maxlength: 1000 },
    createdAt: { type: Date, default: Date.now },
    likeCount: { type: Number, default: 0, min: 0 },
    likedBy: { type: [String], default: [] },
  },
  { _id: false }
);

// ---------------------------------------------------------------------------
// Memory schema
// ---------------------------------------------------------------------------
// Flutter EventMemoryModel.fromJson reads (snake_case):
//   memory_id (or id), event_id, event_name, uploader_id, uploader_name,
//   uploader_avatar, photos, caption, like_count, is_liked_by_me,
//   recent_comments, comment_count, created_at, event_date, is_approved, is_featured

const memorySchema = new mongoose.Schema({
  memoryId: { type: String, default: uuidv4, unique: true, index: true },
  eventId: { type: String, required: true, index: true },
  eventName: { type: String, default: '' },
  uploaderId: { type: Number, required: true, index: true },
  uploaderName: { type: String, default: 'Unknown' },
  uploaderAvatar: { type: String, default: null },
  photos: { type: [photoSchema], default: [] },
  caption: { type: String, default: null, maxlength: 2000 },
  likeCount: { type: Number, default: 0, min: 0 },
  likedBy: { type: [String], default: [] },
  commentCount: { type: Number, default: 0, min: 0 },
  comments: { type: [commentSchema], default: [] },
  isApproved: { type: Boolean, default: true },
  isFeatured: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now },
  eventDate: { type: Date, required: true },
});

// ---------------------------------------------------------------------------
// Indexes
// ---------------------------------------------------------------------------
memorySchema.index({ eventId: 1, createdAt: -1 });
memorySchema.index({ uploaderId: 1 });
memorySchema.index({ isFeatured: 1 });

// ---------------------------------------------------------------------------
// toJSON – convert to snake_case matching Flutter EventMemoryModel.fromJson
// ---------------------------------------------------------------------------
memorySchema.set('toJSON', {
  transform: function (doc, ret) {
    return {
      memory_id: ret.memoryId,
      id: ret.memoryId,
      event_id: ret.eventId,
      event_name: ret.eventName,
      uploader_id: ret.uploaderId,
      uploader_name: ret.uploaderName,
      uploader_avatar: ret.uploaderAvatar,
      photos: (ret.photos || []).map(function (p) {
        return {
          photo_id: p.photoId,
          id: p.photoId,
          url: p.url,
          thumbnail_url: p.thumbnailUrl,
          width: p.width,
          height: p.height,
          description: p.description,
          tags: (p.tags || []).map(function (t) {
            return {
              tag_id: t.tagId,
              user_id: t.userId,
              user_name: t.userName,
              user_avatar: t.userAvatar,
              x_position: t.xPosition,
              y_position: t.yPosition,
            };
          }),
          uploaded_at: p.uploadedAt,
        };
      }),
      caption: ret.caption,
      like_count: ret.likeCount,
      liked_by: ret.likedBy,
      comment_count: ret.commentCount,
      recent_comments: (ret.comments || []).map(function (c) {
        return {
          comment_id: c.commentId,
          id: c.commentId,
          memory_id: c.memoryId || ret.memoryId,
          user_id: c.userId,
          user_name: c.userName,
          user_avatar: c.userAvatar,
          content: c.content,
          created_at: c.createdAt,
          like_count: c.likeCount,
          liked_by: c.likedBy,
        };
      }),
      is_approved: ret.isApproved,
      is_featured: ret.isFeatured,
      created_at: ret.createdAt,
      event_date: ret.eventDate,
    };
  },
});

// ---------------------------------------------------------------------------
// Convenience: API response with user-specific is_liked_by_me
// ---------------------------------------------------------------------------
memorySchema.methods.toApiResponse = function (requestingUserId) {
  var json = this.toJSON();
  var uid = requestingUserId ? String(requestingUserId) : null;
  json.is_liked_by_me = uid ? this.likedBy.includes(uid) : false;
  if (json.recent_comments) {
    json.recent_comments = json.recent_comments.map(function (c) {
      c.is_liked_by_me = uid ? (c.liked_by || []).includes(uid) : false;
      return c;
    });
  }
  return json;
};

module.exports = mongoose.model('Memory', memorySchema);
