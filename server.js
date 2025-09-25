const express = require('express');
const { Pool } = require('pg');
const redis = require('redis');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json());

// PostgreSQL connection
const pool = new Pool({
  user: process.env.DB_USER || 'postgres',
  host: process.env.DB_HOST || 'postgres',
  database: process.env.DB_NAME || 'koronet',
  password: process.env.DB_PASSWORD || 'password',
  port: process.env.DB_PORT || 5432,
});

// Redis connection
const redisClient = redis.createClient({
  host: process.env.REDIS_HOST || 'redis',
  port: process.env.REDIS_PORT || 6379,
  password: process.env.REDIS_PASSWORD || undefined,
});

redisClient.on('error', (err) => {
  console.error('Redis Client Error:', err);
});

redisClient.on('connect', () => {
  console.log('Connected to Redis');
});

// Initialize connections
async function initializeConnections() {
  try {
    await redisClient.connect();
    console.log('Redis connected successfully');
    
    // Test PostgreSQL connection
    const client = await pool.connect();
    console.log('PostgreSQL connected successfully');
    client.release();
  } catch (error) {
    console.error('Connection initialization failed:', error);
  }
}

// Health check endpoint
app.get('/health', async (req, res) => {
  const health = {
    status: 'OK',
    timestamp: new Date().toISOString(),
    services: {
      postgresql: 'unknown',
      redis: 'unknown'
    }
  };

  try {
    // Check PostgreSQL
    const client = await pool.connect();
    await client.query('SELECT 1');
    client.release();
    health.services.postgresql = 'healthy';
  } catch (error) {
    health.services.postgresql = 'unhealthy';
    health.status = 'DEGRADED';
  }

  try {
    // Check Redis
    await redisClient.ping();
    health.services.redis = 'healthy';
  } catch (error) {
    health.services.redis = 'unhealthy';
    health.status = 'DEGRADED';
  }

  res.status(health.status === 'OK' ? 200 : 503).json(health);
});

// Main endpoint
app.get('/', async (req, res) => {
  try {
    // Store request in Redis for caching/demo
    const timestamp = new Date().toISOString();
    await redisClient.set('last_request', timestamp, { EX: 3600 }); // Expire in 1 hour
    
    // Log to PostgreSQL
    const client = await pool.connect();
    await client.query(
      'INSERT INTO requests (timestamp, endpoint) VALUES ($1, $2)',
      [timestamp, '/']
    );
    client.release();

    res.json({
      message: 'Hi Koronet Team.',
      timestamp: timestamp,
      services: {
        database: 'PostgreSQL',
        cache: 'Redis'
      }
    });
  } catch (error) {
    console.error('Error in main endpoint:', error);
    res.status(500).json({
      message: 'Hi Koronet Team.',
      error: 'Service temporarily unavailable',
      timestamp: new Date().toISOString()
    });
  }
});

// Get cached data endpoint
app.get('/cache', async (req, res) => {
  try {
    const lastRequest = await redisClient.get('last_request');
    res.json({
      lastRequest: lastRequest,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error retrieving cache:', error);
    res.status(500).json({ error: 'Cache service unavailable' });
  }
});

// Get request history from database
app.get('/history', async (req, res) => {
  try {
    const client = await pool.connect();
    const result = await client.query(
      'SELECT timestamp, endpoint FROM requests ORDER BY timestamp DESC LIMIT 10'
    );
    client.release();
    
    res.json({
      requests: result.rows,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error retrieving history:', error);
    res.status(500).json({ error: 'Database service unavailable' });
  }
});

// Initialize database schema
async function initializeDatabase() {
  try {
    const client = await pool.connect();
    await client.query(`
      CREATE TABLE IF NOT EXISTS requests (
        id SERIAL PRIMARY KEY,
        timestamp TIMESTAMP NOT NULL,
        endpoint VARCHAR(255) NOT NULL
      )
    `);
    client.release();
    console.log('Database schema initialized');
  } catch (error) {
    console.error('Database initialization failed:', error);
  }
}

// Start server
async function startServer() {
  await initializeDatabase();
  await initializeConnections();
  
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`Koronet web server running on port ${PORT}`);
    console.log(`Health check available at http://localhost:${PORT}/health`);
  });
}

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('SIGTERM received, shutting down gracefully');
  await redisClient.quit();
  await pool.end();
  process.exit(0);
});

process.on('SIGINT', async () => {
  console.log('SIGINT received, shutting down gracefully');
  await redisClient.quit();
  await pool.end();
  process.exit(0);
});

startServer().catch(console.error);
