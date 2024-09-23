// mediablob.js
// Media storage for local serving

const express = require('express');
const cors = require('cors');
const morgan = require('morgan'); // Import morgan for logging
const fs = require('fs');
const path = require('path');
const os = require('os');

const app = express();
const port = 3000;

// Use morgan to log all requests
app.use(morgan('combined'));

// Use CORS to allow cross-origin requests
app.use(cors());

// Serve static files from the 'media' directory
app.use('/media', express.static('media'));

// Endpoint to list all media files
app.get('/media-list', (req, res) => {
  const directoryPath = path.join(__dirname, 'media');

  fs.readdir(directoryPath, (err, files) => {
    if (err) {
      console.error('Error scanning media directory:', err); // Log the error
      return res.status(500).send('Unable to scan media directory.');
    }

    const mediaFiles = files.map((file) => ({
      name: file,
      url: `http://${getLocalIPAddress()}:${port}/media/${encodeURIComponent(file)}`,
      type: getFileType(file),
    }));

    console.log(`Served media list with ${mediaFiles.length} files.`); // Log the action

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
    const ext = filename.split('.').pop().toLowerCase();
    if (['mp4', 'mov', 'avi'].includes(ext)) return 'video';
    if (['mp3', 'aac', 'wav', 'm4a'].includes(ext)) return 'audio';
    if (['jpg', 'jpeg', 'png', 'gif'].includes(ext)) return 'image';
    if (['pdf'].includes(ext)) return 'document';
    return 'other';
  }

// Start the server
app.listen(port, () => {
  console.log(`Media server running at http://${getLocalIPAddress()}:${port}`);
});