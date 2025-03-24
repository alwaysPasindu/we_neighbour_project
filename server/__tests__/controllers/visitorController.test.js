const {
  generateQRCodeData,
  verifyVisitor,
  updateVisitorStatus,
} = require('../../controllers/visitorController');
const { connectDB } = require('../../config/database');

jest.mock('../../config/database');

describe('Visitor Controller', () => {
  let mockReq, mockRes;

  beforeEach(() => {
    mockReq = {
      body: {},
      user: { id: 'resident123', apartmentComplexName: 'testApartment' },
      params: {},
      headers: {},
      query: {},
    };
    mockRes = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn(),
      send: jest.fn(),
    };
    process.env.BASE_URL = 'http://localhost:3000';
    jest.clearAllMocks();
  });

  describe('generateQRCodeData', () => {
    it('should generate QR code data successfully', async () => {
      mockReq.body = { numOfVisitors: 2, visitorNames: ['John', 'Jane'] };
      const ResidentMock = { findById: jest.fn().mockResolvedValue({ name: 'Resident', apartmentCode: 'A101', phone: '1234567890', apartmentComplexName: 'testApartment' }) };
      const VisitorMock = jest.fn().mockImplementation(() => ({
        _id: 'visitor123',
        save: jest.fn().mockResolvedValue({ _id: 'visitor123' }),
      }));
      connectDB.mockResolvedValue({
        model: jest.fn()
          .mockReturnValueOnce(VisitorMock)
          .mockReturnValueOnce(ResidentMock),
      });

      await generateQRCodeData(mockReq, mockRes);

      expect(connectDB).toHaveBeenCalledWith('testApartment');
      expect(ResidentMock.findById).toHaveBeenCalledWith('resident123');
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        qrUrl: 'http://localhost:3000/api/visitor/verify/visitor123?apartment=testApartment',
        visitorId: 'visitor123',
      });
    });

    it('should return 500 on server error', async () => {
      mockReq.body = { numOfVisitors: 2 };
      connectDB.mockRejectedValue(new Error('DB Error'));

      await generateQRCodeData(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(500);
      expect(mockRes.json).toHaveBeenCalledWith({ message: 'Server error', error: 'DB Error' });
    });
  });

  describe('verifyVisitor', () => {
    
    it('should return 400 if apartment name is missing', async () => {
      mockReq.params = { visitorId: 'visitor123' };
      mockReq.query = {};

      await verifyVisitor(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.send).toHaveBeenCalledWith('<h1>Missing apartment name</h1>');
    });

    it('should return 404 if visitor not found', async () => {
      mockReq.params = { visitorId: 'visitor123' };
      mockReq.query = { apartment: 'testApartment' };
      const VisitorMock = { findById: jest.fn().mockResolvedValue(null) };
      connectDB.mockResolvedValue({
        model: jest.fn().mockReturnValue(VisitorMock),
      });

      await verifyVisitor(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(404);
      expect(mockRes.send).toHaveBeenCalledWith('<h1>Invalid QR Code</h1>');
    });

    it('should return 400 if QR code already processed', async () => {
      mockReq.params = { visitorId: 'visitor123' };
      mockReq.query = { apartment: 'testApartment' };
      const VisitorMock = { findById: jest.fn().mockResolvedValue({ status: 'Approved' }) };
      connectDB.mockResolvedValue({
        model: jest.fn().mockReturnValue(VisitorMock),
      });

      await verifyVisitor(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.send).toHaveBeenCalledWith('<h1>QR Code Already Processed: Approved</h1>');
    });
  });

  describe('updateVisitorStatus', () => {
    it('should approve a visitor successfully', async () => {
      mockReq.body = { visitorId: 'visitor123', action: 'approve' };
      mockReq.headers['x-apartment-name'] = 'testApartment';
      const VisitorMock = {
        findById: jest.fn().mockResolvedValue({
          status: 'Pending',
          save: jest.fn().mockResolvedValue({}),
        }),
      };
      connectDB.mockResolvedValue({
        model: jest.fn().mockReturnValue(VisitorMock),
      });

      await updateVisitorStatus(mockReq, mockRes);

      expect(connectDB).toHaveBeenCalledWith('testApartment');
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        message: 'Visitor accepted',
      });
    });

    it('should reject a visitor successfully', async () => {
      mockReq.body = { visitorId: 'visitor123', action: 'reject' };
      mockReq.headers['x-apartment-name'] = 'testApartment';
      const VisitorMock = {
        findById: jest.fn().mockResolvedValue({
          status: 'Pending',
          save: jest.fn().mockResolvedValue({}),
        }),
      };
      connectDB.mockResolvedValue({
        model: jest.fn().mockReturnValue(VisitorMock),
      });

      await updateVisitorStatus(mockReq, mockRes);

      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        message: 'Visitor rejected',
      });
    });

    it('should return 400 if action is invalid', async () => {
      mockReq.body = { visitorId: 'visitor123', action: 'invalid' };
      mockReq.headers['x-apartment-name'] = 'testApartment';

      await updateVisitorStatus(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.json).toHaveBeenCalledWith({ message: 'Visitor ID, apartment name, and valid action are required' });
    });

    it('should return 404 if visitor not found', async () => {
      mockReq.body = { visitorId: 'visitor123', action: 'approve' };
      mockReq.headers['x-apartment-name'] = 'testApartment';
      const VisitorMock = { findById: jest.fn().mockResolvedValue(null) };
      connectDB.mockResolvedValue({
        model: jest.fn().mockReturnValue(VisitorMock),
      });

      await updateVisitorStatus(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(404);
      expect(mockRes.json).toHaveBeenCalledWith({ message: 'Invalid QR code' });
    });

    it('should return 400 if QR code already processed', async () => {
      mockReq.body = { visitorId: 'visitor123', action: 'approve' };
      mockReq.headers['x-apartment-name'] = 'testApartment';
      const VisitorMock = { findById: jest.fn().mockResolvedValue({ status: 'Approved' }) };
      connectDB.mockResolvedValue({
        model: jest.fn().mockReturnValue(VisitorMock),
      });

      await updateVisitorStatus(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.json).toHaveBeenCalledWith({ message: 'QR code already processed' });
    });
  });
});