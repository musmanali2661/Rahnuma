/**
 * Roman Urdu to Urdu script transliteration utilities for the web frontend.
 * Mirrors the backend nominatimService.js map.
 */

const ROMAN_URDU_MAP = {
  lahore: 'لاہور',
  karachi: 'کراچی',
  islamabad: 'اسلام آباد',
  rawalpindi: 'راولپنڈی',
  peshawar: 'پشاور',
  quetta: 'کوئٹہ',
  multan: 'ملتان',
  faisalabad: 'فیصل آباد',
  sialkot: 'سیالکوٹ',
  gujranwala: 'گوجرانوالہ',
  hyderabad: 'حیدرآباد',
  masjid: 'مسجد',
  hospital: 'ہسپتال',
  bazar: 'بازار',
  road: 'روڈ',
  market: 'مارکیٹ',
};

/**
 * Transliterate Roman Urdu words to Urdu script.
 * @param {string} text
 * @returns {string}
 */
export function transliterateRomanUrdu(text) {
  if (!text) return text;
  let result = text.toLowerCase();
  for (const [roman, urdu] of Object.entries(ROMAN_URDU_MAP)) {
    result = result.replace(new RegExp(`\\b${roman}\\b`, 'gi'), urdu);
  }
  return result;
}

/**
 * Check if a string contains Arabic/Urdu script characters.
 */
export function isUrduScript(text) {
  return /[\u0600-\u06FF]/.test(text);
}
