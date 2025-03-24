const request = require('supertest');
const express = require('express');
const visitorRoutes = require('../../routes/visitorRoutes');
const { authenticate, isResident } = require('../../middleware/authMiddleware');

jest.mock('../../middleware/authMiddleware');
jest.mock('../../controllers/visitorController');

const app = express();
app.use(express.json());
app.use('/api/visitor', visitorRoutes);

describe('Visitor Routes', () => {
  beforeEach(() => {
    authenticate.mockImplementation((req, res, next) => {
      req.user = { id: 'resident123', apartmentComplexName: 'testApartment' };
      next();
    });
    isResident.mockImplementation((req, res, next) => next());
    jest.clearAllMocks();
  });

  it('POST /api/visitor/generate-qr should generate QR code', async () => {
    const mockGenerate = require('../../controllers/visitorController').generateQRCodeData
      .mockImplementation((req, res) => res.json({ success: true, qrUrl: 'http://localhost:3000/api/visitor/verify/visitor123', visitorId: 'visitor123' }));

    const response = await request(app)
      .post('/api/visitor/generate-qr')
      .send({ numOfVisitors: 2, visitorNames: ['John', 'Jane'] });

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ success: true, qrUrl: 'http://localhost:3000/api/visitor/verify/visitor123', visitorId: 'visitor123' });
    expect(mockGenerate).toHaveBeenCalled();
  });

  it('GET /api/visitor/verify/:visitorId should return verification page', async () => {
    const mockVerify = require('../../controllers/visitorController').verifyVisitor
      .mockImplementation((req, res) => res.send('<h1>Visitor Verification</h1>'));

    const response = await request(app)
      .get('/api/visitor/verify/visitor123?apartment=testApartment');

    expect(response.status).toBe(200);
    expect(response.text).toContain('Visitor Verification');
    expect(mockVerify).toHaveBeenCalled();
  });

  it('POST /api/visitor/update-status should update visitor status', async () => {
    const mockUpdate = require('../../controllers/visitorController').updateVisitorStatus
      .mockImplementation((req, res) => res.json({ success: true, message: 'Visitor accepted' }));

    const response = await request(app)
      .post('/api/visitor/update-status')
      .set('x-apartment-name', 'testApartment')
      .send({ visitorId: 'visitor123', action: 'approve' });

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ success: true, message: 'Visitor accepted' });
    expect(mockUpdate).toHaveBeenCalled();
  });
});