const { registerResident } = require('../../controllers/residentController');
const { connectDB } = require('../../config/database');
const { syncUserToFirebase } = require('../../utils/firebaseSync');

jest.mock('../../config/database');
jest.mock('../../utils/firebaseSync');

describe('Resident Controller - registerResident', () => {
  let mockReq, mockRes;

  beforeEach(() => {
    mockReq = {
      body: {
        name: 'John Doe',
        nic: '123456789V',
        email: 'john@example.com',
        password: 'password123',
        phone: '1234567890',
        address: '123 Street',
        apartmentComplexName: 'testApartment',
        apartmentCode: 'A101',
      },
    };
    mockRes = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn(),
    };

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

  it('should register a new resident successfully', async () => {
    await registerResident(mockReq, mockRes);

    expect(connectDB).toHaveBeenCalledWith('testApartment');
    expect(mockRes.status).toHaveBeenCalledWith(201);
    expect(mockRes.json).toHaveBeenCalledWith({
      message: 'Resident registered successfully..! - Waiting for Manager approval',
    });
  });

  it('should return 400 if resident already exists', async () => {
    const ResidentMock = jest.fn().mockImplementation(() => ({}));
    ResidentMock.findOne = jest.fn().mockResolvedValue({ email: 'john@example.com' });
    connectDB.mockResolvedValue({
      model: jest.fn().mockReturnValue(ResidentMock),
    });

    await registerResident(mockReq, mockRes);

    expect(mockRes.status).toHaveBeenCalledWith(400);
    expect(mockRes.json).toHaveBeenCalledWith({ message: 'Resident already exists' });
  });

  it('should return 500 on server error', async () => {
    connectDB.mockRejectedValue(new Error('DB Error'));

    await registerResident(mockReq, mockRes);

    expect(mockRes.status).toHaveBeenCalledWith(500);
    expect(mockRes.json).toHaveBeenCalledWith({ message: 'Server Error' });
  });
});