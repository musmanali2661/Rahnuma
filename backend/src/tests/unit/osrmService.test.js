'use strict';

jest.mock('axios');

const axios = require('axios');
const osrmService = require('../../services/osrmService');

// Helper to build a minimal OSRM route response
function makeOsrmRoute({ distance = 50000, duration = 1800 } = {}) {
  return {
    distance,
    duration,
    geometry: '_p~iF~ps|U_ulLnnqC',  // valid polyline6 data
    legs: [
      {
        distance,
        duration,
        summary: 'Test Road',
        steps: [
          {
            distance: 100,
            duration: 10,
            name: 'Test St',
            mode: 'driving',
            maneuver: { type: 'depart' },
            geometry: '_p~iF~ps|U',
          },
        ],
      },
    ],
  };
}

describe('osrmService.getRoute', () => {
  beforeEach(() => jest.clearAllMocks());

  const waypoints = [
    { lat: 31.5, lon: 74.3 },
    { lat: 33.7, lon: 73.0 },
  ];

  it('returns a route with distance, duration, and LineString geometry', async () => {
    axios.get.mockResolvedValue({
      data: {
        code: 'Ok',
        routes: [makeOsrmRoute()],
        waypoints: [],
      },
    });

    const result = await osrmService.getRoute(waypoints);
    expect(result.routes).toHaveLength(1);
    const route = result.routes[0];
    expect(typeof route.distance).toBe('number');
    expect(typeof route.duration).toBe('number');
    expect(route.geometry.type).toBe('LineString');
    expect(typeof route.toll_estimate_pkr).toBe('number');
  });

  it('returns multiple routes when alternatives: true', async () => {
    axios.get.mockResolvedValue({
      data: {
        code: 'Ok',
        routes: [makeOsrmRoute(), makeOsrmRoute({ distance: 60000, duration: 2100 })],
        waypoints: [],
      },
    });

    const result = await osrmService.getRoute(waypoints, { alternatives: true });
    expect(result.routes).toHaveLength(2);
  });

  it('throws error with status 422 when OSRM returns NoRoute', async () => {
    axios.get.mockResolvedValue({
      data: {
        code: 'NoRoute',
        message: 'No route found',
      },
    });

    await expect(osrmService.getRoute(waypoints)).rejects.toMatchObject({ status: 422 });
  });

  it('throws error with status 503 on ECONNREFUSED', async () => {
    const connError = new Error('connect ECONNREFUSED');
    connError.code = 'ECONNREFUSED';
    axios.get.mockRejectedValue(connError);

    await expect(osrmService.getRoute(waypoints)).rejects.toMatchObject({ status: 503 });
  });

  it('throws error with status 503 on ECONNABORTED', async () => {
    const timeoutError = new Error('timeout');
    timeoutError.code = 'ECONNABORTED';
    axios.get.mockRejectedValue(timeoutError);

    await expect(osrmService.getRoute(waypoints)).rejects.toMatchObject({ status: 503 });
  });
});

describe('osrmService.snapToRoad', () => {
  beforeEach(() => jest.clearAllMocks());

  it('returns location, name, and distance from nearest endpoint', async () => {
    axios.get.mockResolvedValue({
      data: {
        code: 'Ok',
        waypoints: [
          {
            location: [74.3, 31.5],
            name: 'Ferozepur Road',
            distance: 12.5,
          },
        ],
      },
    });

    const result = await osrmService.snapToRoad(31.5, 74.3);
    expect(result).toHaveProperty('location');
    expect(result).toHaveProperty('name', 'Ferozepur Road');
    expect(result).toHaveProperty('distance', 12.5);
  });
});

describe('toll estimation', () => {
  beforeEach(() => jest.clearAllMocks());

  it('returns toll > 0 for route with distance > 50km', async () => {
    axios.get.mockResolvedValue({
      data: {
        code: 'Ok',
        routes: [makeOsrmRoute({ distance: 100000 })],  // 100 km
        waypoints: [],
      },
    });

    const result = await osrmService.getRoute([{ lat: 31.5, lon: 74.3 }, { lat: 33.7, lon: 73.0 }]);
    expect(result.routes[0].toll_estimate_pkr).toBeGreaterThan(0);
  });

  it('returns 0 toll for short route < 50km', async () => {
    axios.get.mockResolvedValue({
      data: {
        code: 'Ok',
        routes: [makeOsrmRoute({ distance: 40000 })],  // 40 km
        waypoints: [],
      },
    });

    const result = await osrmService.getRoute([{ lat: 31.5, lon: 74.3 }, { lat: 31.8, lon: 74.0 }]);
    expect(result.routes[0].toll_estimate_pkr).toBe(0);
  });
});
