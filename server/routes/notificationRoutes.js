const express = require('express');
const { authenticate, isManager, isResident } = require('../middleware/authMiddleware');

const {
  createManagementNotification,
  getManagementNotification,
  removeManagementNotification,
  createCommunityNotification,
  getAllCommunityNotifications,
  removeCommunityNotificationByManager,
  removeCommunityNotificationsFromUser,
  editCommunityNotification,
  deleteCommunityNotification,
} = require('../controllers/notificationController');

const router = express.Router();

// Management Notifications (Manager-only routes)
router.post('/management', authenticate, isManager, createManagementNotification);
router.get('/management', authenticate, getManagementNotification);
router.delete('/management/:id', authenticate, isManager, removeManagementNotification);

// Community Notifications (Resident-only for creation/editing, Manager for removal, all authenticated for viewing)
router.post('/community', authenticate, isResident, createCommunityNotification);
router.get('/community', authenticate, getAllCommunityNotifications);
router.put('/community/:id', authenticate, isResident, editCommunityNotification);
router.delete('/community/:id', authenticate, isResident, deleteCommunityNotification); // Resident (creator only)
router.delete('/community/remove-by-manager/:id', authenticate, isManager, removeCommunityNotificationByManager); // Manager
router.delete('/community/:id/remove-for-user', authenticate, removeCommunityNotificationsFromUser); // Any authenticated user

module.exports = router;