const jwt = require('jsonwebtoken');

const authenticate = (req, res, next) => {
  // Case-insensitive header access
  const authHeader = req.headers['authorization'] || req.headers['Authorization'];
  console.log('Received Authorization Header:', authHeader);

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    console.log('No valid Bearer token found in request');
    return res.status(401).json({ message: 'No token, authorization failed' });
  }

  const token = authHeader.substring(7); // Remove "Bearer " prefix
  console.log('Extracted token:', token);

  if (!token) {
    console.log('Token extraction failed');
    return res.status(401).json({ message: 'No token, authorization failed' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    console.log('Token decoded:', decoded);
    req.user = decoded; // Attach decoded payload (id, role) to req
    next();
  } catch (err) {
    console.log('Token verification failed:', err.message);
    return res.status(401).json({ message: 'Token is not valid' });
  }
};

const isResident = (req, res, next) => {
  if (req.user.role !== 'resident') {
    return res.status(403).json({ message: 'Access denied. Residents only.' });
  }
  next();
};

const isManager = (req, res, next) => {
  if (req.user.role !== 'manager') {
    return res.status(403).json({ message: 'Access denied. Managers only.' });
  }
  next();
};

module.exports = { authenticate, isResident, isManager };