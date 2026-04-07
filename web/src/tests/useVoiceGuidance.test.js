import { describe, it, expect, vi, beforeEach } from 'vitest';
import { renderHook, act } from '@testing-library/react';
import { useVoiceGuidance } from '../hooks/useVoiceGuidance.js';

// ── Mock the mapStore so we can control the language ─────────────────────────
vi.mock('../store/mapStore.js', () => ({
  default: vi.fn(() => ({ language: 'en' })),
}));

// ── Mock the Web Speech Synthesis API ─────────────────────────────────────────
const mockSpeak = vi.fn();
const mockCancel = vi.fn();

// SpeechSynthesisUtterance must be available as a constructor
class MockSpeechSynthesisUtterance {
  constructor(text) {
    this.text = text;
    this.lang = '';
    this.rate = 1;
    this.volume = 1;
  }
}

Object.defineProperty(global, 'SpeechSynthesisUtterance', {
  value: MockSpeechSynthesisUtterance,
  writable: true,
});

Object.defineProperty(global, 'speechSynthesis', {
  value: { speak: mockSpeak, cancel: mockCancel },
  writable: true,
});

describe('useVoiceGuidance', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('returns isSpeechSupported = true when speechSynthesis is available', () => {
    const { result } = renderHook(() => useVoiceGuidance());
    expect(result.current.isSpeechSupported).toBe(true);
  });

  it('announce() calls speechSynthesis.speak with the given text', () => {
    const { result } = renderHook(() => useVoiceGuidance());
    act(() => result.current.announce('Turn right'));
    expect(mockSpeak).toHaveBeenCalledOnce();
    const utterance = mockSpeak.mock.calls[0][0];
    expect(utterance.text).toBe('Turn right');
  });

  it('announce() cancels any ongoing speech before speaking', () => {
    const { result } = renderHook(() => useVoiceGuidance());
    act(() => result.current.announce('Hello'));
    expect(mockCancel).toHaveBeenCalled();
  });

  it('announceStep() speaks the correct English instruction for "turn right"', () => {
    const { result } = renderHook(() => useVoiceGuidance());
    const step = { maneuver: { type: 'turn right' }, name: 'Main Street', distance: 100 };
    act(() => result.current.announceStep(step, true));
    expect(mockSpeak).toHaveBeenCalledOnce();
    const utterance = mockSpeak.mock.calls[0][0];
    expect(utterance.text).toContain('Turn right');
    expect(utterance.text).toContain('Main Street');
  });

  it('announceStep() does not repeat the same step twice without force=true', () => {
    const { result } = renderHook(() => useVoiceGuidance());
    const step = { maneuver: { type: 'turn left' }, name: 'Test Rd', distance: 50 };
    act(() => result.current.announceStep(step));
    act(() => result.current.announceStep(step));
    // Should only have been called once (second call deduped)
    expect(mockSpeak).toHaveBeenCalledOnce();
  });

  it('announceStep() announces again with force=true even if same step', () => {
    const { result } = renderHook(() => useVoiceGuidance());
    const step = { maneuver: { type: 'straight' }, name: '', distance: 200 };
    act(() => result.current.announceStep(step, true));
    act(() => result.current.announceStep(step, true));
    expect(mockSpeak).toHaveBeenCalledTimes(2);
  });

  it('announceStep() sets language to en-US in English mode', () => {
    const { result } = renderHook(() => useVoiceGuidance());
    const step = { maneuver: { type: 'arrive' }, name: '', distance: 0 };
    act(() => result.current.announceStep(step, true));
    const utterance = mockSpeak.mock.calls[0][0];
    expect(utterance.lang).toBe('en-US');
  });

  it('ANNOUNCE_DISTANCE_M is 200', () => {
    const { result } = renderHook(() => useVoiceGuidance());
    expect(result.current.ANNOUNCE_DISTANCE_M).toBe(200);
  });
});
