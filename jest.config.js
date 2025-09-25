module.exports = {
  testEnvironment: 'node',
  testMatch: ['**/tests/**/*.test.js'],
  collectCoverageFrom: [
    'server.js',
    '!node_modules/**',
    '!tests/**'
  ],
  coverageReporters: ['text', 'lcov', 'html'],
  testTimeout: 10000
};
