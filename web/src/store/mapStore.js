import { create } from 'zustand';

const useMapStore = create((set) => ({
  map: null,
  userLocation: null,
  language: 'ur',
  setMap: (map) => set({ map }),
  setUserLocation: (location) => set({ userLocation: location }),
  setLanguage: (language) => set({ language }),
}));

export default useMapStore;
