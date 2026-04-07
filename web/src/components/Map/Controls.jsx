import React from 'react';

/**
 * Map controls — locate me button.
 */
export default function Controls({ mapRef }) {
  const handleLocate = () => {
    const map = mapRef?.current;
    if (!map || !navigator.geolocation) return;
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        map.flyTo({
          center: [pos.coords.longitude, pos.coords.latitude],
          zoom: 15,
          speed: 1.5,
        });
      },
      (err) => console.warn('Locate error', err),
      { enableHighAccuracy: true }
    );
  };

  return (
    <div className="absolute bottom-24 right-4 z-10 flex flex-col gap-2">
      <button
        onClick={handleLocate}
        title="Locate me"
        className="w-10 h-10 rounded-full bg-white shadow-md flex items-center justify-center text-blue-700 hover:bg-blue-50 transition"
      >
        <svg xmlns="http://www.w3.org/2000/svg" className="w-5 h-5" viewBox="0 0 24 24" fill="currentColor">
          <path d="M12 8a4 4 0 100 8 4 4 0 000-8zm-8.94 3A9.005 9.005 0 013 12a9 9 0 0016.94 1H22v-2h-2.06A9.005 9.005 0 003 11H1v2h2.06z" />
        </svg>
      </button>
    </div>
  );
}
