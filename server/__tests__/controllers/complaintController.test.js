const { createComplaint, getComplaints } = require('../../controllers/complaintController');
const { connectDB } = require('../../config/database');

jest.mock('../../config/database');

describe('Complaint Controller', () => {
  let mockReq, mockRes;

  beforeEach(() => {
    mockReq = {
      body: {},
      user: { id: 'resident123', apartmentComplexName: 'testApartment' },
    };
    mockRes = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn(),
    };
    jest.clearAllMocks();
  });

  describe('createComplaint', () => {
    it('should create a complaint successfully', async () => {
      mockReq.body = { title: 'Noisy Neighbor', description: 'Too loud at night' };
      const ResidentMock = { findById: jest.fn().mockResolvedValue({ apartmentCode: 'A101' }) };
      const ComplaintMock = jest.fn().mockImplementation(() => ({
        save: jest.fn().mockResolvedValue({}),
      }));
      connectDB.mockResolvedValue({
        model: jest.fn()
          .mockReturnValueOnce(ComplaintMock)
          .mockReturnValueOnce(ResidentMock),
      });

      await createComplaint(mockReq, mockRes);

      expect(connectDB).toHaveBeenCalledWith('testApartment');
      expect(ResidentMock.findById).toHaveBeenCalledWith('resident123');
      expect(mockRes.status).toHaveBeenCalledWith(201);
      expect(mockRes.json).toHaveBeenCalledWith({ message: 'Complaint submitted successfully!' });
    });

    it('should return 500 on server error', async () => {
      mockReq.body = { title: 'Noisy Neighbor', description: 'Too loud at night' };
      connectDB.mockRejectedValue(new Error('DB Error'));

      await createComplaint(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(500);
      expect(mockRes.json).toHaveBeenCalledWith({ message: 'Server Error' });
    });
  });

  describe('getComplaints', () => {
    it('should fetch all complaints successfully', async () => {
      const ComplaintMock = {
        find: jest.fn().mockReturnValue({
          sort: jest.fn().mockReturnValue({
            populate: jest.fn().mockResolvedValue([{ title: 'Test Complaint' }]),
          }),
        }),
      };
      connectDB.mockResolvedValue({
        model: jest.fn().mockReturnValue(ComplaintMock),
      });

      await getComplaints(mockReq, mockRes);

      expect(connectDB).toHaveBeenCalledWith('testApartment');
      expect(mockRes.json).toHaveBeenCalledWith([{ title: 'Test Complaint' }]);
    });

    it('should return 500 on server error', async () => {
      connectDB.mockRejectedValue(new Error('DB Error'));

      await getComplaints(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(500);
      expect(mockRes.json).toHaveBeenCalledWith({ message: 'Server Error' });
    });
  });
});