/**
 * IndexedDB storage service for offline map tiles.
 */

const DB_NAME = 'rahnuma_offline';
const DB_VERSION = 1;
const TILES_STORE = 'tiles';

let db = null;

function openDB() {
  return new Promise((resolve, reject) => {
    const req = indexedDB.open(DB_NAME, DB_VERSION);
    req.onupgradeneeded = (e) => {
      const db = e.target.result;
      if (!db.objectStoreNames.contains(TILES_STORE)) {
        db.createObjectStore(TILES_STORE);
      }
    };
    req.onsuccess = (e) => resolve(e.target.result);
    req.onerror = (e) => reject(e.target.error);
  });
}

async function getDB() {
  if (!db) db = await openDB();
  return db;
}

export async function storeTile(key, blob) {
  const database = await getDB();
  return new Promise((resolve, reject) => {
    const tx = database.transaction(TILES_STORE, 'readwrite');
    const req = tx.objectStore(TILES_STORE).put(blob, key);
    req.onsuccess = () => resolve();
    req.onerror = (e) => reject(e.target.error);
  });
}

export async function getTile(key) {
  const database = await getDB();
  return new Promise((resolve, reject) => {
    const tx = database.transaction(TILES_STORE, 'readonly');
    const req = tx.objectStore(TILES_STORE).get(key);
    req.onsuccess = (e) => resolve(e.target.result || null);
    req.onerror = (e) => reject(e.target.error);
  });
}

/**
 * Download an offline package for a city and store it in IndexedDB.
 * @param {string} cityId
 * @param {function(number)} onProgress  Callback with percentage 0–100
 */
export async function downloadPackage(cityId, onProgress) {
  const API_BASE = import.meta.env.VITE_API_URL || 'http://localhost:4000';
  const url = `${API_BASE}/api/v1/offline/packages/${cityId}`;

  const response = await fetch(url);
  if (!response.ok) throw new Error(`HTTP ${response.status}`);

  const contentLength = response.headers.get('Content-Length');
  const total = contentLength ? parseInt(contentLength, 10) : 0;
  const reader = response.body.getReader();
  const chunks = [];
  let received = 0;
  let lastReported = -1;

  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    chunks.push(value);
    received += value.length;
    if (total > 0) {
      const pct = Math.round((received / total) * 100);
      if (pct !== lastReported) { onProgress?.(pct); lastReported = pct; }
    } else {
      // Content-Length unavailable — report bytes received as progress signal
      onProgress?.(-received);
    }
  }

  const blob = new Blob(chunks, { type: 'application/x-sqlite3' });
  await storeTile(`package:${cityId}`, blob);
  onProgress?.(100);
}

export async function getStorageUsage() {
  if (!navigator.storage?.estimate) return null;
  const { usage, quota } = await navigator.storage.estimate();
  return { used: usage, quota };
}
