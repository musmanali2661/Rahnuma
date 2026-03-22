import React from 'react';

/**
 * RouteLayer — renders the active route as a GeoJSON line on the map.
 * This component is a pure data layer; the map instance is passed as a prop.
 */
export default function RouteLayer({ map, route }) {
  // Rendering handled imperatively in MapView to avoid re-mounting issues.
  // This component exists as a future wrapper for more complex route styling.
  return null;
}
