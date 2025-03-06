const express = require('express');
const router = express.Router();
const apartmentController = require('../controllers/apartmentController');

// Fetch all apartment names
router.get('/get-names', apartmentController.getAllApartments);

module.exports = router;