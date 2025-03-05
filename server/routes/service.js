const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const serviceController = require('../controllers/serviceController');

const authMiddleware = (req, res, next) => {
  const token = req.header('Authorization')?.replace('Bearer ', '');
  if (!token) {
    return res.status(401).json({ message: 'No token provided' });
  }
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your_jwt_secret');
    req.user = decoded; // Ensure decoded includes { id, role }
    next();
  } catch (error) {
    res.status(401).json({ message: 'Invalid token' });
  }
};

router.post('/', authMiddleware, serviceController.createService);
router.get('/', authMiddleware, serviceController.getService); // For location-based services
router.get('/:id', authMiddleware, serviceController.getService); // For specific service by ID
router.put('/:id', authMiddleware, serviceController.editService);
router.delete('/:id', authMiddleware, serviceController.deleteService);
router.post('/:id/reviews', authMiddleware, serviceController.addReview);

module.exports = router;