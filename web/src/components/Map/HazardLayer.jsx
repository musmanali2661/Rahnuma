import React, { useEffect } from 'react';

/**
 * HazardLayer — adds pothole/speed-bump markers to the map.
 */
export default function HazardLayer({ map, events = [] }) {
  useEffect(() => {
    const m = map?.current;
    if (!m || !m.isStyleLoaded()) return;

    const geojson = {
      type: 'FeatureCollection',
      features: events.map((ev) => ({
        type: 'Feature',
        geometry: { type: 'Point', coordinates: [ev.lon, ev.lat] },
        properties: { event_type: ev.event_type, confidence: ev.confidence },
      })),
    };

    if (m.getSource('hazards')) {
      m.getSource('hazards').setData(geojson);
    } else {
      m.addSource('hazards', { type: 'geojson', data: geojson });
      m.addLayer({
        id: 'hazards-circle',
        type: 'circle',
        source: 'hazards',
        paint: {
          'circle-radius': 8,
          'circle-color': [
            'match',
            ['get', 'event_type'],
            'pothole', '#F44336',
            'speed_bump', '#FF9800',
            'rough_road', '#9C27B0',
            '#757575',
          ],
          'circle-opacity': 0.85,
          'circle-stroke-width': 2,
          'circle-stroke-color': '#fff',
        },
      });
    }
  }, [map, events]);

  return null;
}
