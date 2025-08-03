#!/bin/bash

# =============================================================================
# RAG Chat Storage Microservice - Setup Script
# =============================================================================
# This script sets up the development environment and initializes the application
# =============================================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "INFO")
            echo -e "${BLUE}ℹ️  $message${NC}"
            ;;
        "SUCCESS")
            echo -e "${GREEN}✅ $message${NC}"
            ;;
        "WARNING")
            echo -e "${YELLOW}⚠️  $message${NC}"
            ;;
        "ERROR")
            echo -e "${RED}❌ $message${NC}"
            ;;
        "HEADER")
            echo -e "${PURPLE}📋 $message${NC}"
            ;;
        "STEP")
            echo -e "${CYAN}🔧 $message${NC}"
            ;;
    esac
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check Docker status
check_docker() {
    if ! command_exists docker; then
        print_status "ERROR" "Docker is not installed. Please install Docker first."
        print_status "INFO" "Visit: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        print_status "ERROR" "Docker is not running. Please start Docker first."
        exit 1
    fi
    
    print_status "SUCCESS" "Docker is installed and running"
}

# Function to check Node.js
check_nodejs() {
    if ! command_exists node; then
        print_status "ERROR" "Node.js is not installed. Please install Node.js 18+ first."
        print_status "INFO" "Visit: https://nodejs.org/"
        exit 1
    fi
    
    NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -lt 18 ]; then
        print_status "ERROR" "Node.js version 18+ is required. Current version: $(node --version)"
        exit 1
    fi
    
    print_status "SUCCESS" "Node.js $(node --version) is installed"
}

# Function to setup environment files
setup_environment() {
    print_status "STEP" "Setting up environment files..."
    
    # Copy environment example files if they don't exist
    if [ ! -f .env ]; then
        if [ -f .env.example ]; then
            cp .env.example .env
            print_status "SUCCESS" "Created .env from .env.example"
        else
            print_status "WARNING" ".env.example not found, creating basic .env"
            cat > .env << EOF
# =============================================================================
# RAG CHAT STORAGE - ENVIRONMENT CONFIGURATION
# =============================================================================

# Application Configuration
NODE_ENV=development
PORT=8000
API_PREFIX=/api/v1

# Database Configuration
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=postgres
DATABASE_NAME=rag_chat_storage
DATABASE_SSL=false
DATABASE_SYNCHRONIZE=true
DATABASE_LOGGING=false

# Redis Configuration
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DB=0

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRES_IN=24h
JWT_REFRESH_SECRET=your-super-secret-refresh-jwt-key-change-this-in-production
JWT_REFRESH_EXPIRES_IN=7d

# API Key Configuration
API_KEY=your-super-secret-api-key-change-this-in-production

# Ollama Configuration
OLLAMA_HOST=localhost
OLLAMA_PORT=11434
OLLAMA_MODEL=phi3:mini
OLLAMA_TIMEOUT=300000
OLLAMA_TEMPERATURE=0.7
OLLAMA_TOP_P=0.9
OLLAMA_MAX_TOKENS=1000

# Logging Configuration
LOG_LEVEL=debug
LOG_FILE_PATH=./logs
LOG_MAX_SIZE=10485760
LOG_MAX_FILES=5

# Rate Limiting
RATE_LIMIT_TTL=60
RATE_LIMIT_MAX=100

# CORS Configuration
CORS_ORIGIN=http://localhost:3001
CORS_METHODS=GET,HEAD,PUT,PATCH,POST,DELETE
CORS_CREDENTIALS=true

# File Upload Configuration
UPLOAD_MAX_SIZE=10485760
UPLOAD_DEST=./uploads

# Health Check Configuration
HEALTH_CHECK_TIMEOUT=5000
HEALTH_CHECK_INTERVAL=30000

# Swagger Configuration
SWAGGER_TITLE="RAG Chat Storage API"
SWAGGER_DESCRIPTION="API documentation for RAG Chat Storage Microservice"
SWAGGER_VERSION=1.0.0
SWAGGER_PATH=api/docs
EOF
        fi
    else
        print_status "INFO" ".env file already exists"
    fi
    
    # Create logs directory
    mkdir -p logs
    print_status "SUCCESS" "Created logs directory"
    
    # Create uploads directory
    mkdir -p uploads
    print_status "SUCCESS" "Created uploads directory"
}

# Function to install dependencies
install_dependencies() {
    print_status "STEP" "Installing Node.js dependencies..."
    
    if [ -f package.json ]; then
        npm install
        print_status "SUCCESS" "Node.js dependencies installed"
    else
        print_status "ERROR" "package.json not found"
        exit 1
    fi
}

# Function to build the application
build_application() {
    print_status "STEP" "Building the application..."
    
    npm run build
    print_status "SUCCESS" "Application built successfully"
}

# Function to setup Docker
setup_docker() {
    print_status "STEP" "Setting up Docker environment..."
    
    # Check if docker-compose.yml exists
    if [ ! -f docker-compose.yml ]; then
        print_status "ERROR" "docker-compose.yml not found"
        exit 1
    fi
    
    # Pull latest images
    print_status "INFO" "Pulling Docker images..."
    docker-compose pull
    
    print_status "SUCCESS" "Docker environment setup complete"
}

# Function to start services
start_services() {
    print_status "STEP" "Starting services with Docker Compose..."
    
    # Start all services
    docker-compose up -d
    
    print_status "SUCCESS" "Services started successfully"
    
    # Wait for services to be ready
    print_status "INFO" "Waiting for services to be ready..."
    sleep 10
    
    # Check service status
    docker-compose ps
}

# Function to setup Ollama models
setup_ollama() {
    print_status "STEP" "Setting up Ollama models..."
    
    # Wait for Ollama to be ready
    print_status "INFO" "Waiting for Ollama to be ready..."
    sleep 15
    
    # Check if Ollama is running
    if curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then
        print_status "SUCCESS" "Ollama is running"
        
        # Pull required models
        print_status "INFO" "Pulling Ollama models..."
        curl -X POST http://localhost:11434/api/pull -d '{"name": "phi3:mini"}'
        
        print_status "SUCCESS" "Ollama models setup complete"
    else
        print_status "WARNING" "Ollama is not running. Models will be pulled on first use."
    fi
}

# Function to run health checks
run_health_checks() {
    print_status "STEP" "Running health checks..."
    
    # Wait for application to be ready
    print_status "INFO" "Waiting for application to be ready..."
    sleep 20
    
    # Check application health
    if curl -s http://localhost:8000/api/v1/health/live >/dev/null 2>&1; then
        print_status "SUCCESS" "Application is healthy"
    else
        print_status "WARNING" "Application health check failed"
    fi
    
    # Check database
    if docker-compose exec -T postgres pg_isready -U postgres >/dev/null 2>&1; then
        print_status "SUCCESS" "Database is ready"
    else
        print_status "WARNING" "Database health check failed"
    fi
    
    # Check Redis
    if docker-compose exec -T redis redis-cli ping >/dev/null 2>&1; then
        print_status "SUCCESS" "Redis is ready"
    else
        print_status "WARNING" "Redis health check failed"
    fi
}

# Function to display access information
display_access_info() {
    echo ""
    echo "================================================================================"
    print_status "HEADER" "SETUP COMPLETE"
    echo "================================================================================"
    echo ""
    print_status "SUCCESS" "RAG Chat Storage Microservice is ready!"
    echo ""
    echo "🌐 Access Points:"
    echo "   API Base URL: http://localhost:8000/api/v1"
    echo "   Swagger Docs: http://localhost:8000/api/docs"
    echo "   Health Check: http://localhost:8000/api/v1/health"
    echo "   pgAdmin:      http://localhost:5050 (admin@example.com / admin)"
    echo ""
    echo "🧪 Testing:"
    echo "   Run API tests: ./scripts/test-apis.sh"
    echo "   Run RAG tests: ./test-rag-functionality.sh"
    echo ""
    echo "📝 Development:"
    echo "   View logs:    docker-compose logs -f app"
    echo "   Stop services: docker-compose down"
    echo "   Restart:      docker-compose restart"
    echo ""
    echo "🔧 Configuration:"
    echo "   Environment:  .env"
    echo "   Docker:       docker-compose.yml"
    echo ""
    print_status "INFO" "For more information, see README.md and DEPLOYMENT.md"
    echo ""
}

# Main setup function
main() {
    echo ""
    echo "================================================================================"
    print_status "HEADER" "RAG Chat Storage Microservice Setup"
    echo "================================================================================"
    echo ""
    
    # Check prerequisites
    print_status "STEP" "Checking prerequisites..."
    check_docker
    check_nodejs
    
    # Setup environment
    setup_environment
    
    # Install dependencies
    install_dependencies
    
    # Build application
    build_application
    
    # Setup Docker
    setup_docker
    
    # Start services
    start_services
    
    # Setup Ollama
    setup_ollama
    
    # Run health checks
    run_health_checks
    
    # Display access information
    display_access_info
}

# Check if we're in the right directory
if [ ! -f "package.json" ] && [ ! -f "docker-compose.yml" ]; then
    print_status "ERROR" "This script must be run from the project root directory"
    print_status "INFO" "Please navigate to the project directory and run: ./scripts/setup.sh"
    exit 1
fi

# Run the setup
main "$@" 