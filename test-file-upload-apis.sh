#!/bin/bash

# Test File Upload APIs for 4 Secrets Wedding API
# Tests all file upload endpoints including backward compatibility

SERVER_URL="http://localhost:3001"
TEST_IMAGE="test-image.jpg"
TEST_PDF="test-document.pdf"

echo "🧪 Testing File Upload APIs"
echo "=========================="
echo "Server: $SERVER_URL"
echo ""

# Create test files if they don't exist
if [ ! -f "$TEST_IMAGE" ]; then
    echo "📸 Creating test image..."
    # Create a simple test image (1x1 pixel PNG)
    echo -e '\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x02\x00\x00\x00\x90wS\xde\x00\x00\x00\tpHYs\x00\x00\x0b\x13\x00\x00\x0b\x13\x01\x00\x9a\x9c\x18\x00\x00\x00\nIDATx\x9cc\xf8\x00\x00\x00\x01\x00\x01\x00\x00\x00\x00IEND\xaeB`\x82' > "$TEST_IMAGE"
fi

if [ ! -f "$TEST_PDF" ]; then
    echo "📄 Creating test PDF..."
    echo "%PDF-1.4
1 0 obj
<<
/Type /Catalog
/Pages 2 0 R
>>
endobj
2 0 obj
<<
/Type /Pages
/Kids [3 0 R]
/Count 1
>>
endobj
3 0 obj
<<
/Type /Page
/Parent 2 0 R
/MediaBox [0 0 612 792]
>>
endobj
xref
0 4
0000000000 65535 f 
0000000009 00000 n 
0000000058 00000 n 
0000000115 00000 n 
trailer
<<
/Size 4
/Root 1 0 R
>>
startxref
190
%%EOF" > "$TEST_PDF"
fi

echo ""

# Test 1: File API Status
echo "🔍 Test 1: File API Status"
echo "GET $SERVER_URL/api/files/status"
curl -s "$SERVER_URL/api/files/status" | jq '.' || echo "Response: $(curl -s "$SERVER_URL/api/files/status")"
echo ""

# Test 2: Legacy Image API Status
echo "🔍 Test 2: Legacy Image API Status"
echo "GET $SERVER_URL/api/images/status"
curl -s "$SERVER_URL/api/images/status" | jq '.' || echo "Response: $(curl -s "$SERVER_URL/api/images/status")"
echo ""

# Test 3: Upload Image (New endpoint)
echo "🔍 Test 3: Upload File (Image)"
echo "POST $SERVER_URL/upload"
UPLOAD_RESPONSE=$(curl -s -X POST -F "file=@$TEST_IMAGE" "$SERVER_URL/upload")
echo "Response: $UPLOAD_RESPONSE"
IMAGE_URL=$(echo "$UPLOAD_RESPONSE" | jq -r '.file.url // .image.url // empty')
echo "Image URL: $IMAGE_URL"
echo ""

# Test 4: Upload PDF
echo "🔍 Test 4: Upload File (PDF)"
echo "POST $SERVER_URL/upload"
PDF_RESPONSE=$(curl -s -X POST -F "file=@$TEST_PDF" "$SERVER_URL/upload")
echo "Response: $PDF_RESPONSE"
PDF_URL=$(echo "$PDF_RESPONSE" | jq -r '.file.url // empty')
echo "PDF URL: $PDF_URL"
echo ""

# Test 5: Legacy Image Upload
echo "🔍 Test 5: Legacy Image Upload"
echo "POST $SERVER_URL/upload-image"
LEGACY_RESPONSE=$(curl -s -X POST -F "image=@$TEST_IMAGE" "$SERVER_URL/upload-image")
echo "Response: $LEGACY_RESPONSE"
LEGACY_URL=$(echo "$LEGACY_RESPONSE" | jq -r '.image.url // empty')
echo "Legacy Image URL: $LEGACY_URL"
echo ""

# Test 6: Get Files List
echo "🔍 Test 6: Get Files List"
echo "GET $SERVER_URL/files"
curl -s "$SERVER_URL/files" | jq '.' || echo "Response: $(curl -s "$SERVER_URL/files")"
echo ""

# Test 7: Get Images List (Legacy)
echo "🔍 Test 7: Get Images List (Legacy)"
echo "GET $SERVER_URL/images"
curl -s "$SERVER_URL/images" | jq '.' || echo "Response: $(curl -s "$SERVER_URL/images")"
echo ""

# Test 8: Access uploaded file
if [ ! -z "$IMAGE_URL" ]; then
    echo "🔍 Test 8: Access Uploaded Image"
    echo "GET $SERVER_URL$IMAGE_URL"
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$SERVER_URL$IMAGE_URL")
    echo "HTTP Status: $HTTP_CODE"
    if [ "$HTTP_CODE" = "200" ]; then
        echo "✅ File accessible"
    else
        echo "❌ File not accessible"
    fi
    echo ""
fi

# Test 9: Delete File
if [ ! -z "$PDF_URL" ]; then
    echo "🔍 Test 9: Delete File"
    echo "DELETE $SERVER_URL/files/delete"
    DELETE_RESPONSE=$(curl -s -X DELETE -H "Content-Type: application/json" -d "{\"file_url\":\"$PDF_URL\"}" "$SERVER_URL/files/delete")
    echo "Response: $DELETE_RESPONSE"
    echo ""
fi

# Test 10: Delete Image (Legacy)
if [ ! -z "$LEGACY_URL" ]; then
    echo "🔍 Test 10: Delete Image (Legacy)"
    echo "DELETE $SERVER_URL/images/delete"
    DELETE_IMG_RESPONSE=$(curl -s -X DELETE -H "Content-Type: application/json" -d "{\"image_url\":\"$LEGACY_URL\"}" "$SERVER_URL/images/delete")
    echo "Response: $DELETE_IMG_RESPONSE"
    echo ""
fi

echo "🎉 File Upload API Tests Complete!"
echo ""
echo "📋 Summary:"
echo "- File upload endpoint: POST /upload"
echo "- Legacy image upload: POST /upload-image"
echo "- Files list: GET /files"
echo "- Images list: GET /images (legacy)"
echo "- File delete: DELETE /files/delete"
echo "- Image delete: DELETE /images/delete (legacy)"
echo "- File status: GET /api/files/status"
echo "- Image status: GET /api/images/status (legacy)"
echo ""
echo "🔗 File access URLs:"
echo "- Files: $SERVER_URL/files/[filename]"
echo "- Images: $SERVER_URL/images/[filename] (legacy)"

# Cleanup test files
rm -f "$TEST_IMAGE" "$TEST_PDF"
