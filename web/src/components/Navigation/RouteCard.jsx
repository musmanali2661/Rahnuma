import React from 'react';
import { formatDistance, formatDuration } from '../../utils/formatters.js';

export default function RouteCard({ route, onClear }) {
  if (!route) return null;

  const { distance, duration, legs, toll_estimate_pkr } = route;

  return (
    <div className="bg-white rounded-xl shadow-xl p-4">
      {/* Summary row */}
      <div className="flex items-center justify-between mb-3">
        <div className="flex gap-4">
          <div>
            <p className="text-2xl font-bold text-gray-900">{formatDuration(duration)}</p>
            <p className="text-sm text-gray-500">{formatDistance(distance)}</p>
          </div>
          {toll_estimate_pkr > 0 && (
            <div className="text-sm text-orange-600">
              <p className="font-semibold">Toll ~PKR {toll_estimate_pkr}</p>
            </div>
          )}
        </div>
        {onClear && (
          <button onClick={onClear} className="text-gray-400 hover:text-red-500 text-xl font-bold px-2">×</button>
        )}
      </div>

      {/* Turn list */}
      <div className="max-h-32 overflow-y-auto divide-y divide-gray-100">
        {legs[0]?.steps?.slice(0, 8).map((step, i) => (
          <div key={i} className="py-1 flex items-center gap-2 text-xs text-gray-700">
            <span className="font-mono text-gray-400 w-12 shrink-0">{formatDistance(step.distance)}</span>
            <span className="truncate">{step.maneuver?.type} {step.name}</span>
          </div>
        ))}
      </div>
    </div>
  );
}
