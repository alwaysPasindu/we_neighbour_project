require('dotenv').config();
const admin = require('firebase-admin');
//const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);

const serviceAccount = require('../serviceAccountKey.json');
// Decode the Base64-encoded JSON
/*
const serviceAccount = JSON.parse(
  Buffer.from(process.env.FIREBASE_SERVICE_ACCOUNT, 'base64').toString('utf8')
);
*/
// Initialize Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

console.log("Firebase Admin initialized successfully!");
module.exports = { admin, db }; 
