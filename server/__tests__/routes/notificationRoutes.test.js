const request = require('supertest');
const express = require('express');
const notificationRoutes = require('../../routes/notificationRoutes');
const { authenticate, isManager, isResident } = require('../../middleware/authMiddleware');

jest.mock('../../middleware/authMiddleware');
jest.mock('../../controllers/notificationController');

const app = express();
app.use(express.json());
app.use('/notifications', notificationRoutes);

describe('Notification Routes', () => {
  beforeEach(() => {
    authenticate.mockImplementation((req, res, next) => {
      req.user = { id: 'user123', apartmentComplexName: 'testApartment' };
      next();
    });
    isManager.mockImplementation((req, res, next) => next());
    isResident.mockImplementation((req, res, next) => next());
    jest.clearAllMocks();
  });

  it('POST /notifications/management should create a management notification', async () => {
    const mockCreate = require('../../controllers/notificationController').createManagementNotification
      .mockImplementation((req, res) => res.status(201).json({ message: 'Management Notification created successfully!' }));

    const response = await request(app)
      .post('/notifications/management')
      .send({ title: 'Test', message: 'Message' });

    expect(response.status).toBe(201);
    expect(response.body).toEqual({ message: 'Management Notification created successfully!' });
    expect(mockCreate).toHaveBeenCalled();
  });

  it('GET /notifications/management should fetch management notifications', async () => {
    const mockGet = require('../../controllers/notificationController').getManagementNotification
      .mockImplementation((req, res) => res.json([{ title: 'Test' }]));

    const response = await request(app)
      .get('/notifications/management');

    expect(response.status).toBe(200);
    expect(response.body).toEqual([{ title: 'Test' }]);
    expect(mockGet).toHaveBeenCalled();
  });

  it('DELETE /notifications/management/:id should remove a management notification', async () => {
    const mockRemove = require('../../controllers/notificationController').removeManagementNotification
      .mockImplementation((req, res) => res.json({ message: 'Management notification removed successfully!' }));

    const response = await request(app)
      .delete('/notifications/management/notif123');

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ message: 'Management notification removed successfully!' });
    expect(mockRemove).toHaveBeenCalled();
  });

  it('POST /notifications/community should create a community notification', async () => {
    const mockCreate = require('../../controllers/notificationController').createCommunityNotification
      .mockImplementation((req, res) => res.status(201).json({ message: 'Community Notification created successfully!' }));

    const response = await request(app)
      .post('/notifications/community')
      .send({ title: 'Test', message: 'Message' });

    expect(response.status).toBe(201);
    expect(response.body).toEqual({ message: 'Community Notification created successfully!' });
    expect(mockCreate).toHaveBeenCalled();
  });

  it('GET /notifications/community should fetch community notifications', async () => {
    const mockGet = require('../../controllers/notificationController').getAllCommunityNotifications
      .mockImplementation((req, res) => res.json([{ title: 'Test' }]));

    const response = await request(app)
      .get('/notifications/community');

    expect(response.status).toBe(200);
    expect(response.body).toEqual([{ title: 'Test' }]);
    expect(mockGet).toHaveBeenCalled();
  });
});