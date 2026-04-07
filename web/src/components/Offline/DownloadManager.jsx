import React, { useState, useEffect, useCallback } from 'react';
import { listOfflinePackages } from '../../services/api.js';
import { downloadPackage, getStorageUsage } from '../../services/storage.js';
import Card from '../UI/Card.jsx';

export default function DownloadManager() {
  const [packages, setPackages] = useState([]);
  const [downloading, setDownloading] = useState({});
  const [progress, setProgress] = useState({});
  const [storageUsage, setStorageUsage] = useState(null);
  const [error, setError] = useState(null);

  useEffect(() => {
    loadPackages();
    refreshStorage();
  }, []);

  const loadPackages = async () => {
    try {
      const data = await listOfflinePackages();
      setPackages(data.packages || []);
    } catch (err) {
      setError('Failed to load packages');
    }
  };

  const refreshStorage = async () => {
    const usage = await getStorageUsage();
    setStorageUsage(usage);
  };

  const handleDownload = useCallback(async (pkg) => {
    setDownloading((d) => ({ ...d, [pkg.id]: true }));
    setProgress((p) => ({ ...p, [pkg.id]: 0 }));

    try {
      await downloadPackage(pkg.id, (pct) => {
        setProgress((p) => ({ ...p, [pkg.id]: pct }));
      });
      await loadPackages();
      await refreshStorage();
    } catch (err) {
      setError(`Download failed for ${pkg.name}: ${err.message}`);
    } finally {
      setDownloading((d) => ({ ...d, [pkg.id]: false }));
    }
  }, []);

  const formatBytes = (bytes) => {
    if (!bytes) return '–';
    const mb = bytes / (1024 * 1024);
    return mb > 1000 ? `${(mb / 1024).toFixed(1)} GB` : `${mb.toFixed(0)} MB`;
  };

  return (
    <div className="min-h-screen bg-gray-50 p-4">
      <div className="max-w-md mx-auto">
        <h1 className="text-2xl font-bold text-gray-900 mb-1">Offline Maps</h1>
        <p className="text-sm text-gray-500 mb-4 urdu">آف لائن نقشے</p>

        {storageUsage && (
          <Card className="mb-4">
            <p className="text-xs text-gray-500">Storage used</p>
            <div className="flex items-center gap-3 mt-1">
              <div className="flex-1 bg-gray-200 rounded-full h-2">
                <div
                  className="bg-green-600 h-2 rounded-full"
                  style={{ width: `${Math.min(100, (storageUsage.used / storageUsage.quota) * 100)}%` }}
                />
              </div>
              <span className="text-xs text-gray-700">
                {formatBytes(storageUsage.used)} / {formatBytes(storageUsage.quota)}
              </span>
            </div>
          </Card>
        )}

        {error && (
          <div className="bg-red-50 text-red-700 text-sm p-3 rounded-lg mb-4">{error}</div>
        )}

        <div className="space-y-3">
          {packages.map((pkg) => {
            const isDownloading = downloading[pkg.id];
            const pct = progress[pkg.id] || 0;
            return (
              <Card key={pkg.id} className="flex items-center justify-between gap-3">
                <div className="flex-1 min-w-0">
                  <p className="font-medium text-gray-900">{pkg.name}</p>
                  <p className="text-xs text-gray-500">
                    {pkg.available
                      ? `Downloaded · ${formatBytes(pkg.file_size_bytes)}`
                      : `~${pkg.size_mb} MB`}
                  </p>
                  {isDownloading && (
                    <div className="mt-1 bg-gray-200 rounded-full h-1.5">
                      <div className="bg-blue-500 h-1.5 rounded-full transition-all" style={{ width: `${pct}%` }} />
                    </div>
                  )}
                </div>
                <button
                  onClick={() => handleDownload(pkg)}
                  disabled={isDownloading || pkg.available}
                  className={`px-3 py-1.5 rounded-lg text-sm font-medium transition ${
                    pkg.available
                      ? 'bg-green-100 text-green-700 cursor-default'
                      : isDownloading
                      ? 'bg-gray-100 text-gray-400 cursor-wait'
                      : 'bg-blue-600 text-white hover:bg-blue-700'
                  }`}
                >
                  {pkg.available ? '✓ Ready' : isDownloading ? `${pct}%` : 'Download'}
                </button>
              </Card>
            );
          })}
        </div>
      </div>
    </div>
  );
}
