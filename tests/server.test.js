const request = require('supertest');
const app = require('../server');

describe('Koronet Web Server', () => {
  describe('GET /', () => {
    it('should respond with Hi Koronet Team message', async () => {
      const response = await request(app)
        .get('/')
        .expect(200);
      
      expect(response.body.message).toBe('Hi Koronet Team.');
      expect(response.body.timestamp).toBeDefined();
      expect(response.body.services).toBeDefined();
    });
  });

  describe('GET /health', () => {
    it('should return health status', async () => {
      const response = await request(app)
        .get('/health')
        .expect(200);
      
      expect(response.body.status).toBeDefined();
      expect(response.body.timestamp).toBeDefined();
      expect(response.body.services).toBeDefined();
      expect(response.body.services.postgresql).toBeDefined();
      expect(response.body.services.redis).toBeDefined();
    });
  });

  describe('GET /cache', () => {
    it('should return cache information', async () => {
      const response = await request(app)
        .get('/cache')
        .expect(200);
      
      expect(response.body.timestamp).toBeDefined();
    });
  });

  describe('GET /history', () => {
    it('should return request history', async () => {
      const response = await request(app)
        .get('/history')
        .expect(200);
      
      expect(response.body.requests).toBeDefined();
      expect(response.body.timestamp).toBeDefined();
    });
  });
});
