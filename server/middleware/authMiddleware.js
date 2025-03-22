const jwt = require('jsonwebtoken');

exports.authenticate = function (req, res, next) {
  const token = req.header('x-auth-token');
  if (!token) return res.status(401).json({ message: 'No token, authorization failed' });

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded; // { id, role, apartmentComplexName, status, iat, exp }
    next();
  } catch (err) {
    console.error('Authentication error:', err);
    if (err.name === 'TokenExpiredError') {
      return res.status(401).json({ message: 'Token expired' });
    }
    res.status(401).json({ message: 'Token is not valid' });
  }
};

exports.isResident = function (req, res, next) {
  if (req.user.role !== 'Resident') {
    return res.status(403).json({ message: 'Access denied. Not authorized as a Resident.' });
  }
  if (req.user.status !== 'approved') {
    return res.status(403).json({ message: 'Access denied. Your registration request is pending or rejected.' });
  }
  next();
};

exports.isManager = function (req, res, next) {
  if (req.user.role !== 'Manager') {
    return res.status(403).json({ message: 'Access denied. Not authorized as a Manager.' });
  }
  next();
};

exports.isServiceProvider = function (req, res, next) {
  if (req.user.role !== 'ServiceProvider') {
    return res.status(403).json({ message: 'Access denied. Not authorized as a Service Provider.' });
  }
  next();
};

exports.isResidentOrManager = function (req, res, next) {
  if (req.user.role === 'Resident' || req.user.role === 'Manager') {
    return next();
  }
  return res.status(403).json({ message: 'Access denied. Not authorized.' });
};




