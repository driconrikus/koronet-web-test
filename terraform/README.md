# Koronet Web Server - Terraform Infrastructure

This directory contains the Terraform configuration for deploying the Koronet web server on AWS ECS with all necessary infrastructure components.

## Architecture

The infrastructure includes:
- **VPC** with public, private, and database subnets across 2 AZs
- **ECS Fargate** cluster with auto-scaling
- **Application Load Balancer** for traffic distribution
- **RDS PostgreSQL** database with encryption and backups
- **ElastiCache Redis** cluster for caching
- **Docker Hub** for container images
- **CloudWatch** monitoring and alerting
- **Secrets Manager** for secure credential storage

## Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** >= 1.0 installed
3. **Docker** for building and pushing images
4. **AWS Account** with appropriate permissions

## Required AWS Permissions

Your AWS credentials need the following permissions:
- ECS (clusters, services, task definitions)
- VPC (VPC, subnets, security groups, NAT gateways)
- RDS (instances, subnet groups, parameter groups)
- ElastiCache (replication groups, subnet groups)
- Docker Hub access
- IAM (roles, policies, policy attachments)
- CloudWatch (log groups, alarms, dashboards)
- Secrets Manager (secrets, versions)
- SNS (topics, subscriptions)
- Application Load Balancer (load balancers, target groups)

## Deployment Steps

### 1. Configure Backend (Optional)

Edit `main.tf` to configure the S3 backend:

```hcl
backend "s3" {
  bucket = "your-terraform-state-bucket"
  key    = "koronet/terraform.tfstate"
  region = "us-west-2"
}
```

### 2. Initialize Terraform

```bash
cd terraform
terraform init
```

### 3. Review Configuration

```bash
terraform plan
```

### 4. Deploy Infrastructure

```bash
terraform apply
```

### 5. Build and Push Docker Image

After infrastructure is deployed, you can build and push your Docker image to Docker Hub:

```bash
# Login to Docker Hub
docker login --username your-dockerhub-username

# Build image
docker build -t koronet-web-app .

# Tag image
docker tag koronet-web-app:latest your-dockerhub-username/koronet-web-app:latest

# Push image
docker push your-dockerhub-username/koronet-web-app:latest
```

Or use the automated deployment script:

```bash
# Set Docker Hub credentials
export DOCKER_PASSWORD=your-dockerhub-password

# Run deployment script
./deploy.sh
```

### 6. Update ECS Service

After pushing the image, update the ECS service:

```bash
aws ecs update-service --cluster koronet-web-cluster --service koronet-web-service --force-new-deployment
```

## Configuration

### Variables

Key variables you can customize in `variables.tf`:

- `aws_region`: AWS region (default: us-west-2)
- `environment`: Environment name (default: production)
- `container_cpu`: Container CPU units (default: 256)
- `container_memory`: Container memory in MB (default: 512)
- `desired_count`: Desired number of tasks (default: 2)
- `db_instance_class`: RDS instance class (default: db.t3.micro)
- `redis_node_type`: ElastiCache node type (default: cache.t3.micro)
- `docker_username`: Docker Hub username (default: your-dockerhub-username)

### Customization

To customize the deployment:

1. **Change region**: Update `aws_region` variable
2. **Scale resources**: Modify `container_cpu`, `container_memory`, `desired_count`
3. **Database size**: Adjust `db_instance_class` and `db_allocated_storage`
4. **Redis capacity**: Change `redis_node_type`

## Monitoring

### CloudWatch Dashboard

Access the CloudWatch dashboard:
```bash
terraform output cloudwatch_dashboard_url
```

### Alerts

The following alerts are configured:
- High CPU utilization (>80%)
- High memory utilization (>85%)
- High response time (>2 seconds)
- HTTP 5XX errors (>10 in 5 minutes)

### Logs

Application logs are available in CloudWatch Logs:
- Log Group: `/ecs/koronet-web`
- ECS Agent logs
- Application logs

## Security

### Secrets Management

Database credentials are stored in AWS Secrets Manager:
```bash
terraform output secrets_manager_secret_arn
```

### Network Security

- Web server runs in private subnets
- Database in isolated database subnets
- Security groups with minimal required access
- All traffic encrypted in transit

### Access

The application is accessible via the Application Load Balancer:
```bash
terraform output load_balancer_dns_name
```

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Warning**: This will permanently delete all resources including databases. Ensure you have backups if needed.

## Troubleshooting

### Common Issues

1. **ECS Service not starting**: Check CloudWatch logs for application errors
2. **Database connection issues**: Verify security groups and Secrets Manager permissions
3. **Load balancer health checks failing**: Ensure application is responding on `/health` endpoint

### Useful Commands

```bash
# Check ECS service status
aws ecs describe-services --cluster koronet-web-cluster --services koronet-web-service

# View task logs
aws logs tail /ecs/koronet-web --follow

# Check load balancer target health
aws elbv2 describe-target-health --target-group-arn <TARGET_GROUP_ARN>
```

## Cost Optimization

- Uses Fargate Spot for cost savings
- RDS with automated backups and retention
- CloudWatch logs with 7-day retention
- ECR lifecycle policies to manage image storage
- Auto-scaling to handle traffic efficiently
