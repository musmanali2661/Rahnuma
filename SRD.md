# Rahnuma Navigation System - Software Requirements Document (SRD)

## Document Version: 1.0
## Date: March 22, 2026
## Status: Draft

---

## Table of Contents
1. [Introduction](#1-introduction)
2. [System Overview](#2-system-overview)
3. [Functional Requirements](#3-functional-requirements)
4. [Non-Functional Requirements](#4-non-functional-requirements)
5. [Technical Architecture](#5-technical-architecture)
6. [Data Requirements](#6-data-requirements)
7. [API Specifications](#7-api-specifications)
8. [UI/UX Requirements](#8-uiux-requirements)
9. [Security & Privacy](#9-security--privacy)
10. [Performance Metrics](#10-performance-metrics)
11. [Testing Requirements](#11-testing-requirements)
12. [Deployment Strategy](#12-deployment-strategy)
13. [Critical Feature Updates](#13-critical-feature-updates)
14. [Risk Assessment](#14-risk-assessment)
15. [Glossary](#15-glossary)

---

## 1. Introduction

### 1.1 Purpose
This Software Requirements Document (SRD) specifies the technical and functional requirements for **Rahnuma**, a comprehensive navigation system designed specifically for Pakistan. The system leverages OpenStreetMap data, AI-driven road condition detection via mobile IMU sensors, and culturally-adapted UX to provide superior navigation compared to global competitors.

### 1.2 Scope
Rahnuma encompasses:
- Web-based application (React) for desktop and mobile browsers
- Native mobile applications (Flutter) for Android and iOS
- Backend services including routing, geocoding, tile serving, and analytics
- Real-time road condition detection and reporting system
- Offline navigation capabilities for areas with limited connectivity

### 1.3 Target Users
| User Persona | Description | Key Needs |
|--------------|-------------|-----------|
| **Daily Commuter** | Urban professional in Karachi/Lahore/Islamabad | Traffic avoidance, time optimization, fuel efficiency |
| **Long-haul Driver** | Truck/bus driver on motorways and intercity routes | Rest stops, fuel availability, safety checkpoints |
| **Motorcycle Rider** | Two-wheeler commuter (massive demographic) | Pothole alerts, safe routes, weather protection |
| **Family Traveler** | Families traveling intercity or to northern areas | Safety, rest areas, family-friendly POIs |
| **Rural User** | Users in areas with poor infrastructure | Offline maps, unpaved road awareness, local landmarks |

---

## 2. System Overview

### 2.1 System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              CLIENT LAYER                                   │
├─────────────────────────────────┬───────────────────────────────────────────┤
│    React Web Application        │         Flutter Mobile App                │
│    - Desktop/Tablet Views       │    - IMU Sensor Integration              │
│    - PWA Capabilities           │    - Background Location                 │
│    - Offline Tile Cache         │    - Camera Integration (optional)       │
└─────────────────┬───────────────┴─────────────────┬─────────────────────────┘
                  │                                   │
                  ▼                                   ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           API GATEWAY (Kong/Traefik)                        │
│                    Rate Limiting | Auth | Request Routing                    │
└─────────────────────────────────────────────────────────────────────────────┘
                  │                                   │
                  ▼                                   ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         MICROSERVICES LAYER                                 │
├───────────────┬───────────────┬───────────────┬────────────────────────────┤
│  Routing      │  Geocoding    │  Tile Server  │  Sensor Processing         │
│  (OSRM)       │  (Pelias)     │  (Martin)     │  (Python/ML)               │
├───────────────┼───────────────┼───────────────┼────────────────────────────┤
│  POI Service  │  User Service │  Alert       │  Analytics                  │
│  (PostGIS)    │  (Auth0)      │  (WebSocket) │  (ClickHouse)               │
└───────────────┴───────────────┴───────────────┴────────────────────────────┘
                  │                                   │
                  ▼                                   ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           DATA LAYER                                        │
├─────────────────────────────┬───────────────────────────────────────────────┤
│  PostgreSQL + PostGIS       │  Redis Cluster                               │
│  - OSM Base Data            │  - Session Cache                             │
│  - User Reports             │  - Tile Cache                                │
│  - Road Conditions          │  - Rate Limiting                             │
│  - User Profiles            │                                               │
├─────────────────────────────┼───────────────────────────────────────────────┤
│  MinIO/S3                   │  ClickHouse                                  │
│  - Offline Packages         │  - Telemetry                                 │
│  - User Media               │  - Performance Metrics                       │
└─────────────────────────────┴───────────────────────────────────────────────┘
```

### 2.2 Core Value Proposition
Rahnuma differentiates through:
1. **IMU-based road surface detection** - Unique feature not present in Google Maps
2. **Cultural localization** - Urdu voice, local landmark recognition
3. **Offline-first architecture** - Critical for Pakistan's connectivity challenges
4. **Community-powered data** - Real-time hazard reporting specific to Pakistan context

---

## 3. Functional Requirements

### 3.1 Map Display & Interaction

| ID | Requirement | Priority | Description |
|----|-------------|----------|-------------|
| MAP-01 | Vector Tile Rendering | P0 | Render OSM vector tiles with custom styling for Pakistani context |
| MAP-02 | Zoom Levels | P0 | Support zoom levels 3-19 with appropriate detail levels |
| MAP-03 | Map Controls | P0 | Pan, zoom, rotate, tilt (where available) |
| MAP-04 | Satellite View | P2 | Optional satellite imagery (using open satellite sources) |
| MAP-05 | 3D Buildings | P3 | 3D building rendering for major cities |
| MAP-06 | Traffic Overlay | P0 | Real-time and historical traffic coloring on roads |

### 3.2 Navigation & Routing

| ID | Requirement | Priority | Description |
|----|-------------|----------|-------------|
| NAV-01 | Multi-Modal Routing | P0 | Car, motorcycle, bike, pedestrian, rickshaw modes |
| NAV-02 | Turn-by-Turn Guidance | P0 | Voice and visual turn instructions |
| NAV-03 | Route Alternatives | P0 | Provide 3 route options with different trade-offs |
| NAV-04 | Waypoints | P1 | Support for up to 10 intermediate stops |
| NAV-05 | Custom Avoidances | P1 | Avoid highways, tolls, ferries, unpaved roads |
| NAV-06 | Route Preview | P0 | Show elevation profile and key turns before start |
| NAV-07 | Live Rerouting | P0 | Automatic rerouting when user deviates or new hazards appear |
| NAV-08 | Toll Cost Display | P1 | Show M-Tag toll costs and payment methods |
| NAV-09 | Fuel Stop Suggestions | P1 | Suggest refueling stops on long routes |
| NAV-10 | Rest Area Alerts | P1 | Alert for upcoming rest areas on motorways |

### 3.3 Road Surface Detection (IMU-Based)

| ID | Requirement | Priority | Description |
|----|-------------|----------|-------------|
| RSD-01 | Accelerometer Collection | P0 | Sample accelerometer at 50-100Hz during navigation |
| RSD-02 | Gyroscope Collection | P0 | Sample gyroscope for vehicle orientation |
| RSD-03 | Event Classification | P0 | Classify: pothole, speed bump, rough road, construction |
| RSD-04 | Severity Scoring | P0 | Assign 1-5 severity based on sensor impact |
| RSD-05 | Location Correlation | P0 | Correlate events with GPS coordinates |
| RSD-06 | On-Device Filtering | P0 | Remove false positives using ML on device |
| RSD-07 | Batch Upload | P0 | Upload aggregated data when on WiFi |
| RSD-08 | Battery Optimization | P0 | Adaptive sampling rate based on speed and battery |
| RSD-09 | Visual Confirmation | P1 | Option to capture photo/video of hazard |
| RSD-10 | Confidence Scoring | P0 | Calculate confidence based on multiple reports |

### 3.4 Hazard & Alert System

| ID | Requirement | Priority | Description |
|----|-------------|----------|-------------|
| ALT-01 | Real-Time Alerts | P0 | Push alerts for hazards on current route |
| ALT-02 | Hazard Types | P0 | Accident, police checkpoint, road closure, flood, protest, pothole |
| ALT-03 | User Reporting | P0 | 3-tap reporting interface for common hazards |
| ALT-04 | Voice Reporting | P1 | "Hey Rahnuma, report accident ahead" |
| ALT-05 | Alert Radius | P0 | Alerts within 5km of current route |
| ALT-06 | Alert Expiration | P0 | Auto-expire after configurable time (accidents: 2hrs, potholes: 30 days) |
| ALT-07 | Verification System | P1 | Verified vs. unverified alert indicators |
| ALT-08 | Police Checkpost Data | P1 | Show permanent checkposts with timings |
| ALT-09 | Protest Zone Prediction | P2 | AI prediction based on historical protest patterns |

### 3.5 Points of Interest (POI)

| ID | Requirement | Priority | Description |
|----|-------------|----------|-------------|
| POI-01 | POI Categories | P0 | Petrol, mosque, hospital, restaurant, parking, ATM, police |
| POI-02 | Local Categories | P0 | Dhaba, tandoor, chai stall, CNG station, mechanic |
| POI-03 | Fuel Availability | P1 | Real-time fuel availability during shortages |
| POI-04 | Price Display | P1 | Current petrol/diesel/CNG prices |
| POI-05 | Hygiene Rating | P1 | User-submitted hygiene ratings for food places |
| POI-06 | EV Charging | P2 | EV charging station locations and availability |
| POI-07 | Reviews & Photos | P1 | User reviews and photos for POIs |
| POI-08 | Opening Hours | P0 | Prayer time adjustments for business hours |

### 3.6 Multilingual Support

| ID | Requirement | Priority | Description |
|----|-------------|----------|-------------|
| LNG-01 | Urdu UI | P0 | Complete UI in Urdu (Nastaliq font) |
| LNG-02 | English UI | P0 | Complete UI in English |
| LNG-03 | Roman Urdu Input | P0 | Search using Roman Urdu text |
| LNG-04 | Urdu Voice Navigation | P0 | Turn-by-turn in Urdu with professional voice |
| LNG-05 | Regional Languages | P2 | Punjabi, Sindhi, Pashto, Balochi voice options |
| LNG-06 | Toggle Language | P0 | One-tap language switch without restart |

### 3.7 Offline Capabilities

| ID | Requirement | Priority | Description |
|----|-------------|----------|-------------|
| OFF-01 | Map Downloads | P0 | Download maps by city, district, or custom region |
| OFF-02 | Offline Routing | P0 | Full routing capability without internet |
| OFF-03 | Offline POI Search | P0 | Search POIs in downloaded regions |
| OFF-04 | Smart Pre-Caching | P1 | Auto-download frequently visited areas |
| OFF-05 | Incremental Updates | P1 | Update only changed tiles instead of full redownload |
| OFF-06 | Storage Management | P0 | Show storage usage and allow selective deletion |
| OFF-07 | Background Download | P1 | Download maps in background with WiFi only option |

### 3.8 User & Social Features

| ID | Requirement | Priority | Description |
|----|-------------|----------|-------------|
| USR-01 | User Profiles | P0 | Email/phone registration, anonymous mode optional |
| USR-02 | Saved Places | P0 | Home, work, and custom saved locations |
| USR-03 | Trip History | P1 | History of past trips with stats |
| USR-04 | Favorites | P0 | Favorite routes and POIs |
| USR-05 | Community Reports | P0 | View reports from other users |
| USR-06 | Reputation System | P1 | User reputation based on report accuracy |
| USR-07 | Caravan Mode | P1 | Share live location with group/family |
| USR-08 | ETA Sharing | P1 | Share ETA with contacts via WhatsApp |

### 3.9 Safety & Security

| ID | Requirement | Priority | Description |
|----|-------------|----------|-------------|
| SAF-01 | SOS Button | P0 | One-tap emergency alert with location |
| SAF-02 | Emergency Contacts | P0 | Configure up to 5 emergency contacts |
| SAF-03 | Safe Route Mode | P1 | Prioritize well-lit, main roads for night travel |
| SAF-04 | Speed Limit Display | P1 | Show speed limits on roads (where data exists) |
| SAF-05 | Speed Camera Alerts | P1 | Alert for fixed speed cameras |
| SAF-06 | Curfew/Area Alerts | P1 | Alert when entering restricted or sensitive areas |
| SAF-07 | Location Sharing | P1 | Temporary location sharing with trusted contacts |

### 3.10 Vehicle-Specific Features

| ID | Requirement | Priority | Description |
|----|-------------|----------|-------------|
| VEH-01 | Vehicle Profiles | P1 | Save multiple vehicle profiles with dimensions |
| VEH-02 | Rickshaw Mode | P1 | Optimized for narrow lanes and rickshaw-accessible routes |
| VEH-03 | Height Restrictions | P1 | Alert for low bridges and height restrictions |
| VEH-04 | Weight Restrictions | P2 | Bridge weight limit warnings |
| VEH-05 | Fuel Efficiency Routing | P1 | Economy mode for fuel savings |

---

## 4. Non-Functional Requirements

### 4.1 Performance Requirements

| ID | Requirement | Target | Measurement |
|----|-------------|--------|-------------|
| PER-01 | Map Load Time | < 2 seconds | Time to first render |
| PER-02 | Route Calculation | < 3 seconds | From request to display |
| PER-03 | Search Response | < 1 second | Search autocomplete |
| PER-04 | App Startup | < 3 seconds | Cold start to interactive |
| PER-05 | Offline Route Calculation | < 5 seconds | For 200km route |
| PER-06 | IMU Processing Latency | < 100ms | Event detection to storage |
| PER-07 | API Response Time | < 200ms | 95th percentile |
| PER-08 | Frame Rate | 60 fps | Map panning/zooming |

### 4.2 Scalability Requirements

| ID | Requirement | Initial Target | Scale Target |
|----|-------------|----------------|--------------|
| SCL-01 | Concurrent Users | 10,000 | 500,000 |
| SCL-02 | Daily Active Users | 50,000 | 2,000,000 |
| SCL-03 | Monthly Active Users | 100,000 | 5,000,000 |
| SCL-04 | Daily Routes | 200,000 | 10,000,000 |
| SCL-05 | Daily Sensor Events | 5 million | 500 million |
| SCL-06 | Data Storage | 500 GB | 50 TB |

### 4.3 Availability Requirements

| ID | Requirement | Target |
|----|-------------|--------|
| AVL-01 | API Uptime | 99.9% (excluding planned maintenance) |
| AVL-02 | Tile Server Uptime | 99.5% |
| AVL-03 | Offline Functionality | 100% (independent of internet) |
| AVL-04 | Maintenance Window | Sundays 2-4 AM (announced 72 hours prior) |

### 4.4 Reliability Requirements

| ID | Requirement | Target |
|----|-------------|--------|
| REL-01 | Route Accuracy | > 99.5% of routes reachable |
| REL-02 | Turn Instruction Accuracy | > 99% correct instructions |
| REL-03 | Hazard Detection Accuracy | > 85% true positive rate |
| REL-04 | False Positive Rate | < 10% for hazard alerts |
| REL-05 | Crash Recovery | Auto-restart within 5 seconds |

### 4.5 Security Requirements

| ID | Requirement | Description |
|----|-------------|-------------|
| SEC-01 | Data Encryption | TLS 1.3 for all network communication |
| SEC-02 | Storage Encryption | AES-256 for stored user data |
| SEC-03 | Authentication | JWT with 24-hour expiration, refresh tokens |
| SEC-04 | API Rate Limiting | 100 requests/minute per user |
| SEC-05 | Input Validation | All user inputs sanitized |
| SEC-06 | Privacy by Design | Minimal data collection, user control over data |
| SEC-07 | GDPR/PPA Compliance | Comply with Pakistan Privacy Act and international standards |
| SEC-08 | Audit Logging | All access to sensitive data logged |

### 4.6 Usability Requirements

| ID | Requirement | Target |
|----|-------------|--------|
| USE-01 | Urdu Support | Complete UI localization |
| USE-02 | Accessibility | WCAG 2.1 AA compliance |
| USE-03 | Font Size | Configurable text size |
| USE-04 | Color Blind Mode | Support for protanopia/deuteranopia |
| USE-05 | Voice Commands | Support for Urdu voice commands |
| USE-06 | Learning Curve | 90% of users can complete navigation within first use |

---

## 5. Technical Architecture

### 5.1 Technology Stack

#### Frontend - Web (React)
| Component | Technology | Version | Purpose |
|-----------|------------|---------|---------|
| Framework | React | 18.3+ | UI framework |
| Map Library | MapLibre GL | 4.0+ | Vector map rendering |
| State Management | Zustand | 4.5+ | Global state |
| Routing | React Router | 6.20+ | Client-side routing |
| Styling | TailwindCSS | 3.4+ | Utility-first CSS |
| HTTP Client | TanStack Query | 5.0+ | Data fetching & caching |
| Form Handling | React Hook Form | 7.5+ | Form management |
| PWA | Vite PWA Plugin | 0.19+ | Offline support |

#### Frontend - Mobile (Flutter)
| Component | Technology | Version | Purpose |
|-----------|------------|---------|---------|
| Framework | Flutter | 3.22+ | Cross-platform UI |
| Map | flutter_map | 6.0+ | OSM map widget |
| Sensors | sensors_plus | 4.0+ | IMU data collection |
| Location | geolocator | 10.0+ | GPS services |
| Storage | sqflite | 2.3+ | Local database |
| Background | flutter_background_service | 5.0+ | Background tasks |
| State | Riverpod | 2.5+ | State management |
| Offline Tiles | flutter_map_mbtiles | 1.0+ | MBTiles support |

#### Backend Services
| Component | Technology | Version | Purpose |
|-----------|------------|---------|---------|
| API Gateway | Kong | 3.6+ | Request routing, rate limiting |
| Routing Engine | OSRM | 5.27+ | Route calculation |
| Geocoding | Pelias | 1.0+ | Search and geocoding |
| Tile Server | Martin | 0.12+ | Vector tile serving |
| Database | PostgreSQL | 16+ | Primary data store |
| GIS Extension | PostGIS | 3.4+ | Spatial queries |
| Cache | Redis | 7.2+ | Session & tile cache |
| ML Service | FastAPI | 0.115+ | Sensor data processing |
| Message Queue | RabbitMQ | 3.13+ | Async processing |
| Object Storage | MinIO | 2024+ | S3-compatible storage |
| Analytics | ClickHouse | 24.3+ | Telemetry data |

### 5.2 Data Flow Diagrams

#### Route Calculation Flow
```
User Request → API Gateway → OSRM Service → PostGIS (graph data) → OSRM (calculate)
                    ↓
              Redis Cache (check cached route)
                    ↓
              Response → Client → Render
```

#### Sensor Data Flow
```
Mobile IMU → On-device Filtering → Batch Queue → Upload on WiFi
                                                      ↓
                                              API Gateway
                                                      ↓
                                              ML Service (classification)
                                                      ↓
                                              PostGIS (store)
                                                      ↓
                                              Aggregation → ClickHouse
```

### 5.3 Database Schema

#### Core Tables

```sql
-- Users
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone VARCHAR(15) UNIQUE,
    email VARCHAR(255) UNIQUE,
    name VARCHAR(100),
    language VARCHAR(10) DEFAULT 'ur',
    created_at TIMESTAMP DEFAULT NOW(),
    last_active TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    reputation_score FLOAT DEFAULT 0.5
);

-- Vehicles
CREATE TABLE vehicles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    name VARCHAR(50),
    type VARCHAR(20), -- car, motorcycle, rickshaw, truck
    width_meters FLOAT,
    height_meters FLOAT,
    weight_kg FLOAT,
    fuel_type VARCHAR(20),
    is_default BOOLEAN DEFAULT false
);

-- Road Events (from IMU)
CREATE TABLE road_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    location GEOMETRY(Point, 4326),
    event_type VARCHAR(30), -- pothole, speed_bump, rough_road, construction
    severity INTEGER CHECK (severity BETWEEN 1 AND 5),
    confidence FLOAT CHECK (confidence BETWEEN 0 AND 1),
    user_id UUID REFERENCES users(id),
    sensor_summary JSONB, -- aggregated sensor data
    reported_at TIMESTAMP DEFAULT NOW(),
    verified_count INTEGER DEFAULT 1,
    verified_at TIMESTAMP,
    expires_at TIMESTAMP
);

-- User Reports
CREATE TABLE user_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    location GEOMETRY(Point, 4326),
    report_type VARCHAR(30), -- accident, police, flood, road_closed, protest
    description TEXT,
    severity VARCHAR(10), -- minor, moderate, severe
    media_urls TEXT[],
    user_id UUID REFERENCES users(id),
    status VARCHAR(20) DEFAULT 'pending', -- pending, verified, rejected, expired
    created_at TIMESTAMP DEFAULT NOW(),
    verified_at TIMESTAMP,
    verified_by UUID REFERENCES users(id)
);

-- POIs
CREATE TABLE pois (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    osm_id BIGINT,
    name VARCHAR(255),
    name_ur VARCHAR(255),
    category VARCHAR(50),
    subcategory VARCHAR(50),
    location GEOMETRY(Point, 4326),
    address JSONB,
    phone VARCHAR(20),
    opening_hours JSONB,
    rating_avg FLOAT DEFAULT 0,
    rating_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP
);

-- User Trips
CREATE TABLE trips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    start_location GEOMETRY(Point, 4326),
    end_location GEOMETRY(Point, 4326),
    distance_meters FLOAT,
    duration_seconds INTEGER,
    route_geometry JSONB,
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    vehicle_type VARCHAR(20)
);

-- Create Spatial Indexes
CREATE INDEX idx_road_events_location ON road_events USING GIST(location);
CREATE INDEX idx_user_reports_location ON user_reports USING GIST(location);
CREATE INDEX idx_pois_location ON pois USING GIST(location);
CREATE INDEX idx_pois_category ON pois(category);

-- Create Time-based Indexes
CREATE INDEX idx_road_events_reported_at ON road_events(reported_at);
CREATE INDEX idx_user_reports_created_at ON user_reports(created_at);
```

---

## 6. Data Requirements

### 6.1 OpenStreetMap Data Processing

| Dataset | Update Frequency | Processing Required |
|---------|------------------|---------------------|
| Pakistan OSM Extract | Weekly | Import to PostGIS, generate routing graph |
| Road Attributes | Weekly | Extract surface, lanes, speed limits, access |
| POIs | Weekly | Categorize and enrich with local knowledge |
| Administrative Boundaries | Monthly | District, tehsil, union council boundaries |

### 6.2 Custom Data Layers

| Layer | Source | Update Frequency |
|-------|--------|------------------|
| Road Conditions | IMU + User Reports | Real-time |
| Police Checkposts | User Reports + Official Data | Monthly |
| Fuel Prices | Web Scraping + User Reports | Daily |
| Prayer Times | API Integration | Annual (calendar) |
| Protest Zones | User Reports + News Monitoring | Real-time |
| Traffic Patterns | Historical Trip Data | Daily ML retraining |

### 6.3 Data Retention Policy

| Data Type | Retention Period | Notes |
|-----------|------------------|-------|
| Raw IMU Data | 7 days | Aggregated, then deleted |
| Aggregated Road Events | 90 days | High-confidence events may persist |
| User Trip History | 1 year | User can delete manually |
| User Reports | 30 days | Verified reports may persist |
| User Profiles | Until deletion | User can delete account |
| Telemetry Logs | 30 days | Aggregated for analytics |

---

## 7. API Specifications

### 7.1 API Design Principles
- RESTful architecture with JSON responses
- Versioned endpoints (`/api/v1/`)
- OpenAPI 3.0 specification
- JWT authentication for authenticated endpoints
- Rate limiting per API key/user

### 7.2 Core Endpoints

#### Routing
```
GET /api/v1/route
Parameters:
  - start: {lat, lng}
  - end: {lat, lng}
  - waypoints: [{lat, lng}] (optional)
  - profile: [car|motorcycle|rickshaw|pedestrian]
  - alternatives: boolean
  - avoid: [tolls|highways|unpaved]

Response:
{
  "routes": [{
    "id": "string",
    "distance": 12345,
    "duration": 1800,
    "geometry": "encoded polyline",
    "steps": [...],
    "summary": "string"
  }]
}
```

#### Road Events
```
GET /api/v1/events
Parameters:
  - bbox: [minLng, minLat, maxLng, maxLat]
  - types: [pothole|speed_bump|rough|construction]
  - radius: 1000 (meters)

POST /api/v1/events
Body:
{
  "location": {"lat": 31.5204, "lng": 74.3587},
  "event_type": "pothole",
  "severity": 3,
  "media": ["base64_image"] (optional)
}
```

#### Search
```
GET /api/v1/search
Parameters:
  - q: "Liberty Chowk"
  - lat: 31.5204 (for nearby bias)
  - lng: 74.3587
  - limit: 10

Response:
{
  "features": [{
    "type": "Feature",
    "geometry": {"type": "Point", "coordinates": [...]},
    "properties": {
      "name": "Liberty Chowk",
      "name_ur": "لبرٹی چوک",
      "category": "landmark",
      "confidence": 0.95
    }
  }]
}
```

### 7.3 WebSocket Endpoints

```
ws://api.rahnuma.com/v1/live
Purpose: Real-time updates for active navigation
Messages:
  - location_update: {"lat": 31.52, "lng": 74.35, "bearing": 90}
  - hazard_alert: {"type": "accident", "distance": 2500}
  - reroute: {"new_route": {...}}
```

---

## 8. UI/UX Requirements

### 8.1 Design System

#### Color Palette
```css
:root {
  --primary-green: #2E7D32;
  --primary-dark: #1B5E20;
  --primary-light: #4CAF50;
  --secondary-white: #FFFFFF;
  --accent-gold: #FFC107;
  --danger-red: #F44336;
  --warning-orange: #FF9800;
  --success-teal: #009688;
  --info-blue: #2196F3;
  --dark-gray: #424242;
  --light-gray: #F5F5F5;
}
```

#### Typography
```css
/* Urdu */
@font-face {
  font-family: 'Noto Nastaliq Urdu';
  src: url('/fonts/NotoNastaliqUrdu-Regular.woff2');
  font-display: swap;
}

/* English UI */
font-family: 'Inter', system-ui, -apple-system, sans-serif;
```

#### Component Library
- Custom components following Material Design 3 principles
- Touch targets minimum 44x44pt for mobile
- Responsive design for all screen sizes (320px - 3840px)

### 8.2 Screen Specifications

#### Main Map Screen
| Element | Description | Priority |
|---------|-------------|----------|
| Map View | Primary navigation view with custom styling | P0 |
| Search Bar | Top center, expandable, with voice input | P0 |
| Current Location Button | Bottom right, centers on user | P0 |
| Route Card | Bottom sheet when route active | P0 |
| POI Toggle | Filter visible POI categories | P1 |
| Zoom Controls | Optional, can use gestures | P1 |
| Alert Panel | Collapsible showing nearby hazards | P0 |

#### Navigation Mode
| Element | Description | Priority |
|---------|-------------|----------|
| Turn Card | Next turn with distance, street name in Urdu | P0 |
| Lane Guidance | Show lane recommendations | P1 |
| Speed Display | Current speed + speed limit | P1 |
| ETA | Time remaining, distance, arrival time | P0 |
| Next Turn Preview | Visual representation of next turn | P0 |
| Hazard Warnings | Popup alerts with audio | P0 |
| Mini Map | Overview of remaining route | P1 |

#### Search Screen
| Element | Description | Priority |
|---------|-------------|----------|
| Search Input | Autocomplete with Roman Urdu support | P0 |
| Categories | Quick category buttons (Petrol, Food, Mosque) | P0 |
| Recent Searches | Last 5 searches | P1 |
| Saved Places | Home, Work, Favorites | P0 |
| Voice Search | Microphone button for voice input | P1 |

### 8.3 Voice Navigation Script

#### Urdu Voice Prompts
```
"Seedha chalein" - Go straight
"Bayan hote hue dayen muraen" - Turn right after the intersection
"200 meter baad bayen muraen" - Turn left in 200 meters
"Aap apni manzil par pohanch gaye" - You have reached your destination
"Samnay speed breaker hai, raftar kam karein" - Speed breaker ahead, slow down
"Agla petrol pump 2 kilometer baad bayen taraf hai" - Next petrol pump 2km on left
"Aagay accident ki report hai, mutbadil rasta istemal karein" - Accident reported ahead, use alternate route
```

---

## 9. Security & Privacy

### 9.1 Authentication & Authorization
- JWT tokens with 24-hour expiration
- Refresh tokens with 30-day expiration
- OAuth2 support for Google/Apple sign-in
- Phone OTP for SMS-based authentication
- Role-based access control (user, moderator, admin)

### 9.2 Data Privacy
- Location data: Only collected during active navigation
- User controls: Ability to delete all location history
- Anonymization: Reports aggregated before public display
- Data residency: All data stored on servers within Pakistan
- Third-party sharing: Never sell user data

### 9.3 Security Measures
- API rate limiting: 100 requests/minute per IP
- DDoS protection: Cloudflare or similar CDN
- SQL injection prevention: Parameterized queries
- XSS prevention: Content Security Policy headers
- CORS: Restricted to allowed domains
- Regular security audits: Quarterly penetration testing

---

## 10. Performance Metrics

### 10.1 Key Performance Indicators (KPIs)

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| Monthly Active Users | 100,000 (Year 1) | Analytics |
| User Retention (30-day) | 40% | Cohort analysis |
| Average Session Duration | 15 minutes | Analytics |
| Routes per User per Week | 5 | Analytics |
| User Reports per Day | 1,000 | Database count |
| IMU Events per Day | 500,000 | Database count |
| Route Calculation Success Rate | 99.5% | Server logs |
| Crash-free Session Rate | 99.9% | Crash reporting |
| App Store Rating | 4.5+ | App stores |

### 10.2 Monitoring & Alerting
- Prometheus for metrics collection
- Grafana for dashboards
- AlertManager for alerting
- Sentry for error tracking
- Custom alerts:
  - API error rate > 1% for 5 minutes
  - Tile server latency > 500ms
  - OSRM service down
  - Database connection pool > 80%

---

## 11. Testing Requirements

### 11.1 Testing Strategy

| Testing Type | Coverage | Tools |
|--------------|----------|-------|
| Unit Tests | 80% | Jest (React), Flutter Test |
| Integration Tests | 70% | React Testing Library, Flutter Integration Test |
| E2E Tests | Critical paths | Playwright, Appium |
| Performance Tests | All APIs | k6, Locust |
| Security Tests | All endpoints | OWASP ZAP |
| Usability Tests | All features | User testing sessions |

### 11.2 Test Environments
- **Development**: Local environment for developers
- **Staging**: Production-like environment for QA
- **Production**: Live environment with monitoring

### 11.3 Field Testing
- 100 beta users in Karachi, Lahore, Islamabad
- 50 beta users in rural areas (Sindh, Punjab, KP)
- 50 beta users on motorways (M-1, M-2, M-3)

---

## 12. Deployment Strategy

### 12.1 Infrastructure
- Cloud Provider: DigitalOcean or AWS (Pakistan region)
- Containerization: Docker
- Orchestration: Kubernetes (k3s for initial)
- CI/CD: GitHub Actions
- Infrastructure as Code: Terraform

### 12.2 Release Schedule
| Phase | Duration | Activities |
|-------|----------|------------|
| Alpha | Month 1-2 | Internal testing, core features |
| Beta | Month 3-4 | Limited user testing, feedback collection |
| Pilot | Month 5 | 1,000 users in Lahore |
| Launch | Month 6 | Public release, marketing campaign |
| Post-Launch | Month 7+ | Feature additions, scaling |

---

## 13. Critical Feature Updates

### 13.1 Phase 1: Core Navigation (Months 1-3)

| Feature | Description | Status |
|---------|-------------|--------|
| Basic Map Display | OSM vector tiles with custom styling | Required |
| Search | Roman Urdu + English search | Required |
| Routing | OSRM with car profile | Required |
| Turn-by-Turn | Voice guidance in Urdu | Required |
| Offline Maps | City-level downloads | Required |
| IMU Detection | Pothole detection prototype | Required |

### 13.2 Phase 2: Community & Safety (Months 4-6)

| Feature | Description | Status |
|---------|-------------|--------|
| User Reports | Hazard reporting interface | Required |
| SOS Feature | Emergency alert system | Required |
| Vehicle Profiles | Car, motorcycle, rickshaw modes | Required |
| Fuel Price Display | Real-time petrol/diesel prices | Required |
| Speed Camera Alerts | Fixed camera locations | Required |
| IMU ML Model | Production-ready classification | Required |

### 13.3 Phase 3: Advanced Features (Months 7-9)

| Feature | Description | Status |
|---------|-------------|--------|
| Caravan Mode | Group travel coordination | Planned |
| EV Charging | EV station locator | Planned |
| Toll Integration | M-Tag balance and toll costs | Planned |
| Traffic Prediction | ML-based traffic forecasting | Planned |
| AR Navigation | Augmented reality overlay | Planned |
| Voice Commands | "Hey Rahnuma" voice control | Planned |

### 13.4 Phase 4: Monetization & Scale (Months 10-12)

| Feature | Description | Status |
|---------|-------------|--------|
| Business Listings | Premium POI listings | Planned |
| Fleet Management | API for logistics companies | Planned |
| Ad Platform | Contextual advertising | Planned |
| Data API | Road condition data for government | Planned |

### 13.5 Critical Differentiators (Unique to Rahnuma)

| Feature | Why Critical |
|---------|--------------|
| **IMU Road Surface Detection** | Google Maps lacks this; creates unique value proposition |
| **Offline-First Architecture** | Pakistan has connectivity gaps; essential for rural users |
| **Urdu Voice with Local Phrases** | Builds trust; competitors have poor Urdu support |
| **Police Checkpost Alerts** | Safety concern unique to Pakistan context |
| **Fuel Shortage Mode** | Regular fuel crises in Pakistan require this feature |
| **Protest Zone Prediction** | Political gatherings cause major disruptions |
| **Rickshaw Mode** | Major transportation mode ignored by competitors |
| **Wedding Season Routing** | Cultural event that blocks roads in predictable patterns |

---

## 14. Risk Assessment

### 14.1 Technical Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| OSM data quality gaps | Medium | High | Community mapping drives, manual verification |
| IMU battery drain | Medium | Medium | Adaptive sampling, user controls |
| Offline storage limitations | Medium | Medium | Smart tile selection, compression |
| API cost scaling | Low | High | Self-hosted OSRM/Nominatim, CDN optimization |
| Android fragmentation | High | Medium | Extensive device testing, sensor fallbacks |

### 14.2 Business Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Google Maps improvement | Medium | High | Focus on Pakistan-specific features they ignore |
| User adoption | Medium | High | Strong community engagement, referral program |
| Data accuracy concerns | Medium | Medium | Reputation system, moderation |
| Regulatory issues | Low | High | Consult legal, comply with privacy laws |

### 14.3 Operational Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Server downtime | Low | High | Multi-region deployment, auto-scaling |
| Security breach | Low | Critical | Regular audits, encryption, minimal data |
| Team turnover | Medium | Medium | Documentation, knowledge sharing |

---

## 15. Glossary

| Term | Definition |
|------|------------|
| **IMU** | Inertial Measurement Unit - accelerometer + gyroscope |
| **OSM** | OpenStreetMap - open-source map data |
| **OSRM** | Open Source Routing Machine - routing engine |
| **PostGIS** | Spatial database extension for PostgreSQL |
| **MVT** | Mapbox Vector Tiles - vector tile format |
| **MBTiles** | SQLite-based tile storage format |
| **ETA** | Estimated Time of Arrival |
| **POI** | Point of Interest |
| **PWA** | Progressive Web App |
| **JWT** | JSON Web Token |
| **CORS** | Cross-Origin Resource Sharing |
| **WCAG** | Web Content Accessibility Guidelines |

---

## Document Approval

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Product Owner | TBD | | |
| Technical Lead | TBD | | |
| QA Lead | TBD | | |
| Security Lead | TBD | | |

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 0.1 | March 15, 2026 | System Architect | Initial draft |
| 0.5 | March 18, 2026 | System Architect | Added API specs, UI requirements |
| 1.0 | March 22, 2026 | System Architect | Complete SRD with all sections |

---

*This document is confidential and proprietary. Unauthorized distribution is prohibited.*
