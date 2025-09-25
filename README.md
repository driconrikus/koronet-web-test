# Koronet Web Server - DevOps Practical Test

A complete DevOps solution for the Koronet web server, including containerization, CI/CD pipeline, monitoring, and infrastructure as code.

## 🏗️ Architecture Overview

This project implements a modern, scalable web application with the following components:

- **Web Server**: Node.js/Express application responding with "Hi Koronet Team"
- **Database**: PostgreSQL for persistent data storage
- **Cache**: Redis for high-performance caching
- **Containerization**: Docker with optimized multi-stage builds
- **Orchestration**: Docker Compose for local development
- **CI/CD**: GitHub Actions for automated testing and deployment to ECR
- **Infrastructure**: AWS ECS with Terraform IaC
- **Monitoring**: Prometheus, Grafana, and CloudWatch integration

## 📁 Project Structure

```
koronet-web-test/
├── server.js                 # Main application file
├── package.json             # Node.js dependencies
├── Dockerfile               # Optimized container build
├── docker-compose.yml       # Local development setup
├── .github/workflows/       # GitHub Actions CI/CD
├── terraform/               # Infrastructure as Code
├── monitoring/              # Monitoring configuration
├── tests/                   # Application tests
└── README.md               # This file
```

## 🚀 Quick Start

### Local Development

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd koronet-web-test
   ```

2. **Start the application locally**
   ```bash
   # Install dependencies
   npm install
   
   # Start with Docker Compose
   docker-compose up -d
   
   # Or run directly with Node.js
   npm start
   ```

3. **Access the application**
   - Application: http://localhost:3000
   - Health Check: http://localhost:3000/health
   - Grafana: http://localhost:3001 (admin/admin)
   - Prometheus: http://localhost:9090

### AWS Deployment

1. **Prerequisites**
   - AWS CLI configured
   - Terraform >= 1.0
   - Docker installed

2. **Deploy infrastructure**
   ```bash
   cd terraform
   ./deploy.sh
   ```

3. **Access deployed application**
   ```bash
   terraform output load_balancer_dns_name
   ```

## 🔧 Features

### Web Server
- ✅ Responds with "Hi Koronet Team"
- ✅ PostgreSQL integration with connection pooling
- ✅ Redis caching with automatic failover
- ✅ Health check endpoints
- ✅ Request logging and history
- ✅ Graceful shutdown handling

### Docker
- ✅ Multi-stage build for optimization
- ✅ Minimal Alpine Linux base image
- ✅ Non-root user for security
- ✅ Health checks configured
- ✅ Optimized layer caching

### Docker Compose
- ✅ Web server, PostgreSQL, and Redis services
- ✅ Prometheus and Grafana monitoring
- ✅ Proper networking and health checks
- ✅ Volume persistence for data

### CI/CD Pipeline
- ✅ Automated testing with Jest
- ✅ Docker image building and pushing
- ✅ Security scanning with Trivy
- ✅ ECS deployment automation
- ✅ Multi-architecture support (AMD64/ARM64)

### Infrastructure (Terraform)
- ✅ VPC with public/private/database subnets
- ✅ ECS Fargate cluster with auto-scaling
- ✅ Application Load Balancer
- ✅ RDS PostgreSQL with encryption
- ✅ ElastiCache Redis cluster
- ✅ ECR repository with lifecycle policies
- ✅ CloudWatch monitoring and alerting
- ✅ Secrets Manager for credentials

### Monitoring
- ✅ Prometheus metrics collection
- ✅ Grafana dashboards
- ✅ CloudWatch integration
- ✅ Automated alerting
- ✅ Application and infrastructure metrics

## 📊 Monitoring Setup

The monitoring architecture includes:

- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization and dashboards
- **CloudWatch**: AWS-native monitoring and alerting
- **Custom Metrics**: Application-specific KPIs

See [monitoring-diagram.md](monitoring-diagram.md) for the complete architecture diagram.

## 🔐 Security Features

- **Container Security**: Non-root user, minimal base image
- **Network Security**: Private subnets, security groups
- **Data Encryption**: RDS encryption, Redis encryption
- **Secrets Management**: AWS Secrets Manager
- **Vulnerability Scanning**: Trivy integration in CI/CD

## 🧪 Testing

```bash
# Run tests
npm test

# Run tests with coverage
npm run test:coverage

# Run tests in watch mode
npm run test:watch
```

## 📈 Scaling

The application is designed for horizontal scaling:

- **ECS Auto Scaling**: CPU and memory-based scaling
- **Load Balancer**: Traffic distribution
- **Database**: Connection pooling and read replicas
- **Cache**: Redis cluster with automatic failover

## 🛠️ Development

### Environment Variables

Copy `env.example` to `.env` and configure:

```bash
cp env.example .env
```

### Database Schema

The application automatically creates the required database schema on startup.

### Adding New Features

1. Create feature branch
2. Implement changes
3. Add tests
4. Update documentation
5. Submit pull request

## 📝 API Endpoints

- `GET /` - Main endpoint (returns "Hi Koronet Team")
- `GET /health` - Health check with service status
- `GET /cache` - Redis cache information
- `GET /history` - Request history from database

## 🔄 CI/CD Pipeline

The GitHub Actions pipeline includes:

1. **Test Stage**: Unit tests with PostgreSQL and Redis
2. **Build Stage**: Multi-architecture Docker image
3. **Security Stage**: Vulnerability scanning
4. **Deploy Stage**: ECS deployment with rolling updates

## 📋 Deployment Checklist

- [ ] AWS credentials configured
- [ ] Terraform backend configured (optional)
- [ ] GitHub secrets configured (DOCKER_USERNAME, DOCKER_PASSWORD, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION)
- [ ] SNS email subscription configured
- [ ] Domain name configured (optional)

## 🚨 Troubleshooting

### Common Issues

1. **ECS Service not starting**
   - Check CloudWatch logs
   - Verify security group rules
   - Ensure Secrets Manager permissions

2. **Database connection issues**
   - Verify RDS endpoint and port
   - Check security group configuration
   - Validate Secrets Manager secret

3. **Load balancer health check failures**
   - Ensure application responds on `/health`
   - Check security group rules
   - Verify target group configuration

### Useful Commands

```bash
# Check ECS service status
aws ecs describe-services --cluster koronet-web-cluster --services koronet-web-service

# View application logs
aws logs tail /ecs/koronet-web --follow

# Check load balancer health
aws elbv2 describe-target-health --target-group-arn <TARGET_GROUP_ARN>

# Scale ECS service
aws ecs update-service --cluster koronet-web-cluster --service koronet-web-service --desired-count 3
```

## 📞 Support

For questions or issues:

1. Check the troubleshooting section
2. Review CloudWatch logs
3. Check GitHub Actions pipeline logs
4. Create an issue in the repository

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🎯 Project Requirements Completion

✅ **Web Server**: Node.js application responding with "Hi Koronet Team"  
✅ **Database**: PostgreSQL integration with connection pooling  
✅ **Redis**: Redis integration for caching  
✅ **Docker**: Optimized Dockerfile with minimal base image  
✅ **Docker Compose**: Complete setup with networking  
✅ **GitHub Actions**: Full CI/CD pipeline with testing and deployment  
✅ **Monitoring**: Prometheus, Grafana, and CloudWatch integration  
✅ **Terraform**: Complete ECS infrastructure with VPC, security groups, and auto-scaling  

---

**Deployed and ready for production! 🚀**
