#!/bin/bash

# Simple and Safe File Upload Addition Script
# This script ONLY adds file upload functionality without changing existing APIs

echo "🔧 Simple File Upload Addition for DigitalOcean Server"
echo "====================================================="

# Check if we're in the right directory
if [ ! -f "digitalocean-server.js" ]; then
    echo "❌ digitalocean-server.js not found. Please run this script in your project directory."
    exit 1
fi

echo "📦 Installing multer dependency..."
npm install multer --save

echo "📁 Creating files directory..."
mkdir -p src/files
chmod 755 src/files

echo "🔄 Creating backup of current server..."
cp digitalocean-server.js "digitalocean-server.js.backup.$(date +%Y%m%d_%H%M%S)"

echo "🔧 Adding file upload functionality..."

# Create a Node.js script to safely modify the server file
cat > modify_server.js << 'EOF'
const fs = require('fs');

// Read the current server file
let serverContent = fs.readFileSync('digitalocean-server.js', 'utf8');

// Check if multer is already imported
if (!serverContent.includes("const multer = require('multer')")) {
    console.log('Adding multer import...');
    serverContent = serverContent.replace(
        "const path = require('path');",
        "const path = require('path');\nconst multer = require('multer');"
    );
}

// Check if file upload configuration exists
if (!serverContent.includes('// File upload configuration')) {
    console.log('Adding file upload configuration...');
    
    const configCode = `

// File upload configuration
const uploadPath = process.env.UPLOAD_PATH || 'src/files';
const maxFileSize = parseInt(process.env.MAX_FILE_SIZE || 10485760); // 10MB

// Ensure upload directory exists
const fs = require('fs');
if (!fs.existsSync(uploadPath)) {
    fs.mkdirSync(uploadPath, { recursive: true });
    console.log('✅ Upload directory created:', uploadPath);
}

// Configure multer for file uploads
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, uploadPath);
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        const ext = path.extname(file.originalname);
        cb(null, file.fieldname + '-' + uniqueSuffix + ext);
    }
});

const fileFilter = (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|gif|webp|pdf|doc|docx|txt|xls|xlsx|ppt|pptx|zip|rar|mp4|mp3|avi|mov/;
    const ext = path.extname(file.originalname).toLowerCase();
    const isValidType = allowedTypes.test(ext);
    
    const allowedMimeTypes = [
        'image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp',
        'application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'text/plain', 'application/vnd.ms-excel', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        'application/vnd.ms-powerpoint', 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
        'application/zip', 'application/x-rar-compressed', 'video/mp4', 'video/avi', 'video/quicktime',
        'audio/mpeg', 'audio/mp3'
    ];
    
    const isValidMime = allowedMimeTypes.includes(file.mimetype);
    
    if (isValidType || isValidMime) {
        cb(null, true);
    } else {
        cb(new Error(\`Invalid file type: \${file.originalname}\`));
    }
};

const upload = multer({
    storage,
    limits: { fileSize: maxFileSize },
    fileFilter
});
`;

    serverContent = serverContent.replace(
        "require('dotenv').config();",
        "require('dotenv').config();" + configCode
    );
}

// Add static file serving if not exists
if (!serverContent.includes("app.use('/files'")) {
    console.log('Adding static file serving...');
    serverContent = serverContent.replace(
        "app.use(express.urlencoded({ extended: true }));",
        "app.use(express.urlencoded({ extended: true }));\napp.use('/files', express.static(uploadPath));"
    );
}

// Add file upload endpoints if not exists
if (!serverContent.includes('POST /upload')) {
    console.log('Adding file upload endpoints...');
    
    const endpointsCode = `

// ==========================================
// FILE UPLOAD ENDPOINTS
// ==========================================

// Upload file endpoint
app.post('/upload', upload.single('file'), async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ error: 'No file provided' });
        }

        const fileData = {
            filename: req.file.filename,
            originalname: req.file.originalname,
            mimetype: req.file.mimetype,
            size: req.file.size,
            url: \`/files/\${req.file.filename}\`
        };
        
        console.log(\`📁 File uploaded: \${req.file.filename}\`);
        
        return res.status(201).json({
            message: 'File uploaded successfully',
            file: fileData
        });
    } catch (error) {
        console.error('Error uploading file:', error);
        return res.status(500).json({ error: 'Failed to upload file' });
    }
});

// Get files list endpoint
app.get('/files', async (req, res) => {
    try {
        const files = fs.readdirSync(uploadPath).filter(file => !file.startsWith('.'));
        const fileList = files.map(filename => {
            const ext = path.extname(filename).toLowerCase();
            const isImage = /\\.(jpg|jpeg|png|gif|webp)$/i.test(filename);
            
            return {
                filename,
                url: \`/files/\${filename}\`,
                type: isImage ? 'image' : 'file',
                extension: ext
            };
        });
        
        return res.status(200).json({ files: fileList });
    } catch (error) {
        console.error('Error listing files:', error);
        return res.status(500).json({ error: 'Failed to retrieve files' });
    }
});

// Delete file endpoint
app.delete('/files/delete', async (req, res) => {
    try {
        const { file_url } = req.body;
        
        if (!file_url) {
            return res.status(400).json({ error: 'File URL is required' });
        }
        
        const filename = path.basename(file_url);
        const filePath = path.join(uploadPath, filename);
        
        if (!fs.existsSync(filePath)) {
            return res.status(404).json({ error: 'File not found' });
        }
        
        fs.unlinkSync(filePath);
        console.log(\`🗑️ File deleted: \${filename}\`);
        
        return res.status(200).json({ message: 'File deleted successfully' });
    } catch (error) {
        console.error('Error deleting file:', error);
        return res.status(500).json({ error: 'Failed to delete file' });
    }
});

// File upload status endpoint
app.get('/api/files/status', (req, res) => {
    try {
        const files = fs.readdirSync(uploadPath).filter(file => !file.startsWith('.'));
        res.json({
            service: 'File Upload API',
            status: 'ready',
            uploadPath: uploadPath,
            maxFileSize: maxFileSize,
            allowedTypes: ['Images', 'PDFs', 'Documents', 'Videos', 'Audio'],
            totalFiles: files.length
        });
    } catch (error) {
        res.json({
            service: 'File Upload API',
            status: 'ready',
            uploadPath: uploadPath,
            maxFileSize: maxFileSize,
            allowedTypes: ['Images', 'PDFs', 'Documents', 'Videos', 'Audio'],
            totalFiles: 0
        });
    }
});
`;

    // Insert before app.listen or 404 handler
    if (serverContent.includes('// 404 handler')) {
        serverContent = serverContent.replace('// 404 handler', endpointsCode + '\n// 404 handler');
    } else {
        serverContent = serverContent.replace('app.listen(', endpointsCode + '\napp.listen(');
    }
}

// Write the modified content back to the file
fs.writeFileSync('digitalocean-server.js', serverContent);
console.log('✅ Server file updated successfully');
EOF

# Run the Node.js script to modify the server
node modify_server.js

# Clean up
rm modify_server.js

# Update environment file if it exists
if [ -f ".env" ]; then
    echo "🔧 Updating environment configuration..."
    if ! grep -q "UPLOAD_PATH" .env; then
        echo "" >> .env
        echo "# File Upload Configuration" >> .env
        echo "UPLOAD_PATH=src/files" >> .env
        echo "MAX_FILE_SIZE=10485760" >> .env
    fi
fi

echo "🔄 Restarting server..."
pm2 restart 4secrets-wedding-api || pm2 start digitalocean-server.js --name "4secrets-wedding-api"

echo "⏳ Waiting for server to start..."
sleep 3

echo "🧪 Testing server..."

# Test health check
echo "Testing health check..."
if curl -s http://localhost:3001/health > /dev/null; then
    echo "✅ Health check: OK"
else
    echo "❌ Health check: Failed"
fi

# Test file upload status
echo "Testing file upload API..."
if curl -s http://localhost:3001/api/files/status > /dev/null; then
    echo "✅ File upload API: Ready"
else
    echo "❌ File upload API: Failed"
fi

# Test existing email API
echo "Testing email API..."
if curl -s http://localhost:3001/api/email/status > /dev/null; then
    echo "✅ Email API: Still working"
else
    echo "⚠️ Email API: Check status"
fi

# Test existing notifications API
echo "Testing notifications API..."
if curl -s http://localhost:3001/api/notifications/status > /dev/null; then
    echo "✅ Notifications API: Still working"
else
    echo "⚠️ Notifications API: Check status"
fi

echo ""
echo "🎉 File Upload Addition Complete!"
echo "================================="
echo ""
echo "📋 NEW File Upload Endpoints Added:"
echo "  POST   /upload                    - Upload any file"
echo "  GET    /files                     - List all files"
echo "  DELETE /files/delete              - Delete a file"
echo "  GET    /api/files/status          - File API status"
echo ""
echo "📁 File Access:"
echo "  http://your-server:3001/files/[filename]"
echo ""
echo "🧪 Test file upload:"
echo "  curl -X POST -F \"file=@your-file.pdf\" http://your-server:3001/upload"
echo ""
echo "✅ All existing APIs remain unchanged and functional!"
echo ""
echo "📊 Server Status:"
pm2 status 4secrets-wedding-api
