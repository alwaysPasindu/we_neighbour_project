const {
    createManagementNotification,
    getManagementNotification,
    removeManagementNotification,
    createCommunityNotification,
    getAllCommunityNotifications,
    removeCommunityNotificationByManager,
    deleteCommunityNotification,
    removeCommunityNotificationsFromUser,
    editCommunityNotification,
  } = require('../../controllers/notificationController');
  const { connectDB } = require('../../config/database');
  
  jest.mock('../../config/database');
  
  describe('Notification Controller', () => {
    let mockReq, mockRes;
  
    beforeEach(() => {
      mockReq = {
        body: {},
        user: { id: 'user123', apartmentComplexName: 'testApartment' },
        params: {},
      };
      mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };
      jest.clearAllMocks();
    });
  
    describe('createManagementNotification', () => {
      it('should create a management notification successfully', async () => {
        mockReq.body = { title: 'Test Title', message: 'Test Message' };
        const ManagementNotificationMock = jest.fn().mockImplementation(() => ({
          save: jest.fn().mockResolvedValue({}),
        }));
        connectDB.mockResolvedValue({
          model: jest.fn().mockReturnValue(ManagementNotificationMock),
        });
  
        await createManagementNotification(mockReq, mockRes);
  
        expect(connectDB).toHaveBeenCalledWith('testApartment');
        expect(mockRes.status).toHaveBeenCalledWith(201);
        expect(mockRes.json).toHaveBeenCalledWith({ message: 'Management Notification created successfully!' });
      });
  
      it('should return 400 if title or message is missing', async () => {
        mockReq.body = { title: 'Test Title' }; // Missing message
        await createManagementNotification(mockReq, mockRes);
  
        expect(mockRes.status).toHaveBeenCalledWith(400);
        expect(mockRes.json).toHaveBeenCalledWith({ message: 'Title and message are required' });
      });
  
      it('should return 500 on server error', async () => {
        mockReq.body = { title: 'Test Title', message: 'Test Message' };
        connectDB.mockRejectedValue(new Error('DB Error'));
  
        await createManagementNotification(mockReq, mockRes);
  
        expect(mockRes.status).toHaveBeenCalledWith(500);
        expect(mockRes.json).toHaveBeenCalledWith({ message: 'Server Error', error: 'DB Error' });
      });
    });
  
    describe('getManagementNotification', () => {
      it('should fetch all management notifications successfully', async () => {
        const ManagementNotificationMock = { find: jest.fn().mockReturnValue({
          sort: jest.fn().mockReturnValue({
            populate: jest.fn().mockResolvedValue([{ title: 'Test' }]),
          }),
        }) };
        connectDB.mockResolvedValue({
          model: jest.fn().mockReturnValue(ManagementNotificationMock),
        });
  
        await getManagementNotification(mockReq, mockRes);
  
        expect(connectDB).toHaveBeenCalledWith('testApartment');
        expect(mockRes.json).toHaveBeenCalledWith([{ title: 'Test' }]);
      });
  
      it('should return 500 on server error', async () => {
        connectDB.mockRejectedValue(new Error('DB Error'));
  
        await getManagementNotification(mockReq, mockRes);
  
        expect(mockRes.status).toHaveBeenCalledWith(500);
        expect(mockRes.json).toHaveBeenCalledWith({ message: 'Server Error', error: 'DB Error' });
      });
    });
  
    describe('removeManagementNotification', () => {
      it('should remove a management notification successfully', async () => {
        mockReq.params = { id: 'notif123' };
        const ManagementNotificationMock = {
          findById: jest.fn().mockResolvedValue({}),
          findByIdAndDelete: jest.fn().mockResolvedValue({}),
        };
        connectDB.mockResolvedValue({
          model: jest.fn().mockReturnValue(ManagementNotificationMock),
        });
  
        await removeManagementNotification(mockReq, mockRes);
  
        expect(connectDB).toHaveBeenCalledWith('testApartment');
        expect(mockRes.json).toHaveBeenCalledWith({ message: 'Management notification removed successfully!' });
      });
  
      it('should return 404 if notification not found', async () => {
        mockReq.params = { id: 'notif123' };
        const ManagementNotificationMock = {
          findById: jest.fn().mockResolvedValue(null),
        };
        connectDB.mockResolvedValue({
          model: jest.fn().mockReturnValue(ManagementNotificationMock),
        });
  
        await removeManagementNotification(mockReq, mockRes);
  
        expect(mockRes.status).toHaveBeenCalledWith(404);
        expect(mockRes.json).toHaveBeenCalledWith({ message: 'Notification not found' });
      });
  
      it('should return 500 on server error', async () => {
        mockReq.params = { id: 'notif123' };
        connectDB.mockRejectedValue(new Error('DB Error'));
  
        await removeManagementNotification(mockReq, mockRes);
  
        expect(mockRes.status).toHaveBeenCalledWith(500);
        expect(mockRes.json).toHaveBeenCalledWith({ message: 'Server Error', error: 'DB Error' });
      });
    });
  
    describe('createCommunityNotification', () => {
      it('should create a community notification successfully', async () => {
        mockReq.body = { title: 'Community Title', message: 'Community Message' };
        const CommunityNotificationMock = jest.fn().mockImplementation(() => ({
          save: jest.fn().mockResolvedValue({}),
        }));
        connectDB.mockResolvedValue({
          model: jest.fn().mockReturnValue(CommunityNotificationMock),
        });
  
        await createCommunityNotification(mockReq, mockRes);
  
        expect(connectDB).toHaveBeenCalledWith('testApartment');
        expect(mockRes.status).toHaveBeenCalledWith(201);
        expect(mockRes.json).toHaveBeenCalledWith({ message: 'Community Notification created successfully!' });
      });
  
      it('should return 400 if title or message is missing', async () => {
        mockReq.body = { message: 'Community Message' }; // Missing title
        await createCommunityNotification(mockReq, mockRes);
  
        expect(mockRes.status).toHaveBeenCalledWith(400);
        expect(mockRes.json).toHaveBeenCalledWith({ message: 'Title and message are required' });
      });
  
      it('should return 500 on server error', async () => {
        mockReq.body = { title: 'Community Title', message: 'Community Message' };
        connectDB.mockRejectedValue(new Error('DB Error'));
  
        await createCommunityNotification(mockReq, mockRes);
  
        expect(mockRes.status).toHaveBeenCalledWith(500);
        expect(mockRes.json).toHaveBeenCalledWith({ message: 'Server Error', error: 'DB Error' });
      });
    });
  
    describe('getAllCommunityNotifications', () => {
      it('should fetch all community notifications successfully', async () => {
        const CommunityNotificationMock = { find: jest.fn().mockReturnValue({
          sort: jest.fn().mockReturnValue({
            populate: jest.fn().mockResolvedValue([{ title: 'Community Test' }]),
          }),
        }) };
        connectDB.mockResolvedValue({
          model: jest.fn().mockReturnValue(CommunityNotificationMock),
        });
  
        await getAllCommunityNotifications(mockReq, mockRes);
  
        expect(connectDB).toHaveBeenCalledWith('testApartment');
        expect(mockRes.json).toHaveBeenCalledWith([{ title: 'Community Test' }]);
      });
  
      it('should return 500 on server error', async () => {
        connectDB.mockRejectedValue(new Error('DB Error'));
  
        await getAllCommunityNotifications(mockReq, mockRes);
  
        expect(mockRes.status).toHaveBeenCalledWith(500);
        expect(mockRes.json).toHaveBeenCalledWith({ message: 'Server Error', error: 'DB Error' });
      });
    });
  
    describe('removeCommunityNotificationByManager', () => {
      it('should remove a community notification successfully', async () => {
        mockReq.params = { id: 'notif123' };
        const CommunityNotificationMock = {
          findById: jest.fn().mockResolvedValue({}),
          findByIdAndDelete: jest.fn().mockResolvedValue({}),
        };
        connectDB.mockResolvedValue({
          model: jest.fn().mockReturnValue(CommunityNotificationMock),
        });
  
        await removeCommunityNotificationByManager(mockReq, mockRes);
  
        expect(connectDB).toHaveBeenCalledWith('testApartment');
        expect(mockRes.json).toHaveBeenCalledWith({ message: 'Community Notification removed successfully!' });
      });
  
      it('should return 404 if notification not found', async () => {
        mockReq.params = { id: 'notif123' };
        const CommunityNotificationMock = {
          findById: jest.fn().mockResolvedValue(null),
        };
        connectDB.mockResolvedValue({
          model: jest.fn().mockReturnValue(CommunityNotificationMock),
        });
  
        await removeCommunityNotificationByManager(mockReq, mockRes);
  
        expect(mockRes.status).toHaveBeenCalledWith(404);
        expect(mockRes.json).toHaveBeenCalledWith({ message: 'Notification not found' });
      });
  
      it('should return 500 on server error', async () => {
        mockReq.params = { id: 'notif123' };
        connectDB.mockRejectedValue(new Error('DB Error'));
  
        await removeCommunityNotificationByManager(mockReq, mockRes);
  
        expect(mockRes.status).toHaveBeenCalledWith(500);
        expect(mockRes.json).toHaveBeenCalledWith({ message: 'Server Error', error: 'DB Error' });
      });
    });
  
    describe('deleteCommunityNotification', () => {
      it('should delete a community notification successfully', async () => {
        mockReq.params = { id: 'notif123' };
        const CommunityNotificationMock = {
          findById: jest.fn().mockResolvedValue({ createdBy: 'user123' }),
          findByIdAndDelete: jest.fn().mockResolvedValue({}),
        };
        connectDB.mockResolvedValue({
          model: jest.fn().mockReturnValue(CommunityNotificationMock),
        });
  
        await deleteCommunityNotification(mockReq, mockRes);
  
        expect(connectDB).toHaveBeenCalledWith('testApartment');
        expect(mockRes.json).toHaveBeenCalledWith({ message: 'Notification deleted successfully!' });
      });
  
      it('should return 403 if user is not authorized', async () => {
        mockReq.params = { id: 'notif123' };
        const CommunityNotificationMock = {
          findById: jest.fn().mockResolvedValue({ createdBy: 'otherUser' }),
        };
        connectDB.mockResolvedValue({
          model: jest.fn().mockReturnValue(CommunityNotificationMock),
        });
  
        await deleteCommunityNotification(mockReq, mockRes);
  
        expect(mockRes.status).toHaveBeenCalledWith(403);
        expect(mockRes.json).toHaveBeenCalledWith({ message: 'You are not authorized to delete this notification' });
      });
  
      it('should return 404 if notification not found', async () => {
        mockReq.params = { id: 'notif123' };
        const CommunityNotificationMock = {
          findById: jest.fn().mockResolvedValue(null),
        };
        connectDB.mockResolvedValue({
          model: jest.fn().mockReturnValue(CommunityNotificationMock),
        });
  
        await deleteCommunityNotification(mockReq, mockRes);
  
        expect(mockRes.status).toHaveBeenCalledWith(404);
        expect(mockRes.json).toHaveBeenCalledWith({ message: 'Notification not found' });
      });
    });
  
    describe('removeCommunityNotificationsFromUser', () => {
      it('should remove a notification for the current user successfully', async () => {
        mockReq.params = { id: 'notif123' };
        const notification = { removedFor: [], save: jest.fn().mockResolvedValue({}) };
        const CommunityNotificationMock = {
          findById: jest.fn().mockResolvedValue(notification),
        };
        connectDB.mockResolvedValue({
          model: jest.fn().mockReturnValue(CommunityNotificationMock),
        });
  
        await removeCommunityNotificationsFromUser(mockReq, mockRes);
  
        expect(connectDB).toHaveBeenCalledWith('testApartment');
        expect(notification.removedFor).toContain('user123');
        expect(mockRes.json).toHaveBeenCalledWith({ message: 'Notification removed for current user' });
      });
  
      it('should return 404 if notification not found', async () => {
        mockReq.params = { id: 'notif123' };
        const CommunityNotificationMock = {
          findById: jest.fn().mockResolvedValue(null),
        };
        connectDB.mockResolvedValue({
          model: jest.fn().mockReturnValue(CommunityNotificationMock),
        });
  
        await removeCommunityNotificationsFromUser(mockReq, mockRes);
  
        expect(mockRes.status).toHaveBeenCalledWith(404);
        expect(mockRes.json).toHaveBeenCalledWith({ message: 'Notification not found' });
      });
    });
  
    describe('editCommunityNotification', () => {
      it('should edit a community notification successfully', async () => {
        mockReq.params = { id: 'notif123' };
        mockReq.body = { title: 'Updated Title', message: 'Updated Message' };
        const notification = {
          createdBy: 'user123',
          title: 'Old Title',
          message: 'Old Message',
          save: jest.fn().mockResolvedValue({}),
        };
        const CommunityNotificationMock = {
          findById: jest.fn().mockResolvedValue(notification),
        };
        connectDB.mockResolvedValue({
          model: jest.fn().mockReturnValue(CommunityNotificationMock),
        });
  
        await editCommunityNotification(mockReq, mockRes);
  
        expect(connectDB).toHaveBeenCalledWith('testApartment');
        expect(notification.title).toBe('Updated Title');
        expect(notification.message).toBe('Updated Message');
        expect(mockRes.json).toHaveBeenCalledWith({ message: 'Notification updated successfully!', notification });
      });
  
      it('should return 400 if no fields provided', async () => {
        mockReq.params = { id: 'notif123' };
        mockReq.body = {};
        await editCommunityNotification(mockReq, mockRes);
  
        expect(mockRes.status).toHaveBeenCalledWith(400);
        expect(mockRes.json).toHaveBeenCalledWith({ message: 'At least one field (title or message) must be provided' });
      });
  
      it('should return 403 if user is not authorized', async () => {
        mockReq.params = { id: 'notif123' };
        mockReq.body = { title: 'Updated Title' };
        const CommunityNotificationMock = {
          findById: jest.fn().mockResolvedValue({ createdBy: 'otherUser' }),
        };
        connectDB.mockResolvedValue({
          model: jest.fn().mockReturnValue(CommunityNotificationMock),
        });
  
        await editCommunityNotification(mockReq, mockRes);
  
        expect(mockRes.status).toHaveBeenCalledWith(403);
        expect(mockRes.json).toHaveBeenCalledWith({ message: 'You are not authorized to edit this notification' });
      });
    });
  });