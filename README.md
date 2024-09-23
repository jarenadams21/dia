# First Project : Mac Media Blob for Mobile via Swift and Express

{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "MediaPoolItem",
  "type": "object",
  "properties": {
    "id": { "type": "string" },
    "filename": { "type": "string" },
    "fileSize": { "type": "integer" },
    "fileType": { "type": "string", "enum": ["video/mp4"] },
    "createdAt": { "type": "string", "format": "date-time" },
    "updatedAt": { "type": "string", "format": "date-time" },
    "filePath": { "type": "string" },
    "thumbnail": { "type": ["string", "null"] },
    "duration": { "type": ["number", "null"] },
    "metadata": {
      "type": ["object", "null"],
      "properties": {
        "title": { "type": ["string", "null"] },
        "description": { "type": ["string", "null"] },
        "tags": { "type": ["array", "null"], "items": { "type": "string" } }
      }
    }
  },
  "required": ["id", "filename", "fileSize", "fileType", "createdAt", "filePath"]
}
