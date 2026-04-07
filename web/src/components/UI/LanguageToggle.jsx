import React from 'react';
import useMapStore from '../../store/mapStore.js';

export default function LanguageToggle() {
  const { language, setLanguage } = useMapStore();

  return (
    <button
      onClick={() => setLanguage(language === 'ur' ? 'en' : 'ur')}
      className="px-3 py-1 bg-white rounded-full shadow text-sm font-medium hover:bg-gray-50 transition"
      title="Toggle language"
    >
      {language === 'ur' ? 'English' : 'اردو'}
    </button>
  );
}
