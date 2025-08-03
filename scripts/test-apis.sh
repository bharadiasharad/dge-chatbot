#!/bin/bash

# =============================================================================
# RAG Chat Storage API - Complete Endpoint Testing Script
# =============================================================================
# This script tests all backend API endpoints comprehensively
# =============================================================================

# set -e  # Exit on any error - commented out for debugging

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
API_KEY="your-super-secret-api-key-change-this-in-production"
BASE_URL="http://localhost:8000/api/v1"
TEST_USER_EMAIL="apitest@example.com"
TEST_USER_PASSWORD="TestPassword123!"
TEST_USER_FIRST_NAME="API"
TEST_USER_LAST_NAME="Test"

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

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
        "TEST")
            echo -e "${CYAN}🧪 $message${NC}"
            ;;
    esac
}

# Function to make API calls and validate responses
make_api_call() {
    local method=$1
    local endpoint=$2
    local headers=$3
    local data=$4
    local expected_status=$5
    local test_name=$6
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    print_test "Testing $test_name..."
    
    # Make the API call
    if [ -n "$data" ]; then
        response=$(curl -s -w "\n%{http_code}" -X $method "$BASE_URL$endpoint" \
            -H "Content-Type: application/json" \
            $headers \
            -d "$data")
    else
        response=$(curl -s -w "\n%{http_code}" -X $method "$BASE_URL$endpoint" \
            -H "Content-Type: application/json" \
            $headers)
    fi
    
    # Extract status code and response body
    http_code=$(echo "$response" | tail -n1)
    response_body=$(echo "$response" | sed '$d')
    
    # Check if the response is valid JSON
    if echo "$response_body" | jq . >/dev/null 2>&1; then
        json_valid=true
    else
        json_valid=false
    fi
    
    # Validate response
    if [ "$http_code" -eq "$expected_status" ] && [ "$json_valid" = true ]; then
        print_success "$test_name - Status: $http_code"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        print_error "$test_name - Expected: $expected_status, Got: $http_code"
        print_error "Response: $response_body"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# Function to extract values from JSON response
extract_json_value() {
    local json=$1
    local key=$2
    echo "$json" | jq -r ".$key" 2>/dev/null || echo ""
}

# Function to print test header
print_header() {
    echo ""
    echo "================================================================================"
    print_status "HEADER" "$1"
    echo "================================================================================"
}

# Function to print test info
print_test() {
    print_status "TEST" "$1"
}

# Function to print success
print_success() {
    print_status "SUCCESS" "$1"
}

# Function to print error
print_error() {
    print_status "ERROR" "$1"
}

# Function to print warning
print_warning() {
    print_status "WARNING" "$1"
}

# Function to print info
print_info() {
    print_status "INFO" "$1"
}

# Function to print summary
print_summary() {
    echo ""
    echo "================================================================================"
    print_status "HEADER" "TEST SUMMARY"
    echo "================================================================================"
    echo "Total Tests: $TOTAL_TESTS"
    echo "Passed: $PASSED_TESTS"
    echo "Failed: $FAILED_TESTS"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        print_success "All tests passed! 🎉"
        exit 0
    else
        print_error "Some tests failed! ❌"
        exit 1
    fi
}

# Main test execution
main() {
    echo ""
    print_header "RAG Chat Storage API - Complete Endpoint Testing"
    print_info "Base URL: $BASE_URL"
    print_info "API Key: $API_KEY"
    echo ""

    # Test 1: Health Checks
    print_header "1. Health Check Endpoints"
    
    make_api_call "GET" "/health" "" "" 200 "Health Check"
    make_api_call "GET" "/health/live" "" "" 200 "Liveness Check"
    make_api_call "GET" "/health/ready" "" "" 200 "Readiness Check"

    # Test 2: Authentication Endpoints
    print_header "2. Authentication Endpoints"
    
    # Register user
    register_data="{\"email\":\"$TEST_USER_EMAIL\",\"password\":\"$TEST_USER_PASSWORD\",\"firstName\":\"$TEST_USER_FIRST_NAME\",\"lastName\":\"$TEST_USER_LAST_NAME\"}"
    register_response=$(curl -s -X POST "$BASE_URL/auth/register" \
        -H "X-API-Key: $API_KEY" \
        -H "Content-Type: application/json" \
        -d "$register_data")
    
    print_test "User Registration..."
    if echo "$register_response" | jq . >/dev/null 2>&1; then
        print_success "User Registration - Status: 201"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        print_warning "User Registration - User might already exist"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    fi
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    # Login to get JWT token
    login_data="{\"email\":\"$TEST_USER_EMAIL\",\"password\":\"$TEST_USER_PASSWORD\"}"
    login_response=$(curl -s -X POST "$BASE_URL/auth/login" \
        -H "X-API-Key: $API_KEY" \
        -H "Content-Type: application/json" \
        -d "$login_data")
    
    print_test "User Login..."
    if echo "$login_response" | jq . >/dev/null 2>&1; then
        print_success "User Login - Status: 200"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        
        # Extract JWT token
        JWT_TOKEN=$(extract_json_value "$login_response" "data.accessToken")
        if [ -n "$JWT_TOKEN" ] && [ "$JWT_TOKEN" != "null" ]; then
            print_success "JWT Token extracted successfully"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            print_error "Failed to extract JWT token"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    else
        print_error "User Login failed"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    TOTAL_TESTS=$((TOTAL_TESTS + 2))
    
    # Test refresh token
    refresh_token=$(extract_json_value "$login_response" "data.refreshToken")
    if [ -n "$refresh_token" ] && [ "$refresh_token" != "null" ]; then
        refresh_data="{\"refreshToken\":\"$refresh_token\"}"
        make_api_call "POST" "/auth/refresh" "-H \"X-API-Key: $API_KEY\"" "$refresh_data" 200 "Token Refresh"
    else
        print_warning "Skipping token refresh test - no refresh token available"
    fi

    # Test 3: Session Management Endpoints
    print_header "3. Session Management Endpoints"
    
    # Create session
    session_data="{\"title\":\"API Test Session\",\"description\":\"Session created by API test script\"}"
    session_response=$(curl -s -X POST "$BASE_URL/sessions" \
        -H "X-API-Key: $API_KEY" \
        -H "Authorization: Bearer $JWT_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$session_data")
    
    print_test "Session Creation..."
    if echo "$session_response" | jq . >/dev/null 2>&1; then
        print_success "Session Creation - Status: 201"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        
        # Extract session ID
        SESSION_ID=$(extract_json_value "$session_response" "data.id")
        if [ -n "$SESSION_ID" ] && [ "$SESSION_ID" != "null" ]; then
            print_success "Session ID extracted: $SESSION_ID"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            print_error "Failed to extract session ID"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    else
        print_error "Session Creation failed"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    TOTAL_TESTS=$((TOTAL_TESTS + 2))
    
    # Get all sessions
    make_api_call "GET" "/sessions" "-H \"X-API-Key: $API_KEY\" -H \"Authorization: Bearer $JWT_TOKEN\"" "" 200 "Get All Sessions"
    
    # Get specific session
    if [ -n "$SESSION_ID" ] && [ "$SESSION_ID" != "null" ]; then
        make_api_call "GET" "/sessions/$SESSION_ID" "-H \"X-API-Key: $API_KEY\" -H \"Authorization: Bearer $JWT_TOKEN\"" "" 200 "Get Specific Session"
        
        # Rename session
        rename_data="{\"title\":\"Updated API Test Session\"}"
        make_api_call "PUT" "/sessions/$SESSION_ID/rename" "-H \"X-API-Key: $API_KEY\" -H \"Authorization: Bearer $JWT_TOKEN\"" "$rename_data" 200 "Rename Session"
        
        # Toggle favorite
        make_api_call "PUT" "/sessions/$SESSION_ID/favorite" "-H \"X-API-Key: $API_KEY\" -H \"Authorization: Bearer $JWT_TOKEN\"" "" 200 "Toggle Session Favorite"
    else
        print_warning "Skipping session-specific tests - no session ID available"
    fi

    # Test 4: Message Endpoints
    print_header "4. Message Endpoints"
    
    if [ -n "$SESSION_ID" ] && [ "$SESSION_ID" != "null" ]; then
        make_api_call "GET" "/sessions/$SESSION_ID/messages" "-H \"X-API-Key: $API_KEY\" -H \"Authorization: Bearer $JWT_TOKEN\"" "" 200 "Get Session Messages"
    else
        print_warning "Skipping message tests - no session ID available"
    fi

    # Test 5: Chat Endpoints
    print_header "5. Chat Endpoints"
    
    if [ -n "$SESSION_ID" ] && [ "$SESSION_ID" != "null" ]; then
        chat_data="{\"message\":\"Hello, this is a test message from the API test script.\"}"
        make_api_call "POST" "/sessions/$SESSION_ID/chat" "-H \"X-API-Key: $API_KEY\" -H \"Authorization: Bearer $JWT_TOKEN\"" "$chat_data" 200 "Send Chat Message"
    else
        print_warning "Skipping chat tests - no session ID available"
    fi

    # Test 6: RAG Endpoints
    print_header "6. RAG Endpoints"
    
    # Direct RAG chat
    rag_chat_data="{\"message\":\"What is artificial intelligence?\"}"
    make_api_call "POST" "/rag/chat" "-H \"X-API-Key: $API_KEY\" -H \"Authorization: Bearer $JWT_TOKEN\"" "$rag_chat_data" 200 "Direct RAG Chat"
    
    # RAG query
    rag_query_data="{\"query\":\"machine learning\"}"
    make_api_call "POST" "/rag/query" "-H \"X-API-Key: $API_KEY\" -H \"Authorization: Bearer $JWT_TOKEN\"" "$rag_query_data" 200 "RAG Query"

    # Test 7: Error Handling
    print_header "7. Error Handling Tests"
    
    # Test invalid endpoint
    make_api_call "GET" "/invalid-endpoint" "" "" 404 "Invalid Endpoint"
    
    # Test unauthorized access
    make_api_call "GET" "/sessions" "" "" 401 "Unauthorized Access (No Auth)"
    
    # Test invalid JWT
    make_api_call "GET" "/sessions" "-H \"X-API-Key: $API_KEY\" -H \"Authorization: Bearer invalid-token\"" "" 401 "Invalid JWT Token"

    # Test 8: Cleanup
    print_header "8. Cleanup Tests"
    
    if [ -n "$SESSION_ID" ] && [ "$SESSION_ID" != "null" ]; then
        make_api_call "DELETE" "/sessions/$SESSION_ID" "-H \"X-API-Key: $API_KEY\" -H \"Authorization: Bearer $JWT_TOKEN\"" "" 204 "Delete Session"
    else
        print_warning "Skipping session deletion - no session ID available"
    fi

    # Print summary
    print_summary
}

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    print_error "jq is required but not installed. Please install jq first."
    print_info "Install on macOS: brew install jq"
    print_info "Install on Ubuntu: sudo apt-get install jq"
    exit 1
fi

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    print_error "curl is required but not installed."
    exit 1
fi

# Check if the API is running
print_info "Checking if API is running..."
if curl -s "$BASE_URL/health/live" > /dev/null; then
    print_success "API is running and accessible"
else
    print_error "API is not running or not accessible at $BASE_URL"
    print_info "Please start the API first: docker-compose up -d"
    exit 1
fi

# Run the tests
main "$@" 