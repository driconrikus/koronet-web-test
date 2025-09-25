#!/bin/bash

# Koronet Web Server - Terraform Deployment Script
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
AWS_REGION="us-west-2"
DOCKER_USERNAME=""
DOCKER_REPOSITORY=""
IMAGE_TAG="latest"

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI is not installed. Please install it first."
        exit 1
    fi
    
    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform is not installed. Please install it first."
        exit 1
    fi
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed. Please install it first."
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS credentials not configured. Please run 'aws configure' first."
        exit 1
    fi
    
    log_info "Prerequisites check passed!"
}

initialize_terraform() {
    log_info "Initializing Terraform..."
    terraform init
    log_info "Terraform initialized successfully!"
}

plan_terraform() {
    log_info "Planning Terraform deployment..."
    terraform plan -out=tfplan
    log_info "Terraform plan completed!"
}

apply_terraform() {
    log_info "Applying Terraform configuration..."
    terraform apply tfplan
    log_info "Infrastructure deployed successfully!"
}

get_outputs() {
    log_info "Getting Terraform outputs..."
    DOCKER_USERNAME=$(terraform output -raw docker_hub_repository | cut -d'/' -f1)
    DOCKER_REPOSITORY=$(terraform output -raw docker_hub_repository)
    log_info "Docker Repository: $DOCKER_REPOSITORY"
}

build_and_push_image() {
    log_info "Building and pushing Docker image..."
    
    # Login to Docker Hub
    echo "$DOCKER_PASSWORD" | docker login --username $DOCKER_USERNAME --password-stdin
    
    # Build image
    docker build -t koronet-web-app .
    
    # Tag image
    docker tag koronet-web-app:latest $DOCKER_REPOSITORY:$IMAGE_TAG
    
    # Push image
    docker push $DOCKER_REPOSITORY:$IMAGE_TAG
    
    log_info "Docker image pushed successfully!"
}

deploy_application() {
    log_info "Deploying application to ECS..."
    
    # Update ECS service to force new deployment
    aws ecs update-service \
        --cluster koronet-web-cluster \
        --service koronet-web-service \
        --force-new-deployment \
        --region $AWS_REGION
    
    log_info "Application deployment initiated!"
}

wait_for_deployment() {
    log_info "Waiting for deployment to complete..."
    
    aws ecs wait services-stable \
        --cluster koronet-web-cluster \
        --services koronet-web-service \
        --region $AWS_REGION
    
    log_info "Deployment completed successfully!"
}

show_access_info() {
    log_info "Deployment Summary:"
    echo "=================================="
    
    # Get load balancer DNS name
    LB_DNS=$(terraform output -raw load_balancer_dns_name)
    echo "Application URL: http://$LB_DNS"
    echo "Health Check: http://$LB_DNS/health"
    
    # Get CloudWatch dashboard URL
    DASHBOARD_URL=$(terraform output -raw cloudwatch_dashboard_url)
    echo "CloudWatch Dashboard: $DASHBOARD_URL"
    
    echo "=================================="
    log_info "Deployment completed successfully!"
}

# Main execution
main() {
    log_info "Starting Koronet Web Server deployment..."
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-terraform)
                SKIP_TERRAFORM=true
                shift
                ;;
            --skip-docker)
                SKIP_DOCKER=true
                shift
                ;;
            --image-tag)
                IMAGE_TAG="$2"
                shift 2
                ;;
            --help)
                echo "Usage: $0 [OPTIONS]"
                echo "Options:"
                echo "  --skip-terraform    Skip Terraform deployment"
                echo "  --skip-docker       Skip Docker build and push"
                echo "  --image-tag TAG     Use specific image tag (default: latest)"
                echo "  --help              Show this help message"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # Check prerequisites
    check_prerequisites
    
    # Deploy infrastructure
    if [[ "$SKIP_TERRAFORM" != "true" ]]; then
        initialize_terraform
        plan_terraform
        
        # Ask for confirmation
        read -p "Do you want to proceed with the deployment? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Deployment cancelled."
            exit 0
        fi
        
        apply_terraform
        get_outputs
    else
        log_warn "Skipping Terraform deployment"
        get_outputs
    fi
    
    # Build and push Docker image
    if [[ "$SKIP_DOCKER" != "true" ]]; then
        # Check for Docker Hub credentials
        if [[ -z "$DOCKER_PASSWORD" ]]; then
            log_error "DOCKER_PASSWORD environment variable is required for Docker Hub push"
            exit 1
        fi
        build_and_push_image
    else
        log_warn "Skipping Docker build and push"
    fi
    
    # Deploy application
    deploy_application
    wait_for_deployment
    
    # Show access information
    show_access_info
}

# Run main function
main "$@"
