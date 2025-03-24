const mongoose = require('mongoose');
require('dotenv').config();

const dbConnections = {};

const centralDB = mongoose.createConnection(process.env.MONGO_URI, {
  dbName: 'central_db',
});

const connectDB = async (dbName) => {
  try {
    if (!dbConnections[dbName]) {
      const uri = process.env.MONGO_URI;
      const connection = await mongoose.createConnection(uri, {
        dbName,
      });
      // console.log(`Connected to database: ${dbName}`);
      dbConnections[dbName] = connection;
    }
    return dbConnections[dbName];
  } catch (err) {
    console.error('MongoDB connection error:', err);
    throw err;
  }
};

module.exports = { connectDB, centralDB, dbConnections };