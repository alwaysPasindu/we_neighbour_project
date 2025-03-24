const request = require('supertest');
const express = require('express');
const resourceRoutes = require('../../routes/resourceRoutes');
const { authenticate, isResidentOrManager } = require('../../middleware/authMiddleware');

jest.mock('../../middleware/authMiddleware');
jest.mock('../../controllers/resourceController');

const app = express();
app.use(express.json());
app.use('/resources', resourceRoutes);

describe('Resource Routes', () => {
  beforeEach(() => {
    authenticate.mockImplementation((req, res, next) => {
      req.user = { id: 'resident123', apartmentComplexName: 'testApartment', role: 'Resident' };
      next();
    });
    isResidentOrManager.mockImplementation((req, res, next) => next());
    jest.clearAllMocks();
  });

  it('POST /resources/create-request should create a resource request', async () => {
    const mockCreate = require('../../controllers/resourceController').createResourceRequest
      .mockImplementation((req, res) => res.status(201).json({ message: 'Resource request cereated successfully' }));

    const response = await request(app)
      .post('/resources/create-request')
      .send({ resourceName: 'Lawnmower', description: 'For yard work', quantity: 1 });

    expect(response.status).toBe(201);
    expect(response.body).toEqual({ message: 'Resource request cereated successfully' });
    expect(mockCreate).toHaveBeenCalled();
  });

  it('GET /resources/get-request should fetch resource requests', async () => {
    const mockGet = require('../../controllers/resourceController').getResourceRequest
      .mockImplementation((req, res) => res.json([{ resourceName: 'Lawnmower' }]));

    const response = await request(app)
      .get('/resources/get-request');

    expect(response.status).toBe(200);
    expect(response.body).toEqual([{ resourceName: 'Lawnmower' }]);
    expect(mockGet).toHaveBeenCalled();
  });

  it('DELETE /resources/delete-request/:id should delete a resource request', async () => {
    const mockDelete = require('../../controllers/resourceController').deleteResourceRequest
      .mockImplementation((req, res) => res.json({ message: 'Resource request deleted successfully' }));

    const response = await request(app)
      .delete('/resources/delete-request/request123');

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ message: 'Resource request deleted successfully' });
    expect(mockDelete).toHaveBeenCalled();
  });
});