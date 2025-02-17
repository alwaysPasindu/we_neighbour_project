const express = require('express');
const {authenticate, isManager, isResident} = require('../middleware/authMiddleware');
const{
    createManagementNotification,
    getManagementNotifications,
    removeManagementNotification,
    createCommunityNotification,
    getCommunityNotifications,
    removeCommunityNotification,
    removeCommunityNotificationsFromUser,
} = require('../controllers/notificationController');

const router = express.Router();

router.post('/management',authenticate,isManager,createManagementNotification);
router.get('/Management',authenticate,getManagementNotifications);
router.delete('/management/:id',authenticate,isManager,removeManagementNotification);

router.post('/Community',authenticate,isResident,createCommunityNotification);
router.get('/Community',authenticate,getCommunityNotifications);
router.put('/Community/:id',authenticate,editCommunityNotification);
router.delete('/Community/:id',authenticate,removeCommunityNotification);
router.delete('/Community/:id',authenticate,isManager,removeCommunityNotification);
router.delete('/Community/:id/remove-for-user',authenticate, removeCommunityNotificationsFromUser);

module.exports = router;