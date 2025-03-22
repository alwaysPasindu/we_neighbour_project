const express = require('express');
const {authenticate,isResidentOrManager} = require('../middleware/authMiddleware');
const {
    createResourceRequest,
    getResourceRequest,
    deleteResourceRequest
} = require('../controllers/resourceController');

const router = express.Router();

router.post('/create-request',authenticate,createResourceRequest);
router.get('/get-request',authenticate,getResourceRequest);
router.delete('/delete-request/:id',authenticate,isResidentOrManager,deleteResourceRequest);

module.exports = router;