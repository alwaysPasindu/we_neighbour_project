const {
    getSafetyAlerts,
    createSafetyAlert,
    deleteSafetyAlert,
  } = require('../../controllers/safetyAlertsController');
  const { connectDB } = require('../../config/database');
  
  jest.mock('../../config/database');
  
  describe('Safety Alerts Controller', () => {
    let mockReq, mockRes;
  
    beforeEach(() => {
      mockReq = {
        body: {},
        user: { id: 'manager123', apartmentComplexName: 'testApartment' },
        params: {},
      };
      mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };
      jest.clearAllMocks();
    });
  
    describe('getSafetyAlerts', () => {
      it('should fetch all safety alerts successfully', async () => {
        const SafetyAlertMock = {
          find: jest.fn().mockReturnValue({
            sort: jest.fn().mockReturnValue({
              populate: jest.fn().mockResolvedValue([{ title: 'Fire Alarm' }]),
            }),
          }),
        };
        connectDB.mockResolvedValue({
          model: jest.fn().mockReturnValue(SafetyAlertMock),
        });
  
        await getSafetyAlerts(mockReq, mockRes);
  
        expect(connectDB).toHaveBeenCalledWith('testApartment');
        expect(mockRes.json).toHaveBeenCalledWith([{ title: 'Fire Alarm' }]);
      });
  
      it('should return 500 on server error', async () => {
        connectDB.mockRejectedValue(new Error('DB Error'));
  
        await getSafetyAlerts(mockReq, mockRes);
  
        expect(mockRes.status).toHaveBeenCalledWith(500);
        expect(mockRes.json).toHaveBeenCalledWith({ message: 'Server Error', error: 'DB Error' });
      });
    });
  
    describe('createSafetyAlert', () => {
      it('should create a safety alert successfully', async () => {
        mockReq.body = { title: 'Fire Alarm', description: 'Smoke detected' };
        const SafetyAlertMock = jest.fn().mockImplementation(() => ({
          save: jest.fn().mockResolvedValue({}),
        }));
        connectDB.mockResolvedValue({
          model: jest.fn().mockReturnValue(SafetyAlertMock),
        });
  
        await createSafetyAlert(mockReq, mockRes);
  
        expect(connectDB).toHaveBeenCalledWith('testApartment');
        expect(mockRes.status).toHaveBeenCalledWith(201);
        expect(mockRes.json).toHaveBeenCalledWith({ message: 'Safety Alert created successfully!' });
      });
  
      it('should return 400 if title or description is missing', async () => {
        mockReq.body = { title: 'Fire Alarm' }; // Missing description
        await createSafetyAlert(mockReq, mockRes);
  
        expect(mockRes.status).toHaveBeenCalledWith(400);
        expect(mockRes.json).toHaveBeenCalledWith({ message: 'Title and description are required' });
      });
  
      it('should return 500 on server error', async () => {
        mockReq.body = { title: 'Fire Alarm', description: 'Smoke detected' };
        connectDB.mockRejectedValue(new Error('DB Error'));
  
        await createSafetyAlert(mockReq, mockRes);
  
        expect(mockRes.status).toHaveBeenCalledWith(500);
        expect(mockRes.json).toHaveBeenCalledWith({ message: 'Server Error', error: 'DB Error' });
      });
    });
  
    describe('deleteSafetyAlert', () => {
      it('should delete a safety alert successfully', async () => {
        mockReq.params = { id: 'alert123' };
        const SafetyAlertMock = {
          findById: jest.fn().mockResolvedValue({}),
          findByIdAndDelete: jest.fn().mockResolvedValue({}),
        };
        connectDB.mockResolvedValue({
          model: jest.fn().mockReturnValue(SafetyAlertMock),
        });
  
        await deleteSafetyAlert(mockReq, mockRes);
  
        expect(connectDB).toHaveBeenCalledWith('testApartment');
        expect(mockRes.json).toHaveBeenCalledWith({ message: 'Safety Alert deleted successfully!' });
      });
  
      it('should return 404 if alert not found', async () => {
        mockReq.params = { id: 'alert123' };
        const SafetyAlertMock = {
          findById: jest.fn().mockResolvedValue(null),
        };
        connectDB.mockResolvedValue({
          model: jest.fn().mockReturnValue(SafetyAlertMock),
        });
  
        await deleteSafetyAlert(mockReq, mockRes);
  
        expect(mockRes.status).toHaveBeenCalledWith(404);
        expect(mockRes.json).toHaveBeenCalledWith({ message: 'Alert not found' });
      });
  
      it('should return 500 on server error', async () => {
        mockReq.params = { id: 'alert123' };
        connectDB.mockRejectedValue(new Error('DB Error'));
  
        await deleteSafetyAlert(mockReq, mockRes);
  
        expect(mockRes.status).toHaveBeenCalledWith(500);
        expect(mockRes.json).toHaveBeenCalledWith({ message: 'Server Error', error: 'DB Error' });
      });
    });
  });