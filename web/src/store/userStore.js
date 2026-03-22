import { create } from 'zustand';

const useUserStore = create((set) => ({
  user: null,
  token: null,
  setUser: (user) => set({ user }),
  setToken: (token) => {
    set({ token });
    if (token) localStorage.setItem('rahnuma_token', token);
    else localStorage.removeItem('rahnuma_token');
  },
  logout: () => {
    localStorage.removeItem('rahnuma_token');
    set({ user: null, token: null });
  },
}));

export default useUserStore;
