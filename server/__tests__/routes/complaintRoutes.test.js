const request = require('supertest');
const express = require('express');
const complaintRoutes = require('../../routes/complaintRoutes');
const { authenticate, isManager } = require('../../middleware/authMiddleware');

jest.mock('../../middleware/authMiddleware');
jest.mock('../../controllers/complaintController');

const app = express();
app.use(express.json());
app.use('/complaints', complaintRoutes);

describe('Complaint Routes', () => {
  beforeEach(() => {
    authenticate.mockImplementation((req, res, next) => {
      req.user = { id: 'resident123', apartmentComplexName: 'testApartment' };
      next();
    });
    isManager.mockImplementation((req, res, next) => next());
    jest.clearAllMocks();
  });

  it('POST /complaints/create-complaints should create a complaint', async () => {
    const mockCreate = require('../../controllers/complaintController').createComplaint
      .mockImplementation((req, res) => res.status(201).json({ message: 'Complaint submitted successfully!' }));

    const response = await request(app)
      .post('/complaints/create-complaints')
      .send({ title: 'Noisy Neighbor', description: 'Too loud at night' });

    expect(response.status).toBe(201);
    expect(response.body).toEqual({ message: 'Complaint submitted successfully!' });
    expect(mockCreate).toHaveBeenCalled();
  });

  it('GET /complaints/get-complaints should fetch complaints', async () => {
    const mockGet = require('../../controllers/complaintController').getComplaints
      .mockImplementation((req, res) => res.json([{ title: 'Test Complaint' }]));

    const response = await request(app)
      .get('/complaints/get-complaints');

    expect(response.status).toBe(200);
    expect(response.body).toEqual([{ title: 'Test Complaint' }]);
    expect(mockGet).toHaveBeenCalled();
  });
});