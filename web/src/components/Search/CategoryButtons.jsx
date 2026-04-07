import React from 'react';
import { searchPlaces } from '../../services/api.js';
import useMapStore from '../../store/mapStore.js';

const CATEGORIES = [
  { id: 'petrol', label: 'Petrol', icon: '⛽', urdu: 'پٹرول' },
  { id: 'food', label: 'Food', icon: '🍴', urdu: 'کھانا' },
  { id: 'mosque', label: 'Mosque', icon: '🕌', urdu: 'مسجد' },
  { id: 'hospital', label: 'Hospital', icon: '🏥', urdu: 'ہسپتال' },
];

export default function CategoryButtons({ onResults }) {
  const { userLocation } = useMapStore();

  const handleCategory = async (categoryId) => {
    try {
      const results = await searchPlaces(categoryId, {
        lat: userLocation?.lat,
        lon: userLocation?.lon,
        category: categoryId,
      });
      onResults?.(results, categoryId);
    } catch (err) {
      console.error('Category search error', err);
    }
  };

  return (
    <div className="flex gap-2 mt-2">
      {CATEGORIES.map((cat) => (
        <button
          key={cat.id}
          onClick={() => handleCategory(cat.id)}
          className="flex items-center gap-1 bg-white rounded-lg shadow px-3 py-1.5 text-xs font-medium hover:bg-green-50 transition"
        >
          <span>{cat.icon}</span>
          <span className="hidden sm:inline">{cat.label}</span>
        </button>
      ))}
    </div>
  );
}
