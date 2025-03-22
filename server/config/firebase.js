// config/firebase.js
const admin = require('firebase-admin');
require('dotenv').config();

const serviceAccount = require('../serviceAccountKey.json'); // Path to your service account key

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

module.exports = { db };