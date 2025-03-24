// __mocks__/mongoose.js
const mongoose = jest.requireActual('mongoose'); // Preserve real Mongoose functionality

const mockConnection = {
  model: jest.fn((name, schema) => {
    // Return a constructor function to support `new Model()`
    const Model = jest.fn().mockImplementation((data) => ({
      ...data,
      save: jest.fn().mockResolvedValue(data),
    }));
    // Add static methods like findOne, findById
    Model.findOne = jest.fn();
    Model.findById = jest.fn();
    return Model;
  }),
  on: jest.fn(),
  once: jest.fn(),
};

const mongooseMock = {
  ...mongoose, // Include real Schema, Types, etc.
  createConnection: jest.fn().mockReturnValue(mockConnection),
  connect: jest.fn().mockResolvedValue(mockConnection),
  connection: { close: jest.fn().mockResolvedValue() },
};

module.exports = mongooseMock;