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

    await User.findByIdAndUpdate(req.userId, {
      $push: { 'profile.images': imageUrl },
    });

    res.json({ success: true, data: imageUrl, message: 'Image uploaded' });
  } catch (error) {
    console.error('Upload gallery error:', error);
    res.status(500).json({ success: false, message: 'Failed to upload image' });
  }
});

module.exports = router;
