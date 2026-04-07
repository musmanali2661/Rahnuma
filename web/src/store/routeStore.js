import { create } from 'zustand';
import { calculateRoute as apiCalculateRoute } from '../services/api.js';

const useRouteStore = create((set, get) => ({
  route: null,
  destination: null,
  loading: false,
  error: null,
  /** Index of the step currently being navigated in routes[0].legs[0].steps */
  currentStepIndex: 0,
  /** Whether active turn-by-turn navigation is in progress */
  isNavigating: false,

  setDestination: (dest) => set({ destination: dest }),

  calculateRoute: async (origin, destination) => {
    set({ loading: true, error: null });
    try {
      const data = await apiCalculateRoute(
        [
          { lat: origin.lat, lon: origin.lon },
          { lat: destination.lat, lon: destination.lon },
        ],
        { profile: 'car', alternatives: false }
      );
      const bestRoute = data.routes?.[0] || null;
      set({ route: bestRoute, loading: false, currentStepIndex: 0, isNavigating: false });
    } catch (err) {
      set({ error: err.message, loading: false });
    }
  },

  /** Start turn-by-turn navigation mode */
  startNavigation: () => set({ isNavigating: true, currentStepIndex: 0 }),

  /** Advance to the next step (called by location tracking or user tap) */
  advanceStep: () => {
    const { route, currentStepIndex } = get();
    const steps = route?.legs?.[0]?.steps || [];
    if (currentStepIndex < steps.length - 1) {
      set({ currentStepIndex: currentStepIndex + 1 });
    }
  },

  /** Update the current step based on the user's distance to step endpoints */
  updateStepFromLocation: (userLat, userLon) => {
    const { route, currentStepIndex, isNavigating } = get();
    if (!isNavigating || !route) return;

    const steps = route.legs?.[0]?.steps || [];
    if (!steps.length) return;

    // Find the first upcoming step the user has not yet passed
    for (let i = currentStepIndex; i < steps.length; i++) {
      const step = steps[i];
      const coords = step.geometry?.coordinates;
      if (!coords || !coords.length) continue;

      // Use the step's end coordinate to check if user has passed it
      const [endLon, endLat] = coords[coords.length - 1];
      const dist = haversine(userLat, userLon, endLat, endLon);

      if (dist > 30) {
        // User hasn't passed this step yet — keep it as current
        if (i !== currentStepIndex) set({ currentStepIndex: i });
        return;
      }
    }
  },

  clearRoute: () =>
    set({ route: null, destination: null, currentStepIndex: 0, isNavigating: false }),
}));

/** Simple inline Haversine for step tracking (in metres). */
function haversine(lat1, lon1, lat2, lon2) {
  const R = 6371000;
  const φ1 = (lat1 * Math.PI) / 180;
  const φ2 = (lat2 * Math.PI) / 180;
  const Δφ = ((lat2 - lat1) * Math.PI) / 180;
  const Δλ = ((lon2 - lon1) * Math.PI) / 180;
  const a = Math.sin(Δφ / 2) ** 2 + Math.cos(φ1) * Math.cos(φ2) * Math.sin(Δλ / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

export default useRouteStore;
