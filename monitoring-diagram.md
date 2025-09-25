# Koronet Web Server Monitoring Architecture

## High-Level Monitoring Setup

```mermaid
graph TB
    subgraph "AWS ECS Cluster"
        subgraph "Application Layer"
            WS[Koronet Web Server<br/>Port 3000]
            PG[PostgreSQL<br/>Port 5432]
            RD[Redis<br/>Port 6379]
        end
        
        subgraph "Monitoring Layer"
            PE[Prometheus Exporter<br/>Port 9090]
            GE[Grafana<br/>Port 3000]
            NE[Node Exporter<br/>Port 9100]
            CE[cAdvisor<br/>Port 8080]
            RE[Redis Exporter<br/>Port 9121]
            PGE[Postgres Exporter<br/>Port 9187]
        end
        
        subgraph "Sidecar Containers"
            SC[CloudWatch Agent<br/>Sidecar]
            AM[Application Metrics<br/>Sidecar]
        end
    end
    
    subgraph "AWS CloudWatch"
        CW[CloudWatch Logs]
        CM[CloudWatch Metrics]
        CA[CloudWatch Alarms]
    end
    
    subgraph "External Monitoring"
        AL[AlertManager]
        SL[Slack/Email Alerts]
    end
    
    %% Application connections
    WS --> PG
    WS --> RD
    
    %% Monitoring data flow
    WS --> PE
    PG --> PGE
    RD --> RE
    
    %% System metrics
    NE --> PE
    CE --> PE
    
    %% Visualization
    PE --> GE
    
    %% AWS Integration
    SC --> CW
    AM --> CM
    CM --> CA
    CA --> AL
    AL --> SL
    
    %% External access
    GE --> |Dashboards| User[DevOps Team]
    AL --> |Alerts| User
```

## Monitoring Components

### 1. Application Monitoring
- **Koronet Web Server**: Custom metrics for request count, response time, error rate
- **PostgreSQL**: Database connection pool, query performance, slow queries
- **Redis**: Cache hit/miss ratio, memory usage, connection count

### 2. Infrastructure Monitoring
- **Node Exporter**: System metrics (CPU, memory, disk, network)
- **cAdvisor**: Container metrics (resource usage, restart count)
- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization and dashboards

### 3. AWS CloudWatch Integration
- **CloudWatch Agent**: System and application logs
- **CloudWatch Metrics**: Custom application metrics
- **CloudWatch Alarms**: Automated alerting based on thresholds

### 4. Alerting
- **AlertManager**: Handles alerts from Prometheus
- **Notification Channels**: Slack, email, PagerDuty integration

## Key Metrics to Monitor

### Application Metrics
- HTTP request rate and response time
- Database connection pool utilization
- Redis cache performance
- Error rates and status codes

### Infrastructure Metrics
- CPU and memory utilization
- Disk I/O and space
- Network throughput
- Container health and restarts

### Business Metrics
- Active user sessions
- API endpoint usage
- Database query performance
- Cache effectiveness

## Alerting Rules

### Critical Alerts
- Application down (HTTP 5xx errors > 5%)
- Database connection failures
- High memory usage (> 90%)
- Disk space low (< 10% free)

### Warning Alerts
- High response time (> 2 seconds)
- Cache miss rate high (> 50%)
- CPU usage high (> 80%)
- Unusual traffic patterns
