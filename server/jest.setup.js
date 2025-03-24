// jest.setup.js
jest.setTimeout(10000);

process.env.JWT_SECRET = 'test-secret';
process.env.PORT = '3000';
process.env.BASE_URL = 'http://localhost:3000';

jest.mock('bcrypt', () => ({
  hash: jest.fn().mockResolvedValue('hashedPassword'),
  compare: jest.fn().mockResolvedValue(true),
}));

jest.mock('jsonwebtoken', () => ({
  sign: jest.fn().mockReturnValue('mockedToken'),
  verify: jest.fn().mockReturnValue({ id: 'mockedId', role: 'Resident', apartmentComplexName: 'testApartment' }),
}));

jest.mock('./config/firebase', () => ({
  db: {
    collection: jest.fn(() => ({
      doc: jest.fn(() => ({
        set: jest.fn().mockResolvedValue(),
      })),
    })),
  },
}));