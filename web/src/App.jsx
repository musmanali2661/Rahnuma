import React from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import MapView from './components/Map/MapView.jsx';
import DownloadManager from './components/Offline/DownloadManager.jsx';

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<MapView />} />
        <Route path="/offline" element={<DownloadManager />} />
      </Routes>
    </BrowserRouter>
  );
}
