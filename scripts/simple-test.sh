#!/bin/bash

# Simple API Test Script
API_KEY="your-super-secret-api-key-change-this-in-production"
BASE_URL="http://localhost:8000/api/v1"

echo "🧪 Testing RAG Chat Storage API"
echo "=================================="

# Test 1: Health Check
echo "1. Testing Health Check..."
response=$(curl -s -X GET "$BASE_URL/health/live")
echo "Response: $response"
echo ""

# Test 2: Register User
echo "2. Testing User Registration..."
register_response=$(curl -s -X POST "$BASE_URL/auth/register" \
  -H "X-API-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "TestPassword123!",
    "firstName": "Test",
    "lastName": "User"
  }')
echo "Register Response: $register_response"
echo ""

# Test 3: Login
echo "3. Testing User Login..."
login_response=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "X-API-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "TestPassword123!"
  }')
echo "Login Response: $login_response"
echo ""

# Extract JWT token
JWT_TOKEN=$(echo "$login_response" | jq -r '.data.accessToken' 2>/dev/null)
if [ "$JWT_TOKEN" != "null" ] && [ -n "$JWT_TOKEN" ]; then
    echo "✅ JWT Token extracted: ${JWT_TOKEN:0:20}..."
    
    # Test 4: Create Session
    echo "4. Testing Session Creation..."
    session_response=$(curl -s -X POST "$BASE_URL/sessions" \
      -H "X-API-Key: $API_KEY" \
      -H "Authorization: Bearer $JWT_TOKEN" \
      -H "Content-Type: application/json" \
      -d '{
        "title": "Test Session",
        "description": "Session created by test script"
      }')
    echo "Session Response: $session_response"
    echo ""
    
    # Extract session ID
    SESSION_ID=$(echo "$session_response" | jq -r '.data.id' 2>/dev/null)
    if [ "$SESSION_ID" != "null" ] && [ -n "$SESSION_ID" ]; then
        echo "✅ Session ID extracted: $SESSION_ID"
        
        # Test 5: Get Sessions
        echo "5. Testing Get Sessions..."
        sessions_response=$(curl -s -X GET "$BASE_URL/sessions" \
          -H "X-API-Key: $API_KEY" \
          -H "Authorization: Bearer $JWT_TOKEN")
        echo "Sessions Response: $sessions_response"
        echo ""
        
        # Test 6: Send Chat Message
        echo "6. Testing Chat Message..."
        chat_response=$(curl -s -X POST "$BASE_URL/sessions/$SESSION_ID/chat" \
          -H "X-API-Key: $API_KEY" \
          -H "Authorization: Bearer $JWT_TOKEN" \
          -H "Content-Type: application/json" \
          -d '{
            "message": "Hello, this is a test message!"
          }')
        echo "Chat Response: $chat_response"
        echo ""
        
        # Test 7: RAG Chat
        echo "7. Testing RAG Chat..."
        rag_response=$(curl -s -X POST "$BASE_URL/rag/chat" \
          -H "X-API-Key: $API_KEY" \
          -H "Authorization: Bearer $JWT_TOKEN" \
          -H "Content-Type: application/json" \
          -d '{
            "message": "What is artificial intelligence?"
          }')
        echo "RAG Response: $rag_response"
        echo ""
        
        # Test 8: Delete Session
        echo "8. Testing Session Deletion..."
        delete_response=$(curl -s -X DELETE "$BASE_URL/sessions/$SESSION_ID" \
          -H "X-API-Key: $API_KEY" \
          -H "Authorization: Bearer $JWT_TOKEN")
        echo "Delete Response: $delete_response"
        echo ""
    else
        echo "❌ Failed to extract session ID"
    fi
else
    echo "❌ Failed to extract JWT token"
fi

echo "✅ API Testing Complete!" 