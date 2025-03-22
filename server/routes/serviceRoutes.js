const express = require('express');
const router = express.Router();
const { authenticate,isServiceProvider } = require('../middleware/authMiddleware');
const {
  createService,
  getService,
  editService,
  deleteService,
  addReview
  } = require('../controllers/serviceController');


router.post('/', authenticate,isServiceProvider, createService);
router.get('/', authenticate, getService);
router.put('/:id', authenticate,isServiceProvider, editService);
router.delete('/:id', authenticate, deleteService);
//router.get('/:id', authenticate, getService); 
router.post('/:id/reviews', authenticate, addReview); 

module.exports = router;