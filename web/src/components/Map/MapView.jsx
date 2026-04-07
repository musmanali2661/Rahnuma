import React, { useEffect, useRef, useCallback } from 'react';
import maplibregl from 'maplibre-gl';
import { mapStyle } from '../../assets/styles/mapStyles.js';
import useMapStore from '../../store/mapStore.js';
import useRouteStore from '../../store/routeStore.js';
import { useVoiceGuidance } from '../../hooks/useVoiceGuidance.js';
import SearchBar from '../Search/SearchBar.jsx';
import RouteCard from '../Navigation/RouteCard.jsx';
import Controls from './Controls.jsx';

const PAKISTAN_CENTER = [69.3451, 30.3753];
const PAKISTAN_ZOOM = 5;

export default function MapView() {
  const mapContainer = useRef(null);
  const mapRef = useRef(null);

  const { setMap, userLocation, setUserLocation } = useMapStore();
  const { route, isNavigating, updateStepFromLocation, currentStepIndex, clearRoute } = useRouteStore();
  const { announceStep, ANNOUNCE_DISTANCE_M } = useVoiceGuidance();

  // Track the last announced step index to avoid re-announcing the same step
  const lastAnnouncedStepRef = useRef(-1);

  // Initialise the map
  useEffect(() => {
    if (mapRef.current || !mapContainer.current) return;

    const map = new maplibregl.Map({
      container: mapContainer.current,
      style: mapStyle,
      center: PAKISTAN_CENTER,
      zoom: PAKISTAN_ZOOM,
      attributionControl: false,
    });

    map.addControl(
      new maplibregl.AttributionControl({ compact: true }),
      'bottom-right'
    );

    map.on('load', () => {
      mapRef.current = map;
      setMap(map);
      startLocationTracking(map);
    });

    return () => {
      map.remove();
      mapRef.current = null;
    };
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  // Draw/update route on the map
  useEffect(() => {
    const map = mapRef.current;
    if (!map || !map.isStyleLoaded()) return;

    if (map.getSource('route')) {
      map.getSource('route').setData(
        route
          ? { type: 'FeatureCollection', features: [{ type: 'Feature', geometry: route.geometry, properties: {} }] }
          : { type: 'FeatureCollection', features: [] }
      );
    } else if (route) {
      map.addSource('route', {
        type: 'geojson',
        data: { type: 'FeatureCollection', features: [{ type: 'Feature', geometry: route.geometry, properties: {} }] },
      });
      map.addLayer({
        id: 'route-line',
        type: 'line',
        source: 'route',
        layout: { 'line-join': 'round', 'line-cap': 'round' },
        paint: { 'line-color': '#1976D2', 'line-width': 5, 'line-opacity': 0.9 },
      });
      map.addLayer({
        id: 'route-line-outline',
        type: 'line',
        source: 'route',
        layout: { 'line-join': 'round', 'line-cap': 'round' },
        paint: { 'line-color': '#0D47A1', 'line-width': 8, 'line-opacity': 0.3 },
      }, 'route-line');
    }
  }, [route]);

  // Voice guidance: announce the current step when it changes during navigation
  useEffect(() => {
    if (!isNavigating || !route) return;
    if (currentStepIndex === lastAnnouncedStepRef.current) return;

    const steps = route.legs?.[0]?.steps || [];
    const step = steps[currentStepIndex];
    if (step) {
      lastAnnouncedStepRef.current = currentStepIndex;
      announceStep(step, true);
    }
  }, [isNavigating, currentStepIndex, route, announceStep]);

  // Reset last-announced ref when navigation stops
  useEffect(() => {
    if (!isNavigating) {
      lastAnnouncedStepRef.current = -1;
    }
  }, [isNavigating]);

  const startLocationTracking = useCallback((map) => {
    if (!navigator.geolocation) return;

    const marker = new maplibregl.Marker({ color: '#1976D2' });

    const watchId = navigator.geolocation.watchPosition(
      (pos) => {
        const { latitude: lat, longitude: lon } = pos.coords;
        setUserLocation({ lat, lon });
        marker.setLngLat([lon, lat]).addTo(map);

        // Update current navigation step based on position
        updateStepFromLocation(lat, lon);
      },
      (err) => console.warn('Geolocation error:', err),
      { enableHighAccuracy: true, maximumAge: 5000 }
    );

    return () => navigator.geolocation.clearWatch(watchId);
  }, [setUserLocation, updateStepFromLocation]);

  return (
    <div className="relative w-full h-full">
      {/* Map container */}
      <div ref={mapContainer} className="map-container" />

      {/* Search bar overlay */}
      <div className="absolute top-4 left-4 right-4 z-10 max-w-lg mx-auto">
        <SearchBar map={mapRef} />
      </div>

      {/* Map controls */}
      <Controls mapRef={mapRef} />

      {/* Route card */}
      {route && (
        <div className="absolute bottom-4 left-4 right-4 z-10 max-w-lg mx-auto">
          <RouteCard route={route} onClear={clearRoute} />
        </div>
      )}
    </div>
  );
}
