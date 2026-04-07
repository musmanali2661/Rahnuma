'use strict';

/**
 * OpenAPI 3.0 specification for the Rahnuma Navigation System API.
 */
const openApiSpec = {
  openapi: '3.0.3',
  info: {
    title: 'Rahnuma Navigation System API',
    description: 'Backend API for the Rahnuma Navigation System — Pakistan\'s open navigation platform',
    version: '1.0.0',
    contact: {
      name: 'Rahnuma Project',
    },
  },
  servers: [
    { url: '/api/v1', description: 'Version 1' },
  ],
  components: {
    securitySchemes: {
      bearerAuth: {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
      },
    },
    schemas: {
      Error: {
        type: 'object',
        properties: {
          error: { type: 'string' },
        },
      },
      ValidationError: {
        type: 'object',
        properties: {
          errors: {
            type: 'array',
            items: {
              type: 'object',
              properties: {
                msg: { type: 'string' },
                param: { type: 'string' },
              },
            },
          },
        },
      },
      AuthTokens: {
        type: 'object',
        properties: {
          accessToken: { type: 'string' },
          refreshToken: { type: 'string' },
        },
        required: ['accessToken', 'refreshToken'],
      },
      Waypoint: {
        type: 'object',
        properties: {
          lat: { type: 'number', minimum: -90, maximum: 90 },
          lon: { type: 'number', minimum: -180, maximum: 180 },
        },
        required: ['lat', 'lon'],
      },
      POI: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
          name: { type: 'string' },
          name_ur: { type: 'string' },
          category: { type: 'string' },
          subcategory: { type: 'string', nullable: true },
          lat: { type: 'number' },
          lon: { type: 'number' },
          rating_avg: { type: 'number', nullable: true },
          rating_count: { type: 'integer', nullable: true },
          phone: { type: 'string', nullable: true },
          opening_hours: { type: 'string', nullable: true },
        },
      },
      Report: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
          report_type: { type: 'string', enum: ['accident', 'police', 'flood', 'road_closed', 'protest'] },
          description: { type: 'string', nullable: true },
          lat: { type: 'number' },
          lon: { type: 'number' },
          verified: { type: 'boolean' },
          created_at: { type: 'string', format: 'date-time' },
          expires_at: { type: 'string', format: 'date-time', nullable: true },
        },
      },
      Event: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
          event_type: { type: 'string', enum: ['pothole', 'speed_bump', 'rough_road'] },
          confidence: { type: 'number', minimum: 0, maximum: 1 },
          geojson: { type: 'object' },
          created_at: { type: 'string', format: 'date-time' },
          verified: { type: 'boolean' },
        },
      },
      OfflinePackage: {
        type: 'object',
        properties: {
          id: { type: 'string' },
          name: { type: 'string' },
          size_mb: { type: 'number' },
          available: { type: 'boolean' },
          file_size_bytes: { type: 'integer', nullable: true },
          last_updated: { type: 'string', format: 'date-time', nullable: true },
        },
      },
    },
  },
  paths: {
    // ── Auth ──────────────────────────────────────────────────────────────────
    '/auth/register': {
      post: {
        summary: 'Register a new user',
        tags: ['Auth'],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                properties: {
                  email: { type: 'string', format: 'email' },
                  phone: { type: 'string' },
                  password: { type: 'string', minLength: 6 },
                  name: { type: 'string' },
                },
                required: ['password'],
              },
            },
          },
        },
        responses: {
          201: { description: 'User created', content: { 'application/json': { schema: { $ref: '#/components/schemas/AuthTokens' } } } },
          400: { description: 'Validation error', content: { 'application/json': { schema: { $ref: '#/components/schemas/ValidationError' } } } },
          409: { description: 'Email or phone already registered', content: { 'application/json': { schema: { $ref: '#/components/schemas/Error' } } } },
        },
      },
    },
    '/auth/login': {
      post: {
        summary: 'Authenticate and get tokens',
        tags: ['Auth'],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                properties: {
                  email: { type: 'string', format: 'email' },
                  phone: { type: 'string' },
                  password: { type: 'string' },
                },
                required: ['password'],
              },
            },
          },
        },
        responses: {
          200: { description: 'Login successful', content: { 'application/json': { schema: { $ref: '#/components/schemas/AuthTokens' } } } },
          400: { description: 'Validation error' },
          401: { description: 'Invalid credentials' },
        },
      },
    },
    '/auth/refresh': {
      post: {
        summary: 'Refresh access token',
        tags: ['Auth'],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                properties: {
                  refreshToken: { type: 'string' },
                },
                required: ['refreshToken'],
              },
            },
          },
        },
        responses: {
          200: {
            description: 'New access token',
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  properties: { accessToken: { type: 'string' } },
                },
              },
            },
          },
          401: { description: 'Invalid or expired refresh token' },
        },
      },
    },
    '/auth/logout': {
      post: {
        summary: 'Revoke refresh token',
        tags: ['Auth'],
        security: [{ bearerAuth: [] }],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                properties: { refreshToken: { type: 'string' } },
                required: ['refreshToken'],
              },
            },
          },
        },
        responses: {
          204: { description: 'Logged out successfully' },
          401: { description: 'Unauthenticated' },
        },
      },
    },

    // ── Route ─────────────────────────────────────────────────────────────────
    '/route': {
      post: {
        summary: 'Calculate a route between waypoints',
        tags: ['Route'],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                properties: {
                  waypoints: { type: 'array', items: { $ref: '#/components/schemas/Waypoint' }, minItems: 2, maxItems: 10 },
                  profile: { type: 'string', enum: ['car', 'bike', 'foot'], default: 'car' },
                  alternatives: { type: 'boolean', default: false },
                },
                required: ['waypoints'],
              },
            },
          },
        },
        responses: {
          200: { description: 'Route calculated' },
          400: { description: 'Validation error' },
          422: { description: 'No route found' },
          503: { description: 'Routing service unavailable' },
        },
      },
    },
    '/route/snap': {
      get: {
        summary: 'Snap a coordinate to the nearest road',
        tags: ['Route'],
        parameters: [
          { name: 'lat', in: 'query', required: true, schema: { type: 'number' } },
          { name: 'lon', in: 'query', required: true, schema: { type: 'number' } },
        ],
        responses: {
          200: { description: 'Snapped location' },
          400: { description: 'Validation error' },
        },
      },
    },

    // ── Search ────────────────────────────────────────────────────────────────
    '/search': {
      get: {
        summary: 'Search for places',
        tags: ['Search'],
        parameters: [
          { name: 'q', in: 'query', required: true, schema: { type: 'string' } },
          { name: 'lat', in: 'query', schema: { type: 'number' } },
          { name: 'lon', in: 'query', schema: { type: 'number' } },
          { name: 'limit', in: 'query', schema: { type: 'integer', default: 10 } },
          { name: 'category', in: 'query', schema: { type: 'string' } },
        ],
        responses: {
          200: { description: 'Search results' },
          400: { description: 'Validation error' },
        },
      },
    },
    '/search/reverse': {
      get: {
        summary: 'Reverse geocode a coordinate',
        tags: ['Search'],
        parameters: [
          { name: 'lat', in: 'query', required: true, schema: { type: 'number' } },
          { name: 'lon', in: 'query', required: true, schema: { type: 'number' } },
        ],
        responses: {
          200: { description: 'Address information' },
          400: { description: 'Validation error' },
        },
      },
    },

    // ── Events ────────────────────────────────────────────────────────────────
    '/events': {
      get: {
        summary: 'Get road events in a bounding box',
        tags: ['Events'],
        parameters: [
          { name: 'minLat', in: 'query', required: true, schema: { type: 'number' } },
          { name: 'minLon', in: 'query', required: true, schema: { type: 'number' } },
          { name: 'maxLat', in: 'query', required: true, schema: { type: 'number' } },
          { name: 'maxLon', in: 'query', required: true, schema: { type: 'number' } },
          { name: 'type', in: 'query', schema: { type: 'string', enum: ['pothole', 'speed_bump', 'rough_road'] } },
          { name: 'limit', in: 'query', schema: { type: 'integer', default: 200 } },
        ],
        responses: {
          200: {
            description: 'List of events',
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  properties: { events: { type: 'array', items: { $ref: '#/components/schemas/Event' } } },
                },
              },
            },
          },
          400: { description: 'Validation error' },
        },
      },
      post: {
        summary: 'Submit road events from IMU data',
        tags: ['Events'],
        security: [{ bearerAuth: [] }],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                properties: {
                  events: {
                    type: 'array',
                    minItems: 1,
                    maxItems: 50,
                    items: {
                      type: 'object',
                      properties: {
                        lat: { type: 'number' },
                        lon: { type: 'number' },
                        event_type: { type: 'string', enum: ['pothole', 'speed_bump', 'rough_road'] },
                        confidence: { type: 'number', minimum: 0, maximum: 1 },
                      },
                    },
                  },
                },
              },
            },
          },
        },
        responses: {
          201: { description: 'Events inserted' },
          400: { description: 'Validation error' },
          401: { description: 'Unauthenticated' },
        },
      },
    },

    // ── Offline ───────────────────────────────────────────────────────────────
    '/offline/packages': {
      get: {
        summary: 'List available offline map packages',
        tags: ['Offline'],
        responses: {
          200: {
            description: 'List of packages',
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  properties: { packages: { type: 'array', items: { $ref: '#/components/schemas/OfflinePackage' } } },
                },
              },
            },
          },
        },
      },
    },
    '/offline/packages/{city}': {
      get: {
        summary: 'Download offline map package for a city',
        tags: ['Offline'],
        parameters: [
          { name: 'city', in: 'path', required: true, schema: { type: 'string' } },
        ],
        responses: {
          200: { description: 'MBTiles file download' },
          404: { description: 'Package not found' },
        },
      },
    },

    // ── POIs ──────────────────────────────────────────────────────────────────
    '/pois': {
      get: {
        summary: 'Get points of interest in a bounding box',
        tags: ['POIs'],
        parameters: [
          { name: 'minLat', in: 'query', required: true, schema: { type: 'number' } },
          { name: 'minLon', in: 'query', required: true, schema: { type: 'number' } },
          { name: 'maxLat', in: 'query', required: true, schema: { type: 'number' } },
          { name: 'maxLon', in: 'query', required: true, schema: { type: 'number' } },
          { name: 'category', in: 'query', schema: { type: 'string' } },
          { name: 'limit', in: 'query', schema: { type: 'integer', default: 50, minimum: 1, maximum: 200 } },
        ],
        responses: {
          200: {
            description: 'List of POIs',
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  properties: { pois: { type: 'array', items: { $ref: '#/components/schemas/POI' } } },
                },
              },
            },
          },
          400: { description: 'Validation error' },
        },
      },
    },
    '/pois/{id}': {
      get: {
        summary: 'Get a single POI by ID',
        tags: ['POIs'],
        parameters: [
          { name: 'id', in: 'path', required: true, schema: { type: 'string', format: 'uuid' } },
        ],
        responses: {
          200: { description: 'POI details', content: { 'application/json': { schema: { $ref: '#/components/schemas/POI' } } } },
          404: { description: 'POI not found' },
        },
      },
    },

    // ── Reports ───────────────────────────────────────────────────────────────
    '/reports': {
      get: {
        summary: 'Get crowd-sourced reports in a bounding box',
        tags: ['Reports'],
        parameters: [
          { name: 'minLat', in: 'query', required: true, schema: { type: 'number' } },
          { name: 'minLon', in: 'query', required: true, schema: { type: 'number' } },
          { name: 'maxLat', in: 'query', required: true, schema: { type: 'number' } },
          { name: 'maxLon', in: 'query', required: true, schema: { type: 'number' } },
          { name: 'type', in: 'query', schema: { type: 'string', enum: ['accident', 'police', 'flood', 'road_closed', 'protest'] } },
        ],
        responses: {
          200: {
            description: 'List of reports',
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  properties: { reports: { type: 'array', items: { $ref: '#/components/schemas/Report' } } },
                },
              },
            },
          },
          400: { description: 'Validation error' },
        },
      },
      post: {
        summary: 'Submit a crowd-sourced incident report',
        tags: ['Reports'],
        security: [{ bearerAuth: [] }],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                properties: {
                  lat: { type: 'number' },
                  lon: { type: 'number' },
                  report_type: { type: 'string', enum: ['accident', 'police', 'flood', 'road_closed', 'protest'] },
                  description: { type: 'string' },
                  severity: { type: 'string', enum: ['minor', 'moderate', 'severe'], default: 'moderate' },
                },
                required: ['lat', 'lon', 'report_type'],
              },
            },
          },
        },
        responses: {
          201: { description: 'Report created' },
          400: { description: 'Validation error' },
          401: { description: 'Unauthenticated' },
        },
      },
    },
  },
};

module.exports = openApiSpec;
