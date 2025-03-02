const express = require('express');
const router = express.Router();
const { registerServiceProvider } = require('../controllers/serviceproviderController');

router.post('/register', registerServiceProvider);

module.exports = router;
