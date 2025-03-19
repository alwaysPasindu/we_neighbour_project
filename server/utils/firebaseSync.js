// utils/firebaseSync.js
const admin = require('firebase-admin'); // Import admin directly
const { db } = require('../config/firebase');

async function syncUserToFirebase(user, apartmentName) {
  try {
    const userData = {
      userId: user._id.toString(),
      name: user.name,
      email: user.email,
      role: user.role,
      apartmentName: apartmentName,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(), // Use admin here
    };

    await db.collection('apartments')
      .doc(apartmentName)
      .collection('users')
      .doc(user._id.toString())
      .set(userData);

    console.log(`User ${user._id} synced to Firebase for apartment ${apartmentName}`);
  } catch (error) {
    console.error(`Failed to sync user ${user._id} to Firebase:`, error);
    throw error; // Re-throw to catch it in the caller
  }
}

module.exports = { syncUserToFirebase };