import { create } from 'zustand';
import { calculateRoute as apiCalculateRoute } from '../services/api.js';

const useRouteStore = create((set, get) => ({
  route: null,
  destination: null,
  loading: false,
  error: null,

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
      set({ route: bestRoute, loading: false });
    } catch (err) {
      set({ error: err.message, loading: false });
    }
  },

  clearRoute: () => set({ route: null, destination: null }),
}));

export default useRouteStore;
