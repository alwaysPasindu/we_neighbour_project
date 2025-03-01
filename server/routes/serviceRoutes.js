const express = require('express');
const{authenticate,isResident,isManager} = require('../middleware/authMiddleware');
const {
    createService,
    getService,
    editService,
    deleteService
} = require('../controllers/serviceController');

const router = express.Router();

router.post('./create-service',authenticate,isResident,createService);
router.get('./get-service',authenticate,getService);
router.put('./edit-service/:id',authenticate,isResident,editService);
router.delete('./delete-service/:id',authenticate,isResident,isManager,deleteService);

module.exports = router;