const express = require('express');
const {authenticate, isResident} = require('../middleware/authMiddleware');
const {
    generateQRCodeData,
    verifyVisitor,
    updateVisitorStatus
} = require('../controllers/visitorController');

const router = express.Router();

router.post('/generate-qr',authenticate,isResident,generateQRCodeData);
router.get('/verify/:visitorId', verifyVisitor);
router.post('/update-status', updateVisitorStatus);

module.exports = router;