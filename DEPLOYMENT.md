# Deployment Guide

## Quick Start

### Prerequisites
- Docker & Docker Compose
- Node.js 18+ (for local development)
- Git

### 1. Clone and Setup
```bash
git clone <repository-url>
cd rag-chat-storage-microservice
./scripts/setup.sh
```

### 2. Start with Docker
```bash
docker-compose up -d
docker-compose build app
docker-compose up -d app
```

### 3. Access Points
- **API**: http://localhost:8000
- **Swagger**: http://localhost:8000/api/docs
- **pgAdmin**: http://localhost:5050 (admin@example.com / admin)

### 4. Testing
cd scripts
sh test-apis.sh

## Production Deployment

### Environment Variables
Copy `.env.example` to `.env` and update:

```bash
# Production values
NODE_ENV=production
DATABASE_SSL=true
JWT_SECRET=strong-256-bit-secret
API_KEY=secure-api-key
```

### Docker Production
```bash
docker build -t rag-chat-storage:latest .
docker run -p 8000:8000 --env-file .env rag-chat-storage:latest
```

### Kubernetes
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rag-chat-storage
spec:
  replicas: 3
  selector:
    matchLabels:
      app: rag-chat-storage
  template:
    spec:
      containers:
      - name: app
        image: rag-chat-storage:latest
        ports:
        - containerPort: 8000
        livenessProbe:
          httpGet:
            path: /api/v1/health/live
            port: 8000
        readinessProbe:
          httpGet:
            path: /api/v1/health/ready
            port: 8000
```

## Health Checks
- **Liveness**: `/api/v1/health/live`
- **Readiness**: `/api/v1/health/ready`
- **Full Check**: `/api/v1/health`

## Security Checklist
- [ ] Strong JWT secrets (256-bit)
- [ ] Secure API keys
- [ ] HTTPS in production
- [ ] Database SSL enabled
- [ ] Rate limiting configured
- [ ] CORS properly set
- [ ] Environment variables secured