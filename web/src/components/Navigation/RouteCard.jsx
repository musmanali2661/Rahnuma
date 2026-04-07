import React from 'react';
import { formatDistance, formatDuration } from '../../utils/formatters.js';
import { useVoiceGuidance } from '../../hooks/useVoiceGuidance.js';
import useRouteStore from '../../store/routeStore.js';

export default function RouteCard({ route, onClear }) {
  if (!route) return null;

  const { distance, duration, legs, toll_estimate_pkr } = route;
  const { currentStepIndex, isNavigating, startNavigation } = useRouteStore();
  const { announceStep, isSpeechSupported } = useVoiceGuidance();

  const steps = legs?.[0]?.steps || [];
  const currentStep = steps[currentStepIndex] || null;

  const handleStartNavigation = () => {
    startNavigation();
    if (steps[0]) announceStep(steps[0], true);
  };

  const handleRepeat = () => {
    if (currentStep) announceStep(currentStep, true);
  };

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
        <div className="flex gap-2 items-center">
          {isSpeechSupported && (
            <>
              {!isNavigating ? (
                <button
                  onClick={handleStartNavigation}
                  title="Start voice navigation"
                  className="w-9 h-9 rounded-full bg-green-600 text-white flex items-center justify-center hover:bg-green-700 transition"
                >
                  {/* Play icon */}
                  <svg xmlns="http://www.w3.org/2000/svg" className="w-4 h-4" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M8 5v14l11-7z" />
                  </svg>
                </button>
              ) : (
                <button
                  onClick={handleRepeat}
                  title="Repeat instruction"
                  className="w-9 h-9 rounded-full bg-blue-600 text-white flex items-center justify-center hover:bg-blue-700 transition"
                >
                  {/* Volume icon */}
                  <svg xmlns="http://www.w3.org/2000/svg" className="w-4 h-4" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M3 9v6h4l5 5V4L7 9H3zm13.5 3c0-1.77-1.02-3.29-2.5-4.03v8.05c1.48-.73 2.5-2.25 2.5-4.02z" />
                  </svg>
                </button>
              )}
            </>
          )}
          {onClear && (
            <button onClick={onClear} className="text-gray-400 hover:text-red-500 text-xl font-bold px-2">×</button>
          )}
        </div>
      </div>

      {/* Current step (while navigating) */}
      {isNavigating && currentStep && (
        <div className="bg-blue-50 rounded-lg p-2 mb-2 flex items-center gap-2 text-sm text-blue-800">
          <span className="text-lg">
            {currentStep.maneuver?.type === 'turn right'
              ? '➡️'
              : currentStep.maneuver?.type === 'turn left'
              ? '⬅️'
              : currentStep.maneuver?.type === 'arrive'
              ? '🏁'
              : '⬆️'}
          </span>
          <span className="font-medium truncate">
            {currentStep.name || currentStep.maneuver?.type || 'Continue'}
          </span>
          <span className="ml-auto shrink-0 text-blue-600">{formatDistance(currentStep.distance)}</span>
        </div>
      )}

      {/* Turn list */}
      <div className="max-h-32 overflow-y-auto divide-y divide-gray-100">
        {steps.slice(0, 8).map((step, i) => (
          <div
            key={i}
            className={`py-1 flex items-center gap-2 text-xs ${
              isNavigating && i === currentStepIndex
                ? 'text-blue-700 font-semibold'
                : 'text-gray-700'
            }`}
          >
            <span className="font-mono text-gray-400 w-12 shrink-0">{formatDistance(step.distance)}</span>
            <span className="truncate">{step.maneuver?.type} {step.name}</span>
          </div>
        ))}
      </div>
    </div>
  );
}
