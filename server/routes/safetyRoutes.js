const express = require('express');
const { authenticate, isManager } = require('../middleware/authMiddleware');

const {
    createSafetyAlert,
    getSafetyAlerts,
    deleteSafetyAlert
} = require('../controllers/safetyAlertsController');

const router = express.Router();

router.post('/create-alerts', authenticate, isManager, createSafetyAlert);
router.get('/get-alerts', authenticate, getSafetyAlerts);
router.delete('/delete-alerts/:id', authenticate, isManager, deleteSafetyAlert);

module.exports = router;