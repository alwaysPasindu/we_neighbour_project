const express = require('express');
const router = express.Router();
const { registerResident, getPendingRequests,approveResident,getResidentsForChat} = require('../controllers/residentController');
const {authenticate,isManager,isResident} = require('../middleware/authMiddleware');



router.post('/register', registerResident);
router.get('/pending',authenticate,isManager, getPendingRequests);
router.post('/check',authenticate,isManager, approveResident);
router.get('/chat-residents', authenticate, isResident, getResidentsForChat);

module.exports = router;