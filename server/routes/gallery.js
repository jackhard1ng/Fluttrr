const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const upload = require('../middleware/upload');

// GET /api/gallery/list
router.get('/list', auth, async (req, res) => {
  try {
    const images = req.user.profile?.images || [];
    res.json({ success: true, data: images });
  } catch (error) {
    console.error('Get gallery error:', error);
    res.status(500).json({ success: false, message: 'Failed to get gallery' });
  }
});

// POST /api/gallery/upload
router.post('/upload', auth, upload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: 'No image provided' });
    }

    const imageUrl = `/uploads/${req.file.filename}`;
    const User = require('../models/User');

    // Limit gallery to 20 images to prevent abuse
    const user = await User.findById(req.userId);
    if (user && (user.profile?.images || []).length >= 20) {
      return res.status(400).json({ success: false, message: 'Maximum 20 gallery images allowed' });
    }

    await User.findByIdAndUpdate(req.userId, {
      $push: { 'profile.images': imageUrl },
    });

    res.json({ success: true, data: imageUrl, message: 'Image uploaded' });
  } catch (error) {
    console.error('Upload gallery error:', error);
    res.status(500).json({ success: false, message: 'Failed to upload image' });
  }
});

// DELETE /api/gallery/delete
router.delete('/delete', auth, async (req, res) => {
  try {
    const { imageUrl } = req.body;
    if (!imageUrl || typeof imageUrl !== 'string') {
      return res.status(400).json({ success: false, message: 'imageUrl is required' });
    }

    const User = require('../models/User');
    const user = await User.findById(req.userId);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const images = user.profile?.images || [];
    if (!images.includes(imageUrl)) {
      return res.status(404).json({ success: false, message: 'Image not found in gallery' });
    }

    await User.findByIdAndUpdate(req.userId, {
      $pull: { 'profile.images': imageUrl },
    });

    res.json({ success: true, message: 'Image removed from gallery' });
  } catch (error) {
    console.error('Delete gallery image error:', error);
    res.status(500).json({ success: false, message: 'Failed to delete image' });
  }
});

module.exports = router;
