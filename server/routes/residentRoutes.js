const express = require('express');
const router = express.Router();
const { registerResident } = require('../controllers/residentController');



router.post('/register', registerResident);

module.exports = router;