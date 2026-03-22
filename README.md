# Rahnuma Navigation System

A comprehensive navigation system designed for Pakistan, leveraging OpenStreetMap data, AI-driven road condition detection via mobile IMU sensors, and culturally-adapted UX with Urdu language support.

---

## Table of Contents
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Quick Start](#quick-start)
- [Installation](#installation)
- [Running the Development Environment](#running-the-development-environment)
- [Data Download](#data-download)
- [Testing](#testing)
- [API Documentation](#api-documentation)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

- **Docker** 24+ and Docker Compose v2
- **Node.js** 18+ and npm 9+
- **Flutter** 3.22+ and Dart 3.4+
- **Python** 3.11+ (for ML service)
- **Git** 2.40+
- At least **20GB free disk space** (for OSM data and map tiles)
- At least **8GB RAM** recommended

---

## Project Structure

```
rahnuma/
├── backend/           # Node.js API server + Python ML service
├── web/               # React web application (MapLibre GL)
├── mobile/            # Flutter mobile application
├── data/              # OSM data, offline packages, map styles
├── scripts/           # Setup and maintenance scripts
└── docs/              # Documentation
```

---

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/musmanali2661/Rahnuma.git
cd Rahnuma

# 2. Copy environment variables
cp .env.example .env
# Edit .env with your settings

# 3. Start the development environment
docker compose up -d

# 4. Import OSM data (first time only — takes ~15 minutes)
./scripts/import_osm_data.sh

# 5. Start OSRM routing engine
./scripts/start_osrm.sh

# 6. Open the web app
open http://localhost:5173
```

---

## Installation

### Backend

```bash
cd backend
npm install
pip install -r requirements.txt
```

### Web Application

```bash
cd web
npm install
npm run dev   # starts Vite dev server on http://localhost:5173
```

### Mobile Application

```bash
cd mobile
flutter pub get
flutter run   # connects to a running device or emulator
```

---

## Running the Development Environment

All services can be started with Docker Compose:

```bash
docker compose up -d
```

This starts the following services:

| Service | URL | Description |
|---------|-----|-------------|
| PostgreSQL + PostGIS | `localhost:5432` | Main database |
| Redis | `localhost:6379` | Cache |
| OSRM | `localhost:5000` | Routing engine |
| Martin (tile server) | `localhost:3000` | Vector tile server |
| Backend API | `localhost:4000` | REST API + WebSocket |
| Web App | `localhost:5173` | Vite dev server |
| Nginx | `localhost:80` | Reverse proxy |

To view logs for a specific service:
```bash
docker compose logs -f backend
```

To stop all services:
```bash
docker compose down
```

---

## Data Download

### OSM Pakistan Extract

```bash
# Download and import (automated)
./scripts/import_osm_data.sh

# Manual download (~1.5GB)
wget -P data/osm/ https://download.geofabrik.de/asia/pakistan-latest.osm.pbf
```

### Generate Offline City Packages

```bash
./scripts/generate_offline_packages.sh
# Generates MBTiles for: Karachi, Lahore, Islamabad, Rawalpindi, Faisalabad, Multan, Peshawar, Quetta
```

---

## Testing

### Backend Tests
```bash
cd backend
npm test
```

### Web Tests
```bash
cd web
npm test
```

### Mobile Tests
```bash
cd mobile
flutter test
```

### Integration Tests
```bash
# Requires Docker services running
docker compose -f docker-compose.test.yml up --abort-on-container-exit
```

---

## API Documentation

See [docs/API.md](docs/API.md) for full API reference.

Key endpoints:
- `POST /api/v1/route` — Calculate route between waypoints
- `GET /api/v1/search` — Search for places/addresses
- `GET /api/v1/events` — Get road events (potholes, speed bumps)
- `GET /api/v1/offline/packages` — List offline map packages

---

## Environment Variables

See [.env.example](.env.example) for all available environment variables.

---

## Troubleshooting

### OSRM preprocessing takes too long
OSRM preprocessing for Pakistan data can take 30-60 minutes on first run. This is normal. The processed files are cached in `data/osrm/`.

### Map tiles not showing
Ensure Martin tile server is running and `data/styles/rahnuma_style.json` points to the correct tile URL.

### Flutter build fails on Android
Make sure `ANDROID_HOME` is set and you have Android SDK platform tools installed:
```bash
flutter doctor
```

### PostgreSQL connection refused
Check that the database is running and credentials in `.env` match:
```bash
docker compose ps postgres
docker compose logs postgres
```

### OSM import fails
Ensure you have at least 8GB RAM available for osm2pgsql import:
```bash
./scripts/import_osm_data.sh --slim --cache 4096
```

---

## Contributing

See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines.

---

## License

MIT License — see [LICENSE](LICENSE) for details.
