const nodemailer = require('nodemailer');
const config = require('../config/config');

let transporter;

const getTransporter = () => {
  if (!transporter) {
    // If SMTP credentials are configured, use them
    if (config.email.user && config.email.pass) {
      transporter = nodemailer.createTransport({
        host: config.email.host,
        port: config.email.port,
        secure: config.email.port === 465,
        auth: {
          user: config.email.user,
          pass: config.email.pass,
        },
      });
    } else {
      // Fallback: log emails to console (development mode)
      console.log('Email not configured - OTPs will be logged to console');
      transporter = {
        sendMail: async (options) => {
          console.log('=== EMAIL (not sent - no SMTP configured) ===');
          console.log(`To: ${options.to}`);
          console.log(`Subject: ${options.subject}`);
          console.log(`Body: ${options.text || options.html}`);
          console.log('=============================================');
          return { messageId: 'console-' + Date.now() };
        },
      };
    }
  }
  return transporter;
};

const sendOtpEmail = async (email, otp, type = 'verification') => {
  const subjects = {
    verification: 'Verify your Fluttrr account',
    passwordReset: 'Reset your Fluttrr password',
    businessVerification: 'Verify your Fluttrr business',
  };

  const messages = {
    verification: `Your Fluttrr verification code is: ${otp}\n\nThis code expires in 10 minutes.`,
    passwordReset: `Your password reset code is: ${otp}\n\nThis code expires in 10 minutes.\n\nIf you didn't request this, please ignore this email.`,
    businessVerification: `Your business verification code is: ${otp}\n\nThis code expires in 10 minutes.`,
  };

  const mail = getTransporter();
  await mail.sendMail({
    from: config.email.from,
    to: email,
    subject: subjects[type] || 'Fluttrr Verification Code',
    text: messages[type] || `Your code is: ${otp}`,
  });
};

module.exports = { sendOtpEmail };
