const express = require('express');
const {
    generateQRCodeData,
    checkVisitor,
} = require('../controllers/visitorController');

const router = express.Router();

router.post('/generate-qr', generateQRCodeData);
router.post('/check-qr/:id', checkVisitor);

module.exports = router;