const request = require('supertest');
const express = require('express');
const safetyRoutes = require('../../routes/safetyRoutes');
const { authenticate, isManager } = require('../../middleware/authMiddleware');

jest.mock('../../middleware/authMiddleware');
jest.mock('../../controllers/safetyAlertsController');

const app = express();
app.use(express.json());
app.use('/safety', safetyRoutes);

describe('Safety Routes', () => {
  beforeEach(() => {
    authenticate.mockImplementation((req, res, next) => {
      req.user = { id: 'manager123', apartmentComplexName: 'testApartment' };
      next();
    });
    isManager.mockImplementation((req, res, next) => next());
    jest.clearAllMocks();
  });

  it('POST /safety/create-alerts should create a safety alert', async () => {
    const mockCreate = require('../../controllers/safetyAlertsController').createSafetyAlert
      .mockImplementation((req, res) => res.status(201).json({ message: 'Safety Alert created successfully!' }));

    const response = await request(app)
      .post('/safety/create-alerts')
      .send({ title: 'Fire Alarm', description: 'Smoke detected' });

    expect(response.status).toBe(201);
    expect(response.body).toEqual({ message: 'Safety Alert created successfully!' });
    expect(mockCreate).toHaveBeenCalled();
  });

  it('GET /safety/get-alerts should fetch safety alerts', async () => {
    const mockGet = require('../../controllers/safetyAlertsController').getSafetyAlerts
      .mockImplementation((req, res) => res.json([{ title: 'Fire Alarm' }]));

    const response = await request(app)
      .get('/safety/get-alerts');

    expect(response.status).toBe(200);
    expect(response.body).toEqual([{ title: 'Fire Alarm' }]);
    expect(mockGet).toHaveBeenCalled();
  });

  it('DELETE /safety/delete-alerts/:id should delete a safety alert', async () => {
    const mockDelete = require('../../controllers/safetyAlertsController').deleteSafetyAlert
      .mockImplementation((req, res) => res.json({ message: 'Safety Alert deleted successfully!' }));

    const response = await request(app)
      .delete('/safety/delete-alerts/alert123');

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ message: 'Safety Alert deleted successfully!' });
    expect(mockDelete).toHaveBeenCalled();
  });
});