-- Initialize Koronet database
CREATE DATABASE koronet;

-- Connect to koronet database
\c koronet;

-- Create requests table
CREATE TABLE IF NOT EXISTS requests (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    endpoint VARCHAR(255) NOT NULL,
    user_agent TEXT,
    ip_address INET
);

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_requests_timestamp ON requests(timestamp);
CREATE INDEX IF NOT EXISTS idx_requests_endpoint ON requests(endpoint);

-- Insert sample data
INSERT INTO requests (timestamp, endpoint, user_agent, ip_address) VALUES
    (CURRENT_TIMESTAMP - INTERVAL '1 hour', '/', 'Docker Health Check', '127.0.0.1'),
    (CURRENT_TIMESTAMP - INTERVAL '30 minutes', '/health', 'Prometheus', '127.0.0.1'),
    (CURRENT_TIMESTAMP - INTERVAL '15 minutes', '/cache', 'Test Client', '127.0.0.1');
