// utils/firebaseSync.js
const { admin, db } = require('../config/firebase');

async function syncUserToFirebase(user, apartmentName) {
  const userData = {
    userId: user._id.toString(),
    name: user.name,
    email: user.email,
    role: user.role,
    apartmentName: apartmentName,
    lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
  };

  // Store in Firestore under apartment-specific collection
  await db.collection('apartments')
    .doc(apartmentName)
    .collection('users')
    .doc(user._id.toString())
    .set(userData);

  console.log(`User ${user._id} synced to Firebase for apartment ${apartmentName}`);
}

module.exports = { syncUserToFirebase };