const express = require('express');
const {authenticate,isManager} = require('../middleware/authMiddleware');
const {createComplaint, getComplaints} = require('../controllers/complaintController');
const router = express.Router();

router.post('/create-complaints',authenticate,createComplaint);
router.get('/get-complaints',authenticate,isManager,getComplaints);

module.exports = router;