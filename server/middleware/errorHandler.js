const errorHandler = (err, req, res, _next) => {
  const isProd = process.env.NODE_ENV === 'production';

  // Log error (keep minimal in production)
  if (isProd) {
    console.error('[ERROR]', err.message, req.method, req.path);
  } else {
    console.error('Error:', err.message, err.stack);
  }

  if (err.name === 'ValidationError') {
    const messages = Object.values(err.errors).map((e) => e.message);
    return res.status(400).json({ success: false, message: isProd ? 'Validation error' : messages.join(', ') });
  }

  if (err.code === 11000) {
    return res.status(409).json({ success: false, message: 'A record with this value already exists' });
  }

  if (err.name === 'CastError') {
    return res.status(400).json({ success: false, message: 'Invalid ID format' });
  }

  if (err.message === 'Invalid file type') {
    return res.status(400).json({ success: false, message: 'Invalid file type' });
  }

  if (err.code === 'LIMIT_FILE_SIZE') {
    return res.status(400).json({ success: false, message: 'File too large' });
  }

  const message = isProd
    ? 'Internal server error'
    : (err.message || 'Internal server error');
  res.status(err.status || 500).json({
    success: false,
    message,
  });
};

module.exports = errorHandler;
