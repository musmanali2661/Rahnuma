import React from 'react';

/**
 * LaneGuidance — displays lane arrows for the current maneuver.
 * Phase 1 placeholder; detailed lane data requires OSRM extra data.
 */
export default function LaneGuidance({ lanes = [] }) {
  if (!lanes.length) return null;

  return (
    <div className="flex gap-1">
      {lanes.map((lane, i) => (
        <div
          key={i}
          className={`w-6 h-8 rounded border flex items-end justify-center pb-1 text-xs ${
            lane.valid ? 'border-blue-500 text-blue-700 bg-blue-50' : 'border-gray-300 text-gray-400'
          }`}
        >
          {lane.indications?.includes('straight') ? '↑' : lane.indications?.includes('right') ? '→' : '←'}
        </div>
      ))}
    </div>
  );
}
