module.exports = {
    preset: '@shelf/jest-mongodb',
    testEnvironment: 'node',
    setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
    testTimeout: 10000, // Increase timeout for async operations
  };