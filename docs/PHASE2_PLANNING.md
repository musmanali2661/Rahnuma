# Rahnuma — Phase 2 Planning

## Overview

Phase 2 builds upon the Phase 1 foundation to add advanced ML, community features, enhanced routing, and monetisation capabilities. Planned for **Months 4–8** post-launch.

---

## Phase 2.1 — Enhanced ML & Safety (Months 4–5)

### 2.1.1 Advanced IMU Classification
- Replace threshold-based classifier with LSTM/CNN model trained on labelled Pakistani road data
- Target: >90% precision on pothole/speed bump classification
- On-device TFLite model for offline inference
- Model update delivery via OTA without app store release

### 2.1.2 Real-Time Hazard Verification
- Computer vision verification using phone camera (optional, user-opt-in)
- Multi-user corroboration: event verified after ≥3 independent reports within 50m
- Confidence decay: events expire if not re-reported within 7 days

### 2.1.3 SOS & Emergency Features
- One-tap SOS with GPS coordinates sent to emergency contacts
- Auto-detection of accidents via sudden deceleration + gyroscope
- Integration with Rescue 1122 (Punjab) and Edhi Foundation numbers

### 2.1.4 Speed Camera Alerts
- Crowd-sourced speed camera database
- Fixed and mobile camera alerts
- Community voting to verify/remove stale entries

### 2.1.5 Vehicle Profiles
- Separate profiles for: car, motorcycle, rickshaw, truck, bus
- Custom routing penalties per profile (e.g., motorcycles avoid motorways)
- Weight/height restriction awareness for trucks

---

## Phase 2.2 — Community Features (Months 5–6)

### 2.2.1 User Profiles & Reputation
- Public profiles with contribution stats
- Karma system: earn points for verified reports
- Leaderboard by city

### 2.2.2 Report Verification Workflow
- Moderation queue for unverified reports
- Community voting: thumbs up/down on reports
- Trusted contributor badge for high-karma users

### 2.2.3 Media Uploads
- Photo/video evidence for hazard reports
- Automatic compression and storage (MinIO/S3)
- Privacy-preserving face/plate blurring

### 2.2.4 POI Reviews & Comments
- Star ratings for restaurants, petrol stations, hospitals
- Text reviews in Urdu and English
- Reply system for business owners

### 2.2.5 Caravan Mode
- Group travel with shared live location
- Leader–follower navigation
- Group waypoints and rest stop coordination

---

## Phase 2.3 — Advanced Routing (Months 6–7)

### 2.3.1 Multi-Modal Routing
- Car + walking combinations
- Rickshaw routes (separate graph, avoids highways)
- Intercity bus route integration (BRT, Daewoo, etc.)

### 2.3.2 Fuel Efficiency Routing
- Eco-mode: minimise fuel consumption vs. time
- Real petrol price integration (OGRA API)
- Per-vehicle fuel consumption model

### 2.3.3 Historical Traffic Patterns
- Collect anonymous speed data during navigation sessions
- Time-of-day traffic heat maps
- "Leave at time X for ETA Y" predictor

### 2.3.4 Predictive ETA with ML
- LSTM model trained on historical trip data
- Time-of-day, day-of-week, weather as features
- Confidence intervals on ETA

---

## Phase 2.4 — Monetisation & Scale (Months 7–8)

### 2.4.1 Business Listings API
- Verified business profiles
- Featured placement in search results
- Analytics dashboard for businesses

### 2.4.2 Premium Tier
- Unlimited offline maps (all of Pakistan)
- Ad-free experience
- Priority routing updates
- Advanced fuel efficiency tools

### 2.4.3 Fleet Management Dashboard
- Web dashboard for logistics companies
- Real-time tracking of multiple vehicles
- Route optimisation for deliveries
- Driver performance reports

### 2.4.4 Government & Enterprise Data API
- Anonymised, aggregated traffic data API
- Road condition heatmaps for NHA/provincial highways
- Toll revenue analytics for FWO/NLC
- Pricing: tiered subscription

---

## Technical Debt to Address in Phase 2

- [ ] Replace JWT with OAuth 2.0 / Auth0
- [ ] Migrate to ClickHouse for analytics telemetry
- [ ] Add end-to-end encryption for user location data
- [ ] Kubernetes deployment for auto-scaling
- [ ] Implement CDN (Cloudflare) for tile serving
- [ ] Add OpenTelemetry distributed tracing
- [ ] Write comprehensive API integration tests

---

## Success Metrics for Phase 2

| Metric | Phase 1 Target | Phase 2 Target |
|--------|---------------|---------------|
| IMU classification precision | 70% | 92% |
| Monthly active users | 10,000 | 100,000 |
| Verified road events | 5,000 | 100,000 |
| Offline package downloads | 10,000 | 200,000 |
| API response time (p95) | <500ms | <200ms |
