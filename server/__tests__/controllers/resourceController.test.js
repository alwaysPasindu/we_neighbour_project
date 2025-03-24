const {
    createResourceRequest,
    getResourceRequest,
    deleteResourceRequest,
  } = require('../../controllers/resourceController');
  const { connectDB } = require('../../config/database');
  
  jest.mock('../../config/database');
  
  describe('Resource Controller', () => {
    let mockReq, mockRes;
  
    beforeEach(() => {
      mockReq = {
        body: {},
        user: { id: 'resident123', apartmentComplexName: 'testApartment', role: 'Resident' },
        params: {},
      };
      mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };
      jest.clearAllMocks();
    });
  
    describe('createResourceRequest', () => {
      it('should create a resource request successfully', async () => {
        mockReq.body = { resourceName: 'Lawnmower', description: 'For yard work', quantity: 1 };
        const ResidentMock = { findById: jest.fn().mockResolvedValue({ name: 'Jane Doe', apartmentCode: 'A101' }) };
        const ResourceMock = jest.fn().mockImplementation(() => ({
          save: jest.fn().mockResolvedValue({}),
        }));
        connectDB.mockResolvedValue({
          model: jest.fn()
            .mockReturnValueOnce(ResourceMock)
            .mockReturnValueOnce(ResidentMock),
        });
  
        await createResourceRequest(mockReq, mockRes);
  
        expect(connectDB).toHaveBeenCalledWith('testApartment');
        expect(ResidentMock.findById).toHaveBeenCalledWith('resident123');
        expect(mockRes.status).toHaveBeenCalledWith(201);
        expect(mockRes.json).toHaveBeenCalledWith({ message: 'Resource request cereated successfully' });
      });
  
      it('should return 500 on server error', async () => {
        mockReq.body = { resourceName: 'Lawnmower', description: 'For yard work', quantity: 1 };
        connectDB.mockRejectedValue(new Error('DB Error'));
  
        await createResourceRequest(mockReq, mockRes);
  
        expect(mockRes.status).toHaveBeenCalledWith(500);
        expect(mockRes.json).toHaveBeenCalledWith({ message: 'Server Error' });
      });
    });
  
    describe('getResourceRequest', () => {
      it('should fetch active resource requests successfully', async () => {
        const ResourceMock = {
          find: jest.fn().mockReturnValue({
            sort: jest.fn().mockReturnValue({
              populate: jest.fn().mockResolvedValue([{ resourceName: 'Lawnmower' }]),
            }),
          }),
        };
        connectDB.mockResolvedValue({
          model: jest.fn().mockReturnValue(ResourceMock),
        });
  
        await getResourceRequest(mockReq, mockRes);
  
        expect(connectDB).toHaveBeenCalledWith('testApartment');
        expect(ResourceMock.find).toHaveBeenCalledWith({ status: 'Active' });
        expect(mockRes.json).toHaveBeenCalledWith([{ resourceName: 'Lawnmower' }]);
      });
  
      it('should return 500 on server error', async () => {
        connectDB.mockRejectedValue(new Error('DB Error'));
  
        await getResourceRequest(mockReq, mockRes);
  
        expect(mockRes.status).toHaveBeenCalledWith(500);
        expect(mockRes.json).toHaveBeenCalledWith({ message: 'Server Error' });
      });
    });
  
    describe('deleteResourceRequest', () => {
      it('should delete a resource request successfully as creator', async () => {
        mockReq.params = { id: 'request123' };
        const request = {
          resident: 'resident123',
          status: 'Active',
          save: jest.fn().mockResolvedValue({}),
        };
        const ResourceMock = {
          findById: jest.fn().mockResolvedValue(request),
        };
        connectDB.mockResolvedValue({
          model: jest.fn().mockReturnValue(ResourceMock),
        });
  
        await deleteResourceRequest(mockReq, mockRes);
  
        expect(connectDB).toHaveBeenCalledWith('testApartment');
        expect(request.status).toBe('Deleted');
        expect(request.save).toHaveBeenCalled();
        expect(mockRes.json).toHaveBeenCalledWith({ message: 'Resource request deleted successfully' });
      });
  
      it('should delete a resource request successfully as manager', async () => {
        mockReq.params = { id: 'request123' };
        mockReq.user.role = 'Manager';
        const request = {
          resident: 'otherResident',
          status: 'Active',
          save: jest.fn().mockResolvedValue({}),
        };
        const ResourceMock = {
          findById: jest.fn().mockResolvedValue(request),
        };
        connectDB.mockResolvedValue({
          model: jest.fn().mockReturnValue(ResourceMock),
        });
  
        await deleteResourceRequest(mockReq, mockRes);
  
        expect(request.status).toBe('Deleted');
        expect(mockRes.json).toHaveBeenCalledWith({ message: 'Resource request deleted successfully' });
      });
  
      it('should return 403 if not authorized', async () => {
        mockReq.params = { id: 'request123' };
        const ResourceMock = {
          findById: jest.fn().mockResolvedValue({ resident: 'otherResident' }),
        };
        connectDB.mockResolvedValue({
          model: jest.fn().mockReturnValue(ResourceMock),
        });
  
        await deleteResourceRequest(mockReq, mockRes);
  
        expect(mockRes.status).toHaveBeenCalledWith(403);
        expect(mockRes.json).toHaveBeenCalledWith({ message: 'You are not authorized to delete this resource request' });
      });
  
      it('should return 500 on server error', async () => {
        mockReq.params = { id: 'request123' };
        connectDB.mockRejectedValue(new Error('DB Error'));
  
        await deleteResourceRequest(mockReq, mockRes);
  
        expect(mockRes.status).toHaveBeenCalledWith(500);
        expect(mockRes.json).toHaveBeenCalledWith({ message: 'Server Error' });
      });
    });
  });