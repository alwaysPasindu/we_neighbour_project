const express = require('express');
const{authenticate,isManager,isServiceProvider} = require('../middleware/authMiddleware');
const {
    createService,
    getService,
    editService,
    deleteService
} = require('../controllers/serviceController');

const router = express.Router();

router.post('/create-service',authenticate,isServiceProvider,createService);
router.get('/get-service',authenticate,getService);
router.put('/edit-service/:id',authenticate,isServiceProvider,editService);
router.delete('/delete-service/:id',authenticate,isServiceProvider,deleteService);

module.exports = router;