const mongoose = require('mongoose');

const connectDB = async (retries = 5) => {
  const mongoUri = process.env.MONGODB_URI;

  // In production, require explicit MONGODB_URI
  if (!mongoUri && process.env.NODE_ENV === 'production') {
    console.error('MONGODB_URI environment variable is required in production. Exiting.');
    process.exit(1);
  }

  const uri = mongoUri || 'mongodb://localhost:27017/fluttrr';

  for (let attempt = 1; attempt <= retries; attempt++) {
    try {
      const conn = await mongoose.connect(uri, {
        serverSelectionTimeoutMS: 10000,
        socketTimeoutMS: 45000,
        connectTimeoutMS: 10000,
        maxPoolSize: 25,
      });
      console.log(`MongoDB connected: ${conn.connection.host}`);

      // Monitor connection events for production visibility
      mongoose.connection.on('error', (err) => {
        console.error('MongoDB connection error:', err.message);
      });
      mongoose.connection.on('disconnected', () => {
        console.warn('MongoDB disconnected. Reconnecting...');
      });
      mongoose.connection.on('reconnected', () => {
        console.log('MongoDB reconnected');
      });

      return;
    } catch (error) {
      console.error(`MongoDB connection attempt ${attempt}/${retries} failed: ${error.message}`);
      if (attempt === retries) {
        console.error('All MongoDB connection attempts exhausted. Exiting.');
        process.exit(1);
      }
      // Exponential backoff with jitter: ~2s, ~4s, ~8s, ~16s
      const delay = Math.min(1000 * Math.pow(2, attempt), 16000) + Math.floor(Math.random() * 1000);
      console.log(`Retrying in ${Math.round(delay / 1000)}s...`);
      await new Promise((resolve) => setTimeout(resolve, delay));
    }
  }
};

module.exports = connectDB;
