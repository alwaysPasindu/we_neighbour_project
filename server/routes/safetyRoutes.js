const express = require('express');
const{authenticate,isManager} = require('../middleware/authMiddleware');

const{
    createSafetyAlert,
    getSafetyAlerts,
    deleteSafetyAlert
} = require('../controllers/safetyAlertsController');

const router = express.Router();

router.post('/safety-alerts',authenticate,isManager,createSafetyAlert);
router.get('/safety-alerts',authenticate,getSafetyAlerts);
router.delete('/safety-alerts/:id',authenticate,isManager,deleteSafetyAlert);

module.exports = router;