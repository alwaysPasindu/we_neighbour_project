const express = require('express');
const router = express.Router();
const { registerManager } = require('../controllers/managerController');

router.post('/register', registerManager);

module.exports = router;