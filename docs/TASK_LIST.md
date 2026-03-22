# Rahnuma — Comprehensive Task List

> Derived from the **Software Requirements Document (SRD) v1.0** (March 22, 2026).  
> Every task maps directly to a SRD section/requirement ID.  
> Priority legend: 🔴 P0 (Must-have) · 🟠 P1 (Should-have) · 🟡 P2 (Nice-to-have) · ⚪ P3 (Future)

---

## Table of Contents

1. [Pre-Development Setup](#pre-development-setup)
2. [Phase 1 — Core Navigation (Months 1–3)](#phase-1--core-navigation-months-13)
   - [1.1 Infrastructure & DevOps](#11-infrastructure--devops)
   - [1.2 Database & Data Layer](#12-database--data-layer)
   - [1.3 Backend API Services](#13-backend-api-services)
   - [1.4 Map & Routing Engine](#14-map--routing-engine)
   - [1.5 Web Application (React)](#15-web-application-react)
   - [1.6 Mobile Application (Flutter)](#16-mobile-application-flutter)
   - [1.7 IMU Sensor — Phase 1 Prototype](#17-imu-sensor--phase-1-prototype)
   - [1.8 Offline Maps — Phase 1](#18-offline-maps--phase-1)
   - [1.9 Urdu Language Support — Phase 1](#19-urdu-language-support--phase-1)
3. [Phase 2 — Community & Safety (Months 4–6)](#phase-2--community--safety-months-46)
   - [2.1 User Accounts & Profiles](#21-user-accounts--profiles)
   - [2.2 Hazard Reporting System](#22-hazard-reporting-system)
   - [2.3 SOS & Safety Features](#23-sos--safety-features)
   - [2.4 IMU ML Model — Production](#24-imu-ml-model--production)
   - [2.5 Vehicle Profiles](#25-vehicle-profiles)
   - [2.6 POI Enhancements](#26-poi-enhancements)
   - [2.7 Speed Cameras & Police Data](#27-speed-cameras--police-data)
4. [Phase 3 — Advanced Features (Months 7–9)](#phase-3--advanced-features-months-79)
   - [3.1 Caravan & Social Features](#31-caravan--social-features)
   - [3.2 Traffic Prediction & ML](#32-traffic-prediction--ml)
   - [3.3 Advanced Routing](#33-advanced-routing)
   - [3.4 Toll Integration](#34-toll-integration)
   - [3.5 EV & Fuel Enhancements](#35-ev--fuel-enhancements)
   - [3.6 Voice Commands (Hey Rahnuma)](#36-voice-commands-hey-rahnuma)
   - [3.7 AR Navigation](#37-ar-navigation)
5. [Phase 4 — Monetization & Scale (Months 10–12)](#phase-4--monetization--scale-months-1012)
6. [Cross-Cutting: Security & Privacy](#cross-cutting-security--privacy)
7. [Cross-Cutting: Testing](#cross-cutting-testing)
8. [Cross-Cutting: Performance & Monitoring](#cross-cutting-performance--monitoring)
9. [Cross-Cutting: Deployment & CI/CD](#cross-cutting-deployment--cicd)
10. [Risk Mitigation Actions](#risk-mitigation-actions)

---

## Pre-Development Setup

> Foundation work that must be complete before any feature development begins.

### Environment & Tooling

- [ ] **SETUP-01** 🔴 Provision development, staging, and production environments (DigitalOcean/AWS Pakistan region)
- [ ] **SETUP-02** 🔴 Configure Docker + Docker Compose for local development (all services)
- [ ] **SETUP-03** 🔴 Set up GitHub repository with branch protection rules (main, develop, release/*)
- [ ] **SETUP-04** 🔴 Configure GitHub Actions CI/CD pipeline (lint → test → build → deploy)
- [ ] **SETUP-05** 🔴 Create `.env.example` with all required environment variables documented
- [ ] **SETUP-06** 🔴 Set up Kubernetes cluster (k3s initially) with namespaces per environment
- [ ] **SETUP-07** 🔴 Configure Infrastructure as Code using Terraform
- [ ] **SETUP-08** 🔴 Set up secrets management (GitHub Secrets / HashiCorp Vault)

### OSM Data Acquisition

- [ ] **DATA-01** 🔴 Download Pakistan OSM extract from Geofabrik (`pakistan-latest.osm.pbf`)
- [ ] **DATA-02** 🔴 Set up weekly automated OSM refresh schedule
- [ ] **DATA-03** 🔴 Import OSM data into PostgreSQL/PostGIS using `osm2pgsql`
- [ ] **DATA-04** 🔴 Extract road attributes: surface type, lanes, speed limits, access restrictions
- [ ] **DATA-05** 🔴 Extract and categorize POIs (mosques, hospitals, petrol stations, dhabas)
- [ ] **DATA-06** 🟠 Import administrative boundaries (districts, tehsils, union councils)
- [ ] **DATA-07** 🔴 Generate OSRM routing graph from Pakistan OSM extract (car profile)
- [ ] **DATA-08** 🔴 Validate routing graph coverage across all 4 provinces + AJK + GB

### Team & Process

- [ ] **PROC-01** 🔴 Define sprint cycle (2-week sprints recommended)
- [ ] **PROC-02** 🔴 Assign roles: Product Owner, Tech Lead, Frontend (Web), Frontend (Mobile), Backend, ML, QA, DevOps
- [ ] **PROC-03** 🔴 Set up project management tool (Jira / Linear / GitHub Projects)
- [ ] **PROC-04** 🔴 Establish code review process (minimum 1 reviewer per PR)
- [ ] **PROC-05** 🟠 Schedule weekly SRD review to track requirement coverage

---

## Phase 1 — Core Navigation (Months 1–3)

### 1.1 Infrastructure & DevOps

*SRD §12.1, §5.1 (Backend Services)*

- [ ] **INF-01** 🔴 Deploy PostgreSQL 16 + PostGIS 3.4 container; run all schema migrations
- [ ] **INF-02** 🔴 Deploy Redis 7.2 cluster for session cache, tile cache, and rate limiting
- [ ] **INF-03** 🔴 Deploy OSRM 5.27 with Pakistan car routing graph (MLD algorithm)
- [ ] **INF-04** 🔴 Deploy Martin 0.12+ vector tile server connected to PostGIS
- [ ] **INF-05** 🔴 Deploy Nominatim (self-hosted) with Pakistan OSM data for geocoding
- [ ] **INF-06** 🔴 Deploy Nginx reverse proxy with CORS, HTTPS (TLS 1.3), and compression
- [ ] **INF-07** 🔴 Configure MinIO (S3-compatible) for offline package and media storage
- [ ] **INF-08** 🟠 Deploy RabbitMQ 3.13 for async sensor event processing queue
- [ ] **INF-09** 🟠 Deploy ClickHouse 24.3 for analytics and telemetry

### 1.2 Database & Data Layer

*SRD §5.3 (Schema), §6.3 (Retention)*

- [ ] **DB-01** 🔴 Create `users` table with UUID PK, phone/email unique, language, reputation_score
- [ ] **DB-02** 🔴 Create `vehicles` table with type, dimensions, fuel_type, is_default
- [ ] **DB-03** 🔴 Create `road_events` table with PostGIS Point geometry, severity, confidence, expires_at
- [ ] **DB-04** 🔴 Create `user_reports` table with report_type, severity, media_urls, status workflow
- [ ] **DB-05** 🔴 Create `pois` table with OSM ID, Urdu name, category, opening_hours, ratings
- [ ] **DB-06** 🔴 Create `trips` table with start/end geometry, distance, duration, route_geometry
- [ ] **DB-07** 🔴 Create all GIST spatial indexes (road_events, user_reports, pois locations)
- [ ] **DB-08** 🔴 Create time-based indexes on reported_at, created_at columns
- [ ] **DB-09** 🟠 Implement data retention cron jobs per SRD §6.3 policy:
  - Raw IMU data: auto-delete after 7 days
  - Aggregated road events: 90-day retention
  - User reports: 30-day retention (verified may persist)
  - Trip history: 1-year retention
- [ ] **DB-10** 🔴 Write and run database migrations (versioned SQL files)
- [ ] **DB-11** 🔴 Test all spatial queries with Pakistani coordinate data

### 1.3 Backend API Services

*SRD §7.1, §7.2, §4.5*

- [ ] **API-01** 🔴 Scaffold Express.js (or Fastify) API server with OpenAPI 3.0 spec
- [ ] **API-02** 🔴 Implement JWT authentication middleware (24-hour access + 30-day refresh tokens)
- [ ] **API-03** 🔴 Implement rate limiting: 100 requests/minute per user/IP (SRD SEC-04)
- [ ] **API-04** 🔴 Implement input validation and sanitization on all endpoints (SRD SEC-05)
- [ ] **API-05** 🔴 `GET /api/v1/route` — route calculation with OSRM, return steps + geometry
- [ ] **API-06** 🔴 `GET /api/v1/search` — geocoding/search via Nominatim with Roman Urdu support
- [ ] **API-07** 🔴 `GET /api/v1/search/reverse` — reverse geocode a coordinate
- [ ] **API-08** 🔴 `GET /api/v1/events` — spatial query for road events in bounding box
- [ ] **API-09** 🔴 `POST /api/v1/events` — submit IMU road event (authenticated)
- [ ] **API-10** 🔴 `GET /api/v1/offline/packages` — list available city offline packages
- [ ] **API-11** 🔴 `GET /api/v1/offline/packages/:city` — download MBTiles package
- [ ] **API-12** 🔴 `GET /api/v1/pois` — fetch POIs by category within bounding box
- [ ] **API-13** 🔴 WebSocket endpoint `/v1/live` — real-time navigation updates (location, hazard_alert, reroute messages)
- [ ] **API-14** 🔴 Implement Redis caching layer for routes (TTL: 5 minutes) and tiles (TTL: 24 hours)
- [ ] **API-15** 🔴 Add `/health` and `/ready` endpoints for Kubernetes probes
- [ ] **API-16** 🔴 Set up structured logging with Winston (JSON format for production)
- [ ] **API-17** 🔴 Add `Content-Security-Policy`, `X-Frame-Options`, and HSTS response headers
- [ ] **API-18** 🟠 Implement OpenAPI 3.0 documentation (Swagger UI at `/api/docs`)

### 1.4 Map & Routing Engine

*SRD §3.1, §3.2, MAP-01 – MAP-06, NAV-01 – NAV-10*

- [ ] **MAP-01** 🔴 Create custom MapLibre GL style (`rahnuma_style.json`) with Pakistani road colour scheme:
  - Motorways: `#2E7D32` (green)
  - Primary roads: `#FF9800` (orange)
  - Secondary roads: `#757575` (gray)
  - Residential: `#E0E0E0` (light gray)
  - Unpaved/tracks: `#8D6E63` dashed (brown)
- [ ] **MAP-02** 🔴 Support zoom levels 3–19 with appropriate layer visibility thresholds
- [ ] **MAP-03** 🔴 Add Urdu labels for cities, roads, and landmarks (use `name:ur` OSM tag)
- [ ] **MAP-04** 🔴 Implement pan, zoom, rotate map controls
- [ ] **MAP-05** 🔴 Implement real-time traffic colour overlay on roads (SRD MAP-06)
- [ ] **MAP-06** 🔴 Implement route polyline rendering (blue, with casing outline)
- [ ] **MAP-07** 🔴 Implement hazard layer (potholes, speed bumps) as styled circle markers
- [ ] **MAP-08** 🔴 Implement user location dot with accuracy circle and heading arrow
- [ ] **MAP-09** 🔴 Implement OSRM route calculation: car profile, with geometry (polyline6 or GeoJSON)
- [ ] **MAP-10** 🔴 Implement 3 route alternatives with trade-off labels (fastest / shortest / eco)
- [ ] **MAP-11** 🔴 Implement waypoints support (up to 10 intermediate stops, SRD NAV-04)
- [ ] **MAP-12** 🟠 Implement route avoidance options: tolls, highways, ferries, unpaved roads (SRD NAV-05)
- [ ] **MAP-13** 🔴 Display toll cost estimate for M-Tag tolls (M-1, M-2, M-3) — SRD NAV-08
- [ ] **MAP-14** 🟠 Show elevation profile before navigation start (SRD NAV-06)
- [ ] **MAP-15** 🔴 Implement live rerouting when user deviates > 50m from route (SRD NAV-07)
- [ ] **MAP-16** 🟠 Add fuel stop suggestion on routes > 100 km (SRD NAV-09)
- [ ] **MAP-17** 🟠 Add rest area alerts on motorway routes (SRD NAV-10)

### 1.5 Web Application (React)

*SRD §5.1 (Frontend-Web), §8.1, §8.2*

#### Setup
- [ ] **WEB-01** 🔴 Bootstrap React 18 + Vite 5 project with TypeScript
- [ ] **WEB-02** 🔴 Configure TailwindCSS 3.4 with custom design tokens (SRD §8.1 colour palette)
- [ ] **WEB-03** 🔴 Configure Zustand 4.5 stores: map, route, user, settings
- [ ] **WEB-04** 🔴 Configure React Router 6.20 with lazy-loaded routes
- [ ] **WEB-05** 🔴 Configure TanStack Query 5.0 for all API calls with caching
- [ ] **WEB-06** 🔴 Configure Vite PWA plugin for offline support (service worker, manifest)
- [ ] **WEB-07** 🔴 Integrate Noto Nastaliq Urdu font with `font-display: swap`

#### Map Screen (SRD §8.2)
- [ ] **WEB-08** 🔴 Build `<MapView>` with MapLibre GL, custom style, Pakistan center
- [ ] **WEB-09** 🔴 Build `<SearchBar>` — autocomplete, debounced API calls, Roman Urdu input
- [ ] **WEB-10** 🔴 Build `<SearchResults>` dropdown with name, category, address
- [ ] **WEB-11** 🔴 Build `<CategoryButtons>` — Petrol ⛽, Food 🍴, Mosque 🕌, Hospital 🏥 quick filters
- [ ] **WEB-12** 🔴 Build `<RouteCard>` bottom sheet — ETA, distance, turn list, toll estimate
- [ ] **WEB-13** 🔴 Build `<AlertPanel>` — collapsible panel showing nearby hazards on route
- [ ] **WEB-14** 🔴 Build `<CurrentLocationButton>` — flies map to user's GPS position
- [ ] **WEB-15** 🟠 Build `<POIToggle>` — filter visible POI categories on map
- [ ] **WEB-16** 🟠 Build `<ZoomControls>` — optional on-screen zoom buttons

#### Navigation Mode (SRD §8.2)
- [ ] **WEB-17** 🔴 Build `<TurnCard>` — next turn with distance, street name in Urdu
- [ ] **WEB-18** 🔴 Build `<ETADisplay>` — time remaining, distance, ETA arrival time
- [ ] **WEB-19** 🔴 Build `<HazardWarning>` — popup alert with audio cue when hazard near
- [ ] **WEB-20** 🟠 Build `<LaneGuidance>` — lane arrow indicators
- [ ] **WEB-21** 🟠 Build `<SpeedDisplay>` — current speed + road speed limit
- [ ] **WEB-22** 🟠 Build `<MiniMap>` — overview of remaining route

#### Offline Screen (SRD §3.7)
- [ ] **WEB-23** 🔴 Build `<DownloadManager>` — list cities, show size, trigger download
- [ ] **WEB-24** 🔴 Implement IndexedDB storage for downloaded MBTiles packages
- [ ] **WEB-25** 🔴 Show download progress bar with accurate percentage
- [ ] **WEB-26** 🔴 Show total storage used / available
- [ ] **WEB-27** 🟠 Implement background download (via Service Worker)

#### Language & Accessibility (SRD §3.6, §4.6)
- [ ] **WEB-28** 🔴 Build `<LanguageToggle>` — one-tap English ↔ Urdu switch without page reload
- [ ] **WEB-29** 🔴 Implement RTL layout for Urdu mode (Nastaliq font, right-aligned)
- [ ] **WEB-30** 🟠 Implement WCAG 2.1 AA compliance — contrast ratios, focus indicators, ARIA labels
- [ ] **WEB-31** 🟡 Add colour-blind mode (protanopia/deuteranopia alternate colour scheme)
- [ ] **WEB-32** 🟠 Make text size configurable (small / medium / large)

### 1.6 Mobile Application (Flutter)

*SRD §5.1 (Frontend-Mobile)*

#### Setup
- [ ] **MOB-01** 🔴 Bootstrap Flutter 3.22+ project for Android + iOS
- [ ] **MOB-02** 🔴 Configure Riverpod 2.5 with code generation (`riverpod_annotation`)
- [ ] **MOB-03** 🔴 Configure GoRouter 14.0 with all screen routes
- [ ] **MOB-04** 🔴 Add all pubspec.yaml dependencies (flutter_map, sensors_plus, geolocator, etc.)
- [ ] **MOB-05** 🔴 Configure Android permissions: `ACCESS_FINE_LOCATION`, `ACCESS_BACKGROUND_LOCATION`, `ACTIVITY_RECOGNITION`
- [ ] **MOB-06** 🔴 Configure iOS permissions: `NSLocationWhenInUseUsageDescription`, `NSMotionUsageDescription`

#### Map Screen
- [ ] **MOB-07** 🔴 Build `MapScreen` with `FlutterMap` widget and custom tile layer
- [ ] **MOB-08** 🔴 Add user location marker with heading indicator
- [ ] **MOB-09** 🔴 Add route polyline layer
- [ ] **MOB-10** 🔴 Add hazard marker layer for potholes/speed bumps
- [ ] **MOB-11** 🔴 Add `ZoomControls` and `CurrentLocationButton` widgets
- [ ] **MOB-12** 🟠 Add `LayerSelector` for switching between road/satellite views
- [ ] **MOB-13** 🔴 Add `SearchBar` with Roman Urdu autocomplete

#### Navigation Screen
- [ ] **MOB-14** 🔴 Build `NavigationScreen` with `TurnCard`, `EtaDisplay`, `HazardWarning`
- [ ] **MOB-15** 🔴 Implement Urdu voice guidance using pre-recorded audio files (audioplayers)
- [ ] **MOB-16** 🔴 Record/source professional Urdu voice prompts (all SRD §8.3 scripts)
- [ ] **MOB-17** 🔴 Implement live rerouting logic when user deviates
- [ ] **MOB-18** 🟠 Build `LaneGuidance` widget with lane arrow indicators
- [ ] **MOB-19** 🟠 Build `SpeedDisplay` widget with current GPS speed + road limit

#### Offline Screen
- [ ] **MOB-20** 🔴 Build `DownloadScreen` — city package list, download/delete actions
- [ ] **MOB-21** 🔴 Implement `TileCache` using MBTiles SQLite with TMS Y-axis flip
- [ ] **MOB-22** 🔴 Build `RegionSelector` map widget for bounding-box area selection
- [ ] **MOB-23** 🟠 Implement background download using `flutter_background_service`

#### Settings Screen
- [ ] **MOB-24** 🔴 Build `SettingsScreen` — language, dark mode, voice on/off, sensor on/off
- [ ] **MOB-25** 🟠 Implement saved places — Home, Work, custom favourites

#### Background Services
- [ ] **MOB-26** 🔴 Implement background location service (continues after app is backgrounded)
- [ ] **MOB-27** 🔴 Implement `SensorService` — 50–100 Hz accelerometer + gyroscope collection
- [ ] **MOB-28** 🔴 Implement adaptive sampling: slow to 20 Hz when speed < 5 km/h or battery < 20%
- [ ] **MOB-29** 🔴 Implement 10-second ring buffer for sensor data
- [ ] **MOB-30** 🔴 Implement WiFi-only batch upload of sensor data to API

### 1.7 IMU Sensor — Phase 1 Prototype

*SRD §3.3 (RSD-01 to RSD-10)*

- [ ] **IMU-01** 🔴 Implement on-device peak detection (Z-axis > 2g = pothole)
- [ ] **IMU-02** 🔴 Implement speed bump detection (sustained 1.5–2g for > 200ms)
- [ ] **IMU-03** 🔴 Implement rough road detection (rolling Z-axis variance > 0.8g RMS over 400ms)
- [ ] **IMU-04** 🔴 Implement moving-average filter (window = 5 samples) to remove high-frequency noise
- [ ] **IMU-05** 🔴 Implement event deduplication: ignore events within 20m of an existing event
- [ ] **IMU-06** 🔴 Assign severity score 1–5 based on peak magnitude (SRD RSD-04)
- [ ] **IMU-07** 🔴 Correlate each detected event with current GPS coordinates + timestamp (SRD RSD-05)
- [ ] **IMU-08** 🔴 Implement Python FastAPI ML service (`/classify` endpoint) for server-side classification
- [ ] **IMU-09** 🔴 Store classified events in `road_events` table with confidence score
- [ ] **IMU-10** 🔴 Implement event verification: auto-verify events reported by ≥ 3 unique users within 50m
- [ ] **IMU-11** 🔴 Implement event expiration: potholes expire after 30 days, speed bumps permanent
- [ ] **IMU-12** 🔴 Implement event processor worker: periodic scan to verify + clean up stale events
- [ ] **IMU-13** 🟠 Add battery optimization: stop sensor collection when battery < 15% (SRD RSD-08)
- [ ] **IMU-14** 🟠 Implement gyroscope-based false positive removal (ignore events during sharp turns)
- [ ] **IMU-15** 🟠 Build event aggregation dashboard query (cluster nearby events for heatmap)

### 1.8 Offline Maps — Phase 1

*SRD §3.7 (OFF-01 to OFF-07)*

- [ ] **OFF-01** 🔴 Generate MBTiles packages for 8 major cities: Karachi, Lahore, Islamabad, Rawalpindi, Faisalabad, Multan, Peshawar, Quetta
- [ ] **OFF-02** 🔴 Include tile zoom levels 10–16 in each city package
- [ ] **OFF-03** 🔴 Store packages on MinIO with public download URLs
- [ ] **OFF-04** 🔴 Implement offline routing using OSRM routing graph bundled in app or downloaded
- [ ] **OFF-05** 🔴 Implement offline POI search within downloaded tile bounds
- [ ] **OFF-06** 🔴 Show storage usage per downloaded region and allow selective deletion (SRD OFF-06)
- [ ] **OFF-07** 🟠 Implement incremental tile updates (diff from last version, not full redownload)
- [ ] **OFF-08** 🟠 Implement smart pre-caching for frequently visited areas (SRD OFF-04)
- [ ] **OFF-09** 🟠 Background download with WiFi-only option (SRD OFF-07)

### 1.9 Urdu Language Support — Phase 1

*SRD §3.6 (LNG-01 to LNG-06)*

- [ ] **LNG-01** 🔴 Integrate Noto Nastaliq Urdu font in both web and mobile apps
- [ ] **LNG-02** 🔴 Implement complete Urdu UI translation for all Phase 1 screens
- [ ] **LNG-03** 🔴 Implement Roman Urdu → Urdu script transliteration map (major cities + common words)
- [ ] **LNG-04** 🔴 Implement English UI as the second supported language
- [ ] **LNG-05** 🔴 Record professional Urdu voice navigation audio files (all prompts in SRD §8.3)
- [ ] **LNG-06** 🔴 Implement one-tap language switch without app restart (SRD LNG-06)
- [ ] **LNG-07** 🔴 Ensure RTL text direction in Urdu mode (web: CSS `direction: rtl`; mobile: `Directionality` widget)

---

## Phase 2 — Community & Safety (Months 4–6)

### 2.1 User Accounts & Profiles

*SRD §3.8 (USR-01 to USR-08)*

- [ ] **USR-01** 🔴 Implement email/phone registration with verification (email link + SMS OTP)
- [ ] **USR-02** 🔴 Implement anonymous guest mode (no registration required for basic use)
- [ ] **USR-03** 🔴 Add OAuth2 sign-in: Google, Apple (SRD §9.1)
- [ ] **USR-04** 🔴 Implement saved places: Home, Work + custom (up to 10) with Urdu labels
- [ ] **USR-05** 🔴 Implement favourites: saved routes and POIs
- [ ] **USR-06** 🟠 Implement trip history: past 50 trips with stats (distance, duration, hazards avoided)
- [ ] **USR-07** 🟠 Implement reputation/karma system: +1 for verified report, -1 for rejected
- [ ] **USR-08** 🟠 Build user profile screen showing contributions and reputation badge
- [ ] **USR-09** 🟠 Implement ETA sharing: generate WhatsApp-shareable link with live ETA (SRD USR-08)

### 2.2 Hazard Reporting System

*SRD §3.4 (ALT-01 to ALT-09)*

- [ ] **HAZ-01** 🔴 Build 3-tap hazard reporting UI: tap icon → select type → confirm location
- [ ] **HAZ-02** 🔴 Support hazard types: Accident, Police Checkpoint, Road Closure, Flood, Protest, Pothole (SRD ALT-02)
- [ ] **HAZ-03** 🔴 Push real-time alerts to all users within 5 km of reported hazard on active routes (SRD ALT-01, ALT-05)
- [ ] **HAZ-04** 🔴 Implement alert auto-expiration: accidents 2 hours, potholes 30 days (SRD ALT-06)
- [ ] **HAZ-05** 🟠 Build verification system: 3+ confirmations marks alert as "verified" (SRD ALT-07)
- [ ] **HAZ-06** 🟠 Add thumbs up/down voting on reports
- [ ] **HAZ-07** 🟠 Implement voice-activated reporting: "Hey Rahnuma, report accident ahead" (SRD ALT-04)
- [ ] **HAZ-08** 🟠 Add optional photo/video attachment to reports (stored in MinIO, SRD RSD-09)
- [ ] **HAZ-09** 🟠 Build moderation queue for admin/moderator review of reports
- [ ] **HAZ-10** 🟠 Add permanent police checkpost layer with shift timings (SRD ALT-08)
- [ ] **HAZ-11** 🟡 Implement protest zone prediction using historical pattern ML model (SRD ALT-09)

### 2.3 SOS & Safety Features

*SRD §3.9 (SAF-01 to SAF-07)*

- [ ] **SAF-01** 🔴 Build SOS button (one-tap, prominent on navigation screen)
- [ ] **SAF-02** 🔴 SOS sends SMS + WhatsApp message to up to 5 emergency contacts with live location link
- [ ] **SAF-03** 🔴 Build emergency contacts management screen (add/edit/delete up to 5 contacts)
- [ ] **SAF-04** 🟠 Implement Safe Route Mode: prefer main roads and well-lit areas for night travel (SRD SAF-03)
- [ ] **SAF-05** 🟠 Display road speed limits on navigation screen where OSM data exists (SRD SAF-04)
- [ ] **SAF-06** 🟠 Implement speed camera alerts (fixed camera locations from crowd-sourced DB)
- [ ] **SAF-07** 🟠 Implement curfew/restricted area alerts (alert when entering flagged zones)
- [ ] **SAF-08** 🟠 Build temporary location sharing: share live location with contact for N hours (SRD SAF-07)
- [ ] **SAF-09** 🟠 Add auto-accident detection: trigger SOS if sudden deceleration + gyroscope anomaly detected with no user dismissal

### 2.4 IMU ML Model — Production

*SRD §13.2, §3.3*

- [ ] **ML-01** 🔴 Collect labelled training dataset: drive with phone in Karachi/Lahore; label potholes, speed bumps, rough roads manually
- [ ] **ML-02** 🔴 Design LSTM or 1D-CNN model architecture for time-series IMU classification
- [ ] **ML-03** 🔴 Train model on labelled dataset; target: > 85% precision, < 10% false positive rate (SRD REL-03, REL-04)
- [ ] **ML-04** 🔴 Evaluate model on holdout set; generate confusion matrix
- [ ] **ML-05** 🔴 Convert model to TensorFlow Lite (TFLite) for on-device inference
- [ ] **ML-06** 🔴 Integrate TFLite model into Flutter app; replace threshold classifier
- [ ] **ML-07** 🔴 Update Python FastAPI ML service to use production model for server-side verification
- [ ] **ML-08** 🟠 Implement model OTA update mechanism (download new model without app store release)
- [ ] **ML-09** 🟠 Set up continuous model retraining pipeline: new labelled data → retrain → evaluate → deploy
- [ ] **ML-10** 🟠 Build model performance dashboard in Grafana

### 2.5 Vehicle Profiles

*SRD §3.10 (VEH-01 to VEH-05)*

- [ ] **VEH-01** 🟠 Build vehicle profile screen: add/edit car, motorcycle, rickshaw, truck profiles
- [ ] **VEH-02** 🟠 Implement motorcycle routing mode in OSRM (avoid motorways, use narrow lanes)
- [ ] **VEH-03** 🟠 Implement rickshaw routing mode: prioritize narrow streets, avoid highways (SRD VEH-02)
- [ ] **VEH-04** 🟠 Implement height restriction alerts: flag routes passing under bridges with height data (SRD VEH-03)
- [ ] **VEH-05** 🟠 Implement fuel efficiency routing mode: minimize fuel consumption (SRD VEH-05)
- [ ] **VEH-06** 🟡 Implement bridge weight limit warnings for truck profile (SRD VEH-04)

### 2.6 POI Enhancements

*SRD §3.5 (POI-01 to POI-08)*

- [ ] **POI-01** 🔴 Ensure all standard POI categories are imported: petrol, mosque, hospital, restaurant, parking, ATM, police
- [ ] **POI-02** 🔴 Add Pakistan-specific POI categories: dhaba, tandoor, chai stall, CNG station, mechanic (SRD POI-02)
- [ ] **POI-03** 🔴 Add Urdu names for all major POIs from OSM `name:ur` tags
- [ ] **POI-04** 🟠 Implement prayer time adjustments for business POI hours (show "Open after Zuhr") (SRD POI-08)
- [ ] **POI-05** 🟠 Build POI review system: star rating + text review (Urdu or English)
- [ ] **POI-06** 🟠 Allow photo uploads for POI reviews (stored in MinIO)
- [ ] **POI-07** 🟠 Implement real-time fuel availability status during shortage periods (SRD POI-03)
- [ ] **POI-08** 🟠 Show current petrol/diesel/CNG prices via scraping or user reports (SRD POI-04)
- [ ] **POI-09** 🟠 Add user-submitted hygiene ratings for food places (SRD POI-05)
- [ ] **POI-10** 🟡 Add EV charging station locations and availability (SRD POI-06)

### 2.7 Speed Cameras & Police Data

*SRD §3.4 ALT-08, §3.9 SAF-05, SAF-06*

- [ ] **CAM-01** 🟠 Create crowd-sourced speed camera database schema (`speed_cameras` table with location, type, verified status)
- [ ] **CAM-02** 🟠 Build speed camera submission form in app
- [ ] **CAM-03** 🟠 Implement speed camera alerts: audio + visual warning 500m before camera
- [ ] **CAM-04** 🟠 Import permanent police checkpost data and display on map with timings
- [ ] **CAM-05** 🟠 Implement community voting to verify/remove stale speed camera entries

---

## Phase 3 — Advanced Features (Months 7–9)

### 3.1 Caravan & Social Features

*SRD §3.8 USR-07, §13.3*

- [ ] **CAR-01** 🟠 Design group/caravan data model: session, members, shared waypoints
- [ ] **CAR-02** 🟠 Build Caravan Mode: create group with shareable link/QR code
- [ ] **CAR-03** 🟠 Show all group members' live locations on shared map view
- [ ] **CAR-04** 🟠 Implement leader–follower navigation: followers automatically follow leader's route
- [ ] **CAR-05** 🟠 Add group chat and emoji reactions in caravan session
- [ ] **CAR-06** 🟠 Add shared rest stop voting ("stop here?" with group vote)
- [ ] **CAR-07** 🟠 Implement caravan arrival notifications

### 3.2 Traffic Prediction & ML

*SRD §6.2 (Traffic Patterns), §13.3*

- [ ] **TRF-01** 🟠 Collect anonymous speed samples from active navigation sessions (opt-in)
- [ ] **TRF-02** 🟠 Build data pipeline: raw GPS speeds → ClickHouse aggregation by road segment + time of day
- [ ] **TRF-03** 🟠 Train time-series ML model (LSTM or Gradient Boosting) for ETA prediction
- [ ] **TRF-04** 🟠 Features: time-of-day, day-of-week, weather (if available), historical speed, event density
- [ ] **TRF-05** 🟠 Integrate traffic prediction into routing: dynamically weight road costs
- [ ] **TRF-06** 🟠 Build "Leave at time X for ETA Y" predictor
- [ ] **TRF-07** 🟠 Display traffic heatmap layer on map

### 3.3 Advanced Routing

*SRD §13.3*

- [ ] **ADV-01** 🟠 Add pedestrian routing profile (OSRM foot profile)
- [ ] **ADV-02** 🟠 Add bicycle routing profile (OSRM bike profile)
- [ ] **ADV-03** 🟠 Implement multi-modal routing: car + walking combinations (e.g., drive to parking, walk to destination)
- [ ] **ADV-04** 🟠 Integrate intercity bus route data (BRT, Daewoo, road express timetables)
- [ ] **ADV-05** 🟠 Implement "Wedding Season" routing mode: flag common wedding venue areas as high-risk on Fridays/Saturdays/Sundays during peak season (SRD §13.5)

### 3.4 Toll Integration

*SRD §13.3, NAV-08*

- [ ] **TOL-01** 🟠 Build M-Tag toll cost calculation engine: segment-by-segment toll lookup
- [ ] **TOL-02** 🟠 Show itemised toll list per route (M-1, M-2, M-3, M-4 breakdowns)
- [ ] **TOL-03** 🟠 Integrate M-Tag balance check API (if NHA provides)
- [ ] **TOL-04** 🟠 Add toll-free route alternative with time penalty display

### 3.5 EV & Fuel Enhancements

*SRD §3.5 POI-06, §13.5 (Fuel Shortage Mode)*

- [ ] **EV-01** 🟡 Add EV charging station database (crowd-sourced + imported from OSM)
- [ ] **EV-02** 🟡 Show EV charger type, power rating, and real-time availability (if API exists)
- [ ] **EV-03** 🟠 Implement "Fuel Shortage Mode": highlight all open petrol pumps in city with crowd-sourced availability status
- [ ] **EV-04** 🟠 Integrate OGRA fuel price API for real-time petrol/diesel/CNG prices

### 3.6 Voice Commands (Hey Rahnuma)

*SRD §3.6 LNG-05, §3.4 ALT-04, §13.3*

- [ ] **VOI-01** 🟠 Integrate on-device speech recognition (Google Speech-to-Text / on-device Whisper)
- [ ] **VOI-02** 🟠 Support Urdu command vocabulary: navigation, search, hazard reporting, cancellation
- [ ] **VOI-03** 🟠 Implement wake-word detection "Hey Rahnuma" (on-device, privacy-preserving)
- [ ] **VOI-04** 🟠 Commands to implement:
  - "گھر چلو" (Go home)
  - "قریبی پٹرول پمپ" (Nearest petrol pump)
  - "سامنے حادثہ رپورٹ کرو" (Report accident ahead)
  - "راستہ منسوخ کرو" (Cancel route)
  - "متبادل راستہ دکھاؤ" (Show alternate route)
- [ ] **VOI-05** 🟠 Provide text feedback for each voice command response

### 3.7 AR Navigation

*SRD §13.3*

- [ ] **AR-01** 🟡 Research ARCore (Android) and ARKit (iOS) feasibility for navigation overlay
- [ ] **AR-02** 🟡 Implement camera-based AR with turn arrow overlaid on live camera feed
- [ ] **AR-03** 🟡 Show street name and distance to next turn in AR overlay
- [ ] **AR-04** 🟡 Show POI labels in AR for nearby fuel stations and mosques

---

## Phase 4 — Monetization & Scale (Months 10–12)

*SRD §13.4*

- [ ] **MON-01** 🟡 Build business listing system: verified business profiles with premium features
- [ ] **MON-02** 🟡 Implement featured placement in search results for paid businesses
- [ ] **MON-03** 🟡 Build business owner analytics dashboard (impressions, directions count, reviews)
- [ ] **MON-04** 🟡 Implement premium user tier: unlimited offline maps, ad-free, priority updates
- [ ] **MON-05** 🟡 Build fleet management dashboard: track multiple vehicles, route optimisation, driver reports
- [ ] **MON-06** 🟡 Create Fleet Management API for logistics company integration
- [ ] **MON-07** 🟡 Build contextual advertising system (show relevant POI ads near user)
- [ ] **MON-08** 🟡 Build Road Condition Data API for government/NHA use (anonymised, aggregated)
- [ ] **MON-09** 🟡 Set up subscription billing via JazzCash / EasyPaisa / credit card
- [ ] **MON-10** 🟡 Implement referral program for user growth

---

## Cross-Cutting: Security & Privacy

*SRD §4.5, §9.1–9.3*

- [ ] **SEC-01** 🔴 Enforce TLS 1.3 on all endpoints; redirect HTTP → HTTPS
- [ ] **SEC-02** 🔴 Encrypt all sensitive stored data with AES-256 (user PII, location history)
- [ ] **SEC-03** 🔴 Implement parameterized queries everywhere; no raw SQL string concatenation (SQL injection prevention)
- [ ] **SEC-04** 🔴 Set `Content-Security-Policy`, `X-Content-Type-Options`, `X-Frame-Options`, `Strict-Transport-Security` headers
- [ ] **SEC-05** 🔴 Implement CORS with strict allowlist of permitted origins
- [ ] **SEC-06** 🔴 Add audit logging: log all access to sensitive data (user location, trip history, personal info)
- [ ] **SEC-07** 🔴 Ensure location data is only collected during active navigation (SRD §9.2)
- [ ] **SEC-08** 🔴 Build "Delete My Data" feature: user can delete account and all associated data
- [ ] **SEC-09** 🔴 Anonymize reports before displaying publicly: never show exact user who reported
- [ ] **SEC-10** 🔴 Store all user data on Pakistan-based servers (data residency, SRD §9.2)
- [ ] **SEC-11** 🟠 Write Privacy Policy compliant with Pakistan Privacy Act (PPA 2023) and GDPR
- [ ] **SEC-12** 🟠 Implement DDoS protection (Cloudflare or equivalent CDN)
- [ ] **SEC-13** 🟠 Schedule quarterly penetration testing
- [ ] **SEC-14** 🟠 Implement refresh token rotation and invalidation on logout

---

## Cross-Cutting: Testing

*SRD §11.1–11.3*

### Unit Tests (target: 80% coverage)
- [ ] **TST-01** 🔴 Write Jest unit tests for all backend service functions (OSRM, Nominatim, offlineService, geoUtils)
- [ ] **TST-02** 🔴 Write Vitest unit tests for all React components and hooks
- [ ] **TST-03** 🔴 Write Flutter unit tests for all service classes and utility functions
- [ ] **TST-04** 🔴 Write Python pytest unit tests for ML classification logic (threshold + production model)
- [ ] **TST-05** 🔴 Configure test coverage reporting (Istanbul / LCOV); fail CI if coverage drops below 80%

### Integration Tests (target: 70% coverage)
- [ ] **TST-06** 🔴 Write API integration tests: all REST endpoints with real DB (use test database)
- [ ] **TST-07** 🔴 Write React Testing Library integration tests for key user flows (search → route → navigate)
- [ ] **TST-08** 🔴 Write Flutter integration tests for map + sensor + offline flows
- [ ] **TST-09** 🔴 Write database migration tests: verify schema consistency across all migrations

### End-to-End Tests (critical paths)
- [ ] **TST-10** 🔴 Set up Playwright E2E tests for web app
- [ ] **TST-11** 🔴 E2E test: search for place → get route → start navigation
- [ ] **TST-12** 🔴 E2E test: download offline package → navigate without internet
- [ ] **TST-13** 🔴 E2E test: report a hazard → hazard appears on map for other users
- [ ] **TST-14** 🟠 Set up Appium tests for mobile app critical paths
- [ ] **TST-15** 🟠 Test on minimum 10 Android device profiles (varying screen sizes and Android versions)

### Performance Tests
- [ ] **TST-16** 🔴 Run k6 load tests: API must handle 10,000 concurrent users at < 200ms p95 (SRD PER-07)
- [ ] **TST-17** 🔴 Test OSRM route calculation: < 3 seconds for Karachi→Lahore (SRD PER-02)
- [ ] **TST-18** 🔴 Test map tile load time: < 2 seconds on 4G connection (SRD PER-01)
- [ ] **TST-19** 🔴 Test mobile app cold start: < 3 seconds on mid-range Android (SRD PER-04)
- [ ] **TST-20** 🟠 Run Locust stress tests for tile server and search endpoints

### Field Testing
- [ ] **TST-21** 🔴 Recruit 100 beta testers in Karachi, Lahore, Islamabad
- [ ] **TST-22** 🔴 Recruit 50 beta testers in rural areas (Sindh, Punjab, KP)
- [ ] **TST-23** 🔴 Recruit 50 beta testers on motorways (M-1, M-2, M-3)
- [ ] **TST-24** 🔴 Collect and analyse IMU data from all beta testers; use as training data for Phase 2 ML model
- [ ] **TST-25** 🟠 Conduct formal usability testing: 90% of users can complete navigation on first use (SRD USE-06)

### Security Tests
- [ ] **TST-26** 🟠 Run OWASP ZAP scan against all API endpoints
- [ ] **TST-27** 🟠 Test rate limiting: verify 429 response after 100 requests/minute
- [ ] **TST-28** 🟠 Test JWT expiration and refresh token flows
- [ ] **TST-29** 🟠 Test input sanitisation with SQL injection and XSS payloads

---

## Cross-Cutting: Performance & Monitoring

*SRD §10.1, §10.2, §4.1*

- [ ] **MON-01** 🔴 Deploy Prometheus for metrics collection from all services
- [ ] **MON-02** 🔴 Deploy Grafana with dashboards for: API latency, error rates, OSRM performance, tile server, DB connections
- [ ] **MON-03** 🔴 Configure AlertManager alerts:
  - API error rate > 1% for 5 minutes
  - Tile server latency > 500ms
  - OSRM service down
  - DB connection pool > 80%
- [ ] **MON-04** 🔴 Integrate Sentry for crash reporting (web + mobile)
- [ ] **MON-05** 🔴 Set up ClickHouse telemetry pipeline for user analytics
- [ ] **MON-06** 🔴 Track KPIs weekly: MAU, session duration, routes per user, report accuracy (SRD §10.1)
- [ ] **MON-07** 🟠 Set up uptime monitoring: API 99.9%, tile server 99.5% (SRD AVL-01, AVL-02)
- [ ] **MON-08** 🟠 Configure auto-scaling rules in Kubernetes (scale up when CPU > 70%)

---

## Cross-Cutting: Deployment & CI/CD

*SRD §12.1, §12.2*

- [ ] **DEP-01** 🔴 Configure GitHub Actions workflow: lint → unit test → integration test → build Docker image → push to registry → deploy to staging
- [ ] **DEP-02** 🔴 Configure deployment to production with manual approval gate
- [ ] **DEP-03** 🔴 Write Terraform infrastructure code for all cloud resources
- [ ] **DEP-04** 🔴 Configure Kubernetes manifests (Deployments, Services, Ingress, HPA) for all services
- [ ] **DEP-05** 🔴 Configure automated database backup: daily pg_dump → MinIO/S3 with 30-day retention
- [ ] **DEP-06** 🔴 Document rollback procedure and test it in staging
- [ ] **DEP-07** 🟠 Set up staging environment as production-parity (same infra, anonymised data)
- [ ] **DEP-08** 🟠 Configure Cloudflare CDN for tile server to cache tiles at edge
- [ ] **DEP-09** 🟠 Configure maintenance window procedure (Sundays 2–4 AM announcement 72h prior, SRD AVL-04)
- [ ] **DEP-10** 🟠 Publish mobile app to Google Play Store (Alpha → Beta → Production track)
- [ ] **DEP-11** 🟠 Publish mobile app to Apple App Store
- [ ] **DEP-12** 🔴 Write comprehensive `DEPLOYMENT.md` with step-by-step production setup guide

---

## Risk Mitigation Actions

*SRD §14.1–14.3*

| Risk | SRD ID | Mitigation Task |
|------|--------|-----------------|
| OSM data quality gaps in rural areas | TEC-01 | Organise community mapping drives; validate routing graph for top 10 routes |
| IMU battery drain | TEC-02 | Implement adaptive sampling rate; add user-visible sensor toggle; test on 10+ Android devices |
| Offline storage limitations | TEC-03 | Implement tile compression (Brotli); allow user to choose zoom range |
| Android fragmentation (sensor APIs) | TEC-04 | Test `sensors_plus` on 20+ device models; provide graceful fallback if sensor unavailable |
| Google Maps improving Pakistan support | BIZ-01 | Accelerate Pakistan-unique features: rickshaw mode, checkpost alerts, funeral/wedding routing |
| User adoption challenges | BIZ-02 | Run referral program; partner with universities and motorcycle clubs; social media campaign |
| Data accuracy concerns | BIZ-03 | Prominent report age indicators; reputation-based trust scores; 3-report verification threshold |
| Regulatory issues (privacy law) | BIZ-04 | Consult PTA/PDMA legal; publish Privacy Policy before beta launch |
| Server downtime | OPS-01 | Multi-availability-zone deployment; configure Kubernetes pod restart policy; test failover |
| Security breach | OPS-02 | Quarterly pen tests; bug bounty program; minimal PII collection principle |

---

## Release Milestones

*SRD §12.2*

| Milestone | Month | Gate Criteria |
|-----------|-------|---------------|
| **Alpha** | 1–2 | Internal team navigation works end-to-end in Lahore; 0 P0 bugs |
| **Beta** | 3–4 | 100 external beta users onboarded; crash-free rate ≥ 99%; all P0 features complete |
| **Pilot** | 5 | 1,000 users in Lahore; latency targets met; Play Store / App Store approved |
| **Public Launch** | 6 | Marketing campaign live; 10,000 target MAU; all Phase 1 features verified in field |
| **Phase 2 Complete** | 9 | IMU ML model ≥ 85% precision; SOS live; 50,000 MAU target |
| **Phase 3 Complete** | 12 | Caravan mode, voice commands, traffic prediction live |
| **Phase 4 Complete** | 15 | Monetization live; 100,000+ MAU; fleet API launched |

---

*Document generated from SRD v1.0 — March 22, 2026. Update this list as requirements evolve.*
