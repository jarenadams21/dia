// media-blob.js

const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');
const os = require('os');
const morgan = require('morgan');

const app = express();
const port = 3000;

// Use morgan for logging
app.use(morgan('combined'));

// Enable CORS
app.use(cors());

// Serve static files from the 'media' directory
app.use('/media', express.static(path.join(__dirname, 'media')));

// Endpoint to list all media files
app.get('/media-list', (req, res) => {
    const directoryPath = path.join(__dirname, 'media');

    fs.readdir(directoryPath, (err, files) => {
        if (err) {
            console.error('Error scanning media directory:', err);
            return res.status(500).send('Unable to scan media directory.');
        }

        // Filter out hidden files and unsupported formats
        const supportedExtensions = ['mp3', 'mp4', 'mov'];
        const visibleFiles = files.filter(file => {
            const ext = path.extname(file).toLowerCase().substring(1);
            return !file.startsWith('.') && supportedExtensions.includes(ext);
        });

        const mediaFiles = visibleFiles.map(file => ({
            name: file,
            url: `http://${getLocalIPAddress()}:${port}/media/${encodeURIComponent(file)}`,
            type: getFileType(file),
        }));

        console.log(`Served media list with ${mediaFiles.length} files.`);
        res.json(mediaFiles);
    });
});

// Helper function to get local IP address
function getLocalIPAddress() {
    const interfaces = os.networkInterfaces();
    for (const iface of Object.values(interfaces)) {
        for (const alias of iface) {
            if (alias.family === 'IPv4' && !alias.internal) {
                return alias.address;
            }
        }
    }
}

// Helper function to determine file type
function getFileType(filename) {
    const ext = path.extname(filename).toLowerCase();
    if (['.mp4', '.mov'].includes(ext)) return 'video';
    if (['.mp3'].includes(ext)) return 'audio';
    return 'other';
}

app.listen(port, () => {
    console.log(`Media server running at http://${getLocalIPAddress()}:${port}`);
});