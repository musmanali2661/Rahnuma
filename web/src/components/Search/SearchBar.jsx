import React, { useState, useCallback, useRef } from 'react';
import { searchPlaces } from '../../services/api.js';
import SearchResults from './SearchResults.jsx';
import useRouteStore from '../../store/routeStore.js';
import useMapStore from '../../store/mapStore.js';
import maplibregl from 'maplibre-gl';

const RECENT_KEY = 'rahnuma_recent_searches';
const DEBOUNCE_MS = 350;

function getRecent() {
  try {
    return JSON.parse(localStorage.getItem(RECENT_KEY) || '[]');
  } catch {
    return [];
  }
}

function addRecent(item) {
  const existing = getRecent().filter((r) => r.place_id !== item.place_id);
  const updated = [item, ...existing].slice(0, 5);
  localStorage.setItem(RECENT_KEY, JSON.stringify(updated));
}

// Time to wait (ms) before closing the dropdown on blur.
// This allows click events on dropdown items to fire before the dropdown disappears.
const BLUR_DELAY_MS = 150;

export default function SearchBar({ map }) {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState([]);
  const [loading, setLoading] = useState(false);
  const [focused, setFocused] = useState(false);
  const debounceTimer = useRef(null);

  const { userLocation } = useMapStore();
  const { setDestination, calculateRoute } = useRouteStore();

  const handleChange = useCallback(
    (e) => {
      const val = e.target.value;
      setQuery(val);
      clearTimeout(debounceTimer.current);

      if (!val.trim()) {
        setResults(getRecent());
        return;
      }

      debounceTimer.current = setTimeout(async () => {
        setLoading(true);
        try {
          const data = await searchPlaces(val, {
            lat: userLocation?.lat,
            lon: userLocation?.lon,
          });
          setResults(data);
        } catch (err) {
          console.error('Search error', err);
        } finally {
          setLoading(false);
        }
      }, DEBOUNCE_MS);
    },
    [userLocation]
  );

  const handleSelect = useCallback(
    async (place) => {
      setQuery(place.name);
      setResults([]);
      setFocused(false);
      addRecent(place);

      // Fly to the selected place
      const m = map?.current;
      if (m) {
        m.flyTo({ center: [place.lon, place.lat], zoom: 15, speed: 1.8 });
        new maplibregl.Marker({ color: '#F44336' })
          .setLngLat([place.lon, place.lat])
          .setPopup(new maplibregl.Popup().setText(place.name))
          .addTo(m);
      }

      // Set as destination and calculate route if we have a user location
      setDestination({ lat: place.lat, lon: place.lon, name: place.name });
      if (userLocation) {
        await calculateRoute(userLocation, { lat: place.lat, lon: place.lon });
      }
    },
    [map, userLocation, setDestination, calculateRoute]
  );

  const showDropdown = focused && (results.length > 0 || query.trim() === '');

  return (
    <div className="relative">
      <div className="flex items-center bg-white rounded-xl shadow-lg px-3 py-2 gap-2">
        <svg xmlns="http://www.w3.org/2000/svg" className="w-5 h-5 text-gray-400 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2}>
          <circle cx="11" cy="11" r="8" /><line x1="21" y1="21" x2="16.65" y2="16.65" />
        </svg>
        <input
          type="text"
          value={query}
          onChange={handleChange}
          onFocus={() => { setFocused(true); if (!query.trim()) setResults(getRecent()); }}
      onBlur={() => setTimeout(() => setFocused(false), BLUR_DELAY_MS)}
          placeholder="Search... | تلاش کریں"
          className="flex-1 outline-none text-sm bg-transparent placeholder-gray-400"
          dir="auto"
        />
        {loading && (
          <svg className="w-4 h-4 text-blue-500 animate-spin" viewBox="0 0 24 24" fill="none">
            <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth={4} />
            <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8H4z" />
          </svg>
        )}
        {query && (
          <button onClick={() => { setQuery(''); setResults([]); }} className="text-gray-400 hover:text-gray-600">
            ×
          </button>
        )}
      </div>

      {showDropdown && (
        <SearchResults results={results} onSelect={handleSelect} empty={!query.trim()} />
      )}
    </div>
  );
}
