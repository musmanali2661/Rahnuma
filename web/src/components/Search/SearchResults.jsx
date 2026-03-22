import React from 'react';

export default function SearchResults({ results, onSelect, empty }) {
  if (!results.length && !empty) return null;

  return (
    <div className="absolute top-full left-0 right-0 mt-1 bg-white rounded-xl shadow-xl overflow-hidden z-20 max-h-64 overflow-y-auto">
      {results.length === 0 && empty && (
        <p className="text-sm text-gray-400 p-3">No recent searches</p>
      )}
      {results.map((r, i) => (
        <button
          key={r.place_id || i}
          onClick={() => onSelect(r)}
          className="w-full text-left px-4 py-2 hover:bg-gray-50 border-b last:border-b-0 border-gray-100"
        >
          <p className="text-sm font-medium text-gray-800 truncate">{r.name}</p>
          {r.address?.city && (
            <p className="text-xs text-gray-500 truncate">{r.address.city}</p>
          )}
        </button>
      ))}
    </div>
  );
}
