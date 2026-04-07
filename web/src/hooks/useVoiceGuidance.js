import { useCallback, useRef } from 'react';
import useMapStore from '../store/mapStore.js';

/**
 * Urdu turn instructions (Nastaliq script).
 * Used when the app language is set to 'ur'.
 */
const URDU_INSTRUCTIONS = {
  'turn right': 'دائیں مڑیں',
  'turn left': 'بائیں مڑیں',
  'slight right': 'تھوڑا دائیں مڑیں',
  'slight left': 'تھوڑا بائیں مڑیں',
  'straight': 'سیدھے چلتے رہیں',
  'u-turn': 'یو ٹرن لیں',
  'arrive': 'آپ منزل پر پہنچ گئے',
  'depart': 'سفر شروع کریں',
  'roundabout': 'گول چکر میں داخل ہوں',
  'exit roundabout': 'گول چکر سے نکلیں',
  'merge': 'آگے ملیں',
  'fork': 'سامنے دوراہا ہے',
  'end of road': 'سڑک ختم ہو رہی ہے',
};

/**
 * English turn instructions (fallback when language is 'en').
 */
const ENGLISH_INSTRUCTIONS = {
  'turn right': 'Turn right',
  'turn left': 'Turn left',
  'slight right': 'Keep slight right',
  'slight left': 'Keep slight left',
  'straight': 'Continue straight',
  'u-turn': 'Make a U-turn',
  'arrive': 'You have arrived at your destination',
  'depart': 'Start your journey',
  'roundabout': 'Enter the roundabout',
  'exit roundabout': 'Exit the roundabout',
  'merge': 'Merge ahead',
  'fork': 'Keep to the road ahead',
  'end of road': 'End of road ahead',
};

/**
 * Distance thresholds for announcing a turn (in metres).
 * Announce when within this distance of the turn.
 */
const ANNOUNCE_DISTANCE_M = 200;

/**
 * Hook providing Urdu/English voice guidance via the Web Speech Synthesis API.
 *
 * @returns {{ announce, announceStep, isSpeechSupported }}
 */
export function useVoiceGuidance() {
  const { language } = useMapStore();
  const lastAnnouncedKeyRef = useRef(null);

  const isSpeechSupported = typeof window !== 'undefined' && 'speechSynthesis' in window;

  /**
   * Speak a raw text string immediately.
   * @param {string} text
   * @param {string} [langCode]  BCP-47 language tag, e.g. 'ur-PK' or 'en-US'
   */
  const announce = useCallback(
    (text, langCode) => {
      if (!isSpeechSupported || !text) return;
      const utterance = new SpeechSynthesisUtterance(text);
      utterance.lang = langCode || (language === 'ur' ? 'ur-PK' : 'en-US');
      utterance.rate = 0.9;
      utterance.volume = 1.0;
      window.speechSynthesis.cancel();
      window.speechSynthesis.speak(utterance);
    },
    [isSpeechSupported, language]
  );

  /**
   * Announce the instruction for a route step.
   * Deduplicates so the same turn is not announced twice in a row.
   *
   * @param {object} step  OSRM step object with maneuver and name fields
   * @param {boolean} [force]  If true, announce even if it was the last step announced
   */
  const announceStep = useCallback(
    (step, force = false) => {
      if (!step || !isSpeechSupported) return;
      const maneuverType = step.maneuver?.type;
      if (!maneuverType) return;

      const key = `${maneuverType}:${step.name || ''}`;
      if (!force && key === lastAnnouncedKeyRef.current) return;
      lastAnnouncedKeyRef.current = key;

      const instructionMap = language === 'ur' ? URDU_INSTRUCTIONS : ENGLISH_INSTRUCTIONS;
      const instruction = instructionMap[maneuverType] || instructionMap['straight'];
      const streetName = step.name ? ` ${step.name}` : '';
      const text = `${instruction}${streetName}`;

      announce(text, language === 'ur' ? 'ur-PK' : 'en-US');
    },
    [announce, isSpeechSupported, language]
  );

  return { announce, announceStep, isSpeechSupported, ANNOUNCE_DISTANCE_M };
}
