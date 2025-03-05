const mongoose = require('mongoose');
require('dotenv').config();

const dbConnections = {};

const centralDB = mongoose.createConnection(process.env.MONGO_URI, {
    dbName: 'central_db', // Central database name
    useNewUrlParser: true,
    useUnifiedTopology: true,
});

const connectDB = async (dbName) => {
    try {
        // Check if the connection already exists in the cache
        if (!dbConnections[dbName]) {
            const uri = process.env.MONGO_URI;

               // Create a new connection for the specified database
               const connection = await mongoose.createConnection(uri, {
                dbName, // Specify the database name here
            });

            //console.log(`Connected to database: ${dbName}`);
            dbConnections[dbName] = connection;
        }

        return dbConnections[dbName];
    } catch (err) {
        console.error('MongoDB connection error:', err);
        throw err;
    }
};

module.exports = {connectDB, centralDB};