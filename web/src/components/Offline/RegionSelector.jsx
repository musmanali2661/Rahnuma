import React from 'react';
import maplibregl from 'maplibre-gl';

const CITIES = [
  { id: 'karachi', name: 'Karachi', center: [67.0099, 24.8607], zoom: 11 },
  { id: 'lahore', name: 'Lahore', center: [74.3436, 31.5497], zoom: 11 },
  { id: 'islamabad', name: 'Islamabad', center: [73.0479, 33.7215], zoom: 12 },
  { id: 'peshawar', name: 'Peshawar', center: [71.5249, 34.0151], zoom: 12 },
  { id: 'quetta', name: 'Quetta', center: [66.9750, 30.1798], zoom: 12 },
  { id: 'multan', name: 'Multan', center: [71.4753, 30.1575], zoom: 12 },
  { id: 'faisalabad', name: 'Faisalabad', center: [73.0654, 31.4177], zoom: 12 },
  { id: 'rawalpindi', name: 'Rawalpindi', center: [73.0479, 33.5651], zoom: 12 },
];

export default function RegionSelector({ map, onSelect }) {
  const flyTo = (city) => {
    const m = map?.current;
    if (m) m.flyTo({ center: city.center, zoom: city.zoom, speed: 1.5 });
    onSelect?.(city);
  };

  return (
    <div className="grid grid-cols-2 gap-2">
      {CITIES.map((city) => (
        <button
          key={city.id}
          onClick={() => flyTo(city)}
          className="px-3 py-2 bg-white rounded-lg shadow text-sm font-medium hover:bg-blue-50 transition text-left"
        >
          {city.name}
        </button>
      ))}
    </div>
  );
}
