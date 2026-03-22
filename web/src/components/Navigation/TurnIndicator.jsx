import React from 'react';

const MANEUVER_ICONS = {
  'turn right': '➡️',
  'turn left': '⬅️',
  'slight right': '↗️',
  'slight left': '↖️',
  'straight': '⬆️',
  'u-turn': '↩️',
  'arrive': '🏁',
  'depart': '🚀',
};

export default function TurnIndicator({ step }) {
  if (!step) return null;
  const { maneuver, name, distance } = step;
  const icon = MANEUVER_ICONS[maneuver?.type] || '⬆️';

  return (
    <div className="flex items-center gap-3 bg-white rounded-xl shadow-lg p-3 max-w-sm">
      <span className="text-3xl">{icon}</span>
      <div>
        <p className="font-semibold text-gray-900">{name || 'Continue'}</p>
        <p className="text-sm text-gray-500">{Math.round(distance)} m</p>
      </div>
    </div>
  );
}
