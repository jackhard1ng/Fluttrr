// Validate required secrets in production
if (process.env.NODE_ENV === 'production') {
  if (!process.env.JWT_SECRET || !process.env.JWT_REFRESH_SECRET) {
    console.error('FATAL: JWT_SECRET and JWT_REFRESH_SECRET must be set in production');
    process.exit(1);
  }
}

module.exports = {
  jwt: {
    secret: process.env.JWT_SECRET || 'fluttrr-dev-secret-DO-NOT-USE-IN-PROD',
    refreshSecret: process.env.JWT_REFRESH_SECRET || 'fluttrr-refresh-secret-DO-NOT-USE-IN-PROD',
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
    refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '30d',
  },
  email: {
    host: process.env.SMTP_HOST || 'smtp.gmail.com',
    port: parseInt(process.env.SMTP_PORT || '587'),
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
    from: process.env.EMAIL_FROM || 'noreply@fluttrr.com',
  },
  google: {
    clientId: process.env.GOOGLE_CLIENT_ID,
  },
  stripe: {
    secretKey: process.env.STRIPE_SECRET_KEY,
  },
  upload: {
    maxFileSize: parseInt(process.env.MAX_FILE_SIZE || '5242880'),
    dir: process.env.UPLOAD_DIR || 'uploads',
  },
};
