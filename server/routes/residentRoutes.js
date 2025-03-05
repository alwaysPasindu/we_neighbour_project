const express = require('express');
const router = express.Router();
const { registerResident, getPendingRequests,approveResident} = require('../controllers/residentController');
const {authenticate,isManager} = require('../middleware/authMiddleware');



router.post('/register', registerResident);
router.get('/pending',authenticate,isManager, getPendingRequests);
router.post('/check',authenticate,isManager, approveResident);

module.exports = router;