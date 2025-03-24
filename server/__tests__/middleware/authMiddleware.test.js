// __tests__/middleware/authMiddleware.test.js
const jwt = require('jsonwebtoken');
const { authenticate, isResident, isManager } = require('../../middleware/authMiddleware');

describe('Auth Middleware', () => {
  let mockReq, mockRes, mockNext;

  beforeEach(() => {
    mockReq = {
      header: jest.fn(),
    };
    mockRes = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn(),
    };
    mockNext = jest.fn();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('authenticate', () => {
    it('should call next() with a valid token', () => {
      mockReq.header.mockReturnValue('valid-token');
      jwt.verify.mockReturnValue({ id: 'user1', role: 'Resident' });

      authenticate(mockReq, mockRes, mockNext);

      expect(mockReq.header).toHaveBeenCalledWith('x-auth-token');
      expect(jwt.verify).toHaveBeenCalledWith('valid-token', process.env.JWT_SECRET);
      expect(mockReq.user).toEqual({ id: 'user1', role: 'Resident' });
      expect(mockNext).toHaveBeenCalled();
      expect(mockRes.status).not.toHaveBeenCalled();
    });

    it('should return 401 if no token is provided', () => {
      mockReq.header.mockReturnValue(null);

      authenticate(mockReq, mockRes, mockNext);

      expect(mockRes.status).toHaveBeenCalledWith(401);
      expect(mockRes.json).toHaveBeenCalledWith({ message: 'No token, authorization failed' });
      expect(mockNext).not.toHaveBeenCalled();
    });

    it('should return 401 if token is invalid', () => {
      mockReq.header.mockReturnValue('invalid-token');
      jwt.verify.mockImplementation(() => {
        throw new Error('Invalid token');
      });

      authenticate(mockReq, mockRes, mockNext);

      expect(mockRes.status).toHaveBeenCalledWith(401);
      expect(mockRes.json).toHaveBeenCalledWith({ message: 'Token is not valid' });
      expect(mockNext).not.toHaveBeenCalled();
    });
  });

  describe('isResident', () => {
    it('should call next() for a Resident with approved status', () => {
      mockReq.user = { role: 'Resident', status: 'approved' };

      isResident(mockReq, mockRes, mockNext);

      expect(mockNext).toHaveBeenCalled();
      expect(mockRes.status).not.toHaveBeenCalled();
    });

    it('should return 403 if role is not Resident', () => {
      mockReq.user = { role: 'Manager', status: 'approved' };

      isResident(mockReq, mockRes, mockNext);

      expect(mockRes.status).toHaveBeenCalledWith(403);
      expect(mockRes.json).toHaveBeenCalledWith({ message: 'Access denied. Not authorized as a Resident.' });
      expect(mockNext).not.toHaveBeenCalled();
    });

    it('should return 403 if status is not approved', () => {
      mockReq.user = { role: 'Resident', status: 'pending' };

      isResident(mockReq, mockRes, mockNext);

      expect(mockRes.status).toHaveBeenCalledWith(403);
      expect(mockRes.json).toHaveBeenCalledWith({ message: 'Access denied. Your registration request is pending or rejected.' });
      expect(mockNext).not.toHaveBeenCalled();
    });
  });

  describe('isManager', () => {
    it('should call next() for a Manager', () => {
      mockReq.user = { role: 'Manager' };

      isManager(mockReq, mockRes, mockNext);

      expect(mockNext).toHaveBeenCalled();
      expect(mockRes.status).not.toHaveBeenCalled();
    });

    it('should return 403 if role is not Manager', () => {
      mockReq.user = { role: 'Resident' };

      isManager(mockReq, mockRes, mockNext);

      expect(mockRes.status).toHaveBeenCalledWith(403);
      expect(mockRes.json).toHaveBeenCalledWith({ message: 'Access denied. Not authorized as a Manager.' });
      expect(mockNext).not.toHaveBeenCalled();
    });
  });
});