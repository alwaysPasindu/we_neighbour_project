const express = require('express');
const router = express.Router();
const { registerManager,approveManager } = require('../controllers/managerController');

router.post('/register', registerManager);
router.post('/approve',approveManager);

module.exports = router;