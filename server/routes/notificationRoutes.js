const express = require('express');
const {authenticate, isManager, isResident} = require('../middleware/authMiddleware');
const{
    createManagementNotification,
    getManagementNotifications,
    removeManagementNotification,
    createCommunityNotification,
    getCommunityNotifications,
    removeCommunityNotificationByManager,
    removeCommunityNotificationsFromUser,
    editCommunityNotification,
    deleteCommunityNotification,
} = require('../controllers/notificationController');

const router = express.Router();

router.post('/management',authenticate,isManager,createManagementNotification);
router.get('/Management',authenticate,getManagementNotifications);
router.delete('/management/:id',authenticate,isManager,removeManagementNotification);

router.post('/Community',authenticate,isResident,createCommunityNotification);
router.get('/Community',authenticate,getCommunityNotifications);
router.put('/Community/:id',authenticate,editCommunityNotification);

router.delete('/Community/:id',authenticate,deleteCommunityNotification);
router.delete('/Community/:id',authenticate,isManager,removeCommunityNotificationByManager);
router.delete('/Community/:id/remove-for-user',authenticate, removeCommunityNotificationsFromUser);

module.exports = router;