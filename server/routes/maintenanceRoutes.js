const express = require('express');
const {authenticate,isManager,isResident} =require('../middleware/authMiddleware');
const {
    createMaintenanceRequest,
    getPendingrequests,
    markRequests,
    getCompletedRequests,
    rateMaintenanceRequest
} = require('../controllers/maintenanceController');

const router = express.Router();

router.post('/create-request',authenticate,isResident,createMaintenanceRequest);
router.get('/get-pending-request',authenticate,isManager,getPendingrequests);
router.put('/mark-request/:id/done',authenticate,isManager,markRequests);
router.get('/get-completed-request',authenticate,getCompletedRequests);
router.post('/rate/:id',authenticate,rateMaintenanceRequest);

module.exports = router;