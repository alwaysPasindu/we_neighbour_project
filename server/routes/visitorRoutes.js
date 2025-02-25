const express = require('express');
const {authenticate, isResident} = require('../middleware/authMiddleware');
const {
    generateQRCodeData,
    checkVisitor,
} = require('../controllers/visitorController');

const router = express.Router();

router.post('/generate-qr',authenticate,isResident,generateQRCodeData);

router.post('/check-qr/:id',checkVisitor);

module.exports = router;