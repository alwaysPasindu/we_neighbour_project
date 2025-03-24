const request = require('supertest');
const express = require('express');
const residentRoutes = require('../../routes/residentRoutes');
const { connectDB } = require('../../config/database');

jest.mock('../../config/database');
jest.mock('../../utils/firebaseSync');

describe('Resident Routes', () => {
  let app;

  beforeAll(() => {
    app = express();
    app.use(express.json());
    app.use('/api/residents', residentRoutes);

    // Mock Resident model as a constructor
    const ResidentMock = jest.fn().mockImplementation(() => ({
      save: jest.fn().mockResolvedValue({}),
    }));
    ResidentMock.findOne = jest.fn().mockResolvedValue(null);

    connectDB.mockResolvedValue({
      model: jest.fn().mockReturnValue(ResidentMock),
    });
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('POST /api/residents/register should register a resident', async () => {
    const response = await request(app)
      .post('/api/residents/register')
      .send({
        name: 'John Doe',
        nic: '123456789V',
        email: 'john@example.com',
        password: 'password123',
        phone: '1234567890',
        address: '123 Street',
        apartmentComplexName: 'testApartment',
        apartmentCode: 'A101',
      });

    expect(response.status).toBe(201);
    expect(response.body).toEqual({
      message: 'Resident registered successfully..! - Waiting for Manager approval',
    });
  });
});