const express = require('express');
const {authenticate, isManager, isResident} = require('../middleware/authMiddleware');
const{
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

router.post('/management',authenticate,isManager,createManagementNotification);
router.get('/management',authenticate,getManagementNotification);
router.delete('/management/:id',authenticate,isManager,removeManagementNotification);

router.post('/community',authenticate,isResident,createCommunityNotification);
router.get('/community',authenticate,getAllCommunityNotifications);
router.put('/community/:id',authenticate,editCommunityNotification);

router.delete('/community/:id',authenticate,deleteCommunityNotification);
router.delete('/community/remove-by-manager/:id',authenticate,isManager,removeCommunityNotificationByManager);
router.delete('/community/:id/remove-for-user',authenticate, removeCommunityNotificationsFromUser);

module.exports = router;