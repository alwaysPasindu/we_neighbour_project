const bcrypt = require('bcrypt');
const { registerManager, createApartment, approveManager } = require('../../controllers/managerController');
const { connectDB, centralDB } = require('../../config/database');
const { syncUserToFirebase } = require('../../utils/firebaseSync');

jest.mock('../../config/database');
jest.mock('../../utils/firebaseSync');
jest.mock('bcrypt');

describe('Manager Controller', () => {
  let mockReq, mockRes;

  beforeEach(() => {
    mockReq = { body: {} };
    mockRes = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn(),
    };
    bcrypt.hash.mockResolvedValue('hashedPassword');
    jest.clearAllMocks();
  });

  describe('registerManager', () => {
    beforeEach(() => {
      mockReq.body = {
        name: 'Jane Doe',
        nic: '987654321V',
        email: 'jane@example.com',
        password: 'password123',
        phone: '0987654321',
        address: '456 Road',
        apartmentName: 'testApartment',
      };
    });

    it('should register a new manager successfully', async () => {
      const ApartmentMock = jest.fn().mockImplementation(() => ({ save: jest.fn().mockResolvedValue({}) }));
      ApartmentMock.findOne = jest.fn().mockResolvedValue(null);
      const CentralManagerMock = jest.fn().mockImplementation(() => ({ save: jest.fn().mockResolvedValue({}) }));
      CentralManagerMock.findOne = jest.fn().mockResolvedValue(null);
      const ManagerMock = jest.fn().mockImplementation(() => ({ save: jest.fn().mockResolvedValue({}) }));

      centralDB.model.mockImplementation((name) => {
        if (name === 'Apartment') return ApartmentMock;
        if (name === 'CentralManager') return CentralManagerMock;
      });
      connectDB.mockResolvedValue({
        model: jest.fn().mockReturnValue(ManagerMock),
      });

      await registerManager(mockReq, mockRes);

      expect(connectDB).toHaveBeenCalledWith('testApartment');
      expect(bcrypt.hash).toHaveBeenCalledWith('password123', 10);
      expect(mockRes.status).toHaveBeenCalledWith(201);
      expect(mockRes.json).toHaveBeenCalledWith({ message: 'Manager registered successfully!' });
    });

    it('should return 400 if apartment already exists', async () => {
      const ApartmentMock = jest.fn().mockImplementation(() => ({ save: jest.fn().mockResolvedValue({}) }));
      ApartmentMock.findOne = jest.fn().mockResolvedValue({ apartmentName: 'testApartment' });

      centralDB.model.mockImplementation((name) => {
        if (name === 'Apartment') return ApartmentMock;
      });

      await registerManager(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.json).toHaveBeenCalledWith({ message: 'Apartment already exists' });
    });

    

    it('should return 500 on server error', async () => {
      const ApartmentMock = jest.fn().mockImplementation(() => ({ save: jest.fn().mockResolvedValue({}) }));
      ApartmentMock.findOne = jest.fn().mockRejectedValue(new Error('DB Error'));

      centralDB.model.mockImplementation((name) => {
        if (name === 'Apartment') return ApartmentMock;
      });

      await registerManager(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(500);
      expect(mockRes.json).toHaveBeenCalledWith({ message: 'Server error' });
    });
  });

  describe('createApartment', () => {
    beforeEach(() => {
      mockReq.body = { apartmentName: 'newApartment' };
    });

    it('should create a new apartment successfully', async () => {
      const ApartmentMock = jest.fn().mockImplementation(() => ({ save: jest.fn().mockResolvedValue({}) }));
      ApartmentMock.findOne = jest.fn().mockResolvedValue(null);

      centralDB.model.mockReturnValue(ApartmentMock);

      await createApartment(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(201);
      expect(mockRes.json).toHaveBeenCalledWith({ message: 'Apartment created successfully!' });
    });

    it('should return 400 if apartment already exists', async () => {
      const ApartmentMock = jest.fn().mockImplementation(() => ({ save: jest.fn().mockResolvedValue({}) }));
      ApartmentMock.findOne = jest.fn().mockResolvedValue({ apartmentName: 'newApartment' });

      centralDB.model.mockReturnValue(ApartmentMock);

      await createApartment(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.json).toHaveBeenCalledWith({ message: 'Apartment already exists' });
    });

    it('should return 500 on server error', async () => {
      const ApartmentMock = jest.fn().mockImplementation(() => ({ save: jest.fn().mockResolvedValue({}) }));
      ApartmentMock.findOne = jest.fn().mockRejectedValue(new Error('DB Error'));

      centralDB.model.mockReturnValue(ApartmentMock);

      await createApartment(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(500);
      expect(mockRes.json).toHaveBeenCalledWith({ message: 'Server error', error: expect.any(String) });
    });
  });

  describe('approveManager', () => {
    beforeEach(() => {
      mockReq.body = { managerId: '123', status: 'approved' };
    });

    it('should return 400 for invalid input', async () => {
      mockReq.body.status = 'invalid';
      centralDB.model.mockReturnValue({
        findById: jest.fn(),
      });

      await approveManager(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.json).toHaveBeenCalledWith({ message: 'Invalid input' });
    });

    it('should return 404 if manager not found', async () => {
      centralDB.model.mockReturnValue({
        findById: jest.fn().mockResolvedValue(null),
      });

      await approveManager(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(404);
      expect(mockRes.json).toHaveBeenCalledWith({ message: 'Manager not found' });
    });

    
  });
});