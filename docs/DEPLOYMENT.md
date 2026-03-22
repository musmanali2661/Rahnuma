# Rahnuma — Deployment Guide

## Prerequisites

- **Docker** 24+ and **Docker Compose** v2
- **4 CPU cores** minimum, 8 recommended
- **20 GB free disk** (OSM data + tiles)
- **8 GB RAM** minimum (osm2pgsql import requires up to 8 GB)

---

## Production Deployment

### 1. Server Setup

```bash
# Ubuntu 22.04 LTS
sudo apt update && sudo apt install -y docker.io docker-compose-v2 git wget

# Add current user to docker group
sudo usermod -aG docker $USER && newgrp docker
```

### 2. Clone & Configure

```bash
git clone https://github.com/musmanali2661/Rahnuma.git
cd Rahnuma
cp .env.example .env

# Edit .env with production values:
#   POSTGRES_PASSWORD=<strong_password>
#   JWT_SECRET=<64_char_random_string>
#   NODE_ENV=production
nano .env
```

### 3. Import OSM Data

```bash
# Download Pakistan extract (~1.5 GB) and import into PostGIS
./scripts/import_osm_data.sh
```

### 4. Preprocess OSRM Routing Data

```bash
# Takes 30-60 minutes on first run; results cached in data/osrm/
./scripts/start_osrm.sh
# Press Ctrl+C once preprocessing is done (server will start automatically via Docker Compose)
```

### 5. Generate Offline Packages

```bash
# Requires: osmium-tool, tippecanoe
./scripts/generate_offline_packages.sh
```

### 6. Start All Services

```bash
docker compose -f docker-compose.yml up -d
```

### 7. Verify

```bash
# API health check
curl http://localhost:4000/health

# Tile server
curl http://localhost:3000/

# OSRM
curl "http://localhost:5000/route/v1/car/73.0479,33.7215;74.3436,31.5497?overview=false"
```

---

## Nginx Configuration (HTTPS)

Install Certbot and obtain a certificate:

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d rahnuma.pk -d www.rahnuma.pk
```

---

## Updating OSM Data

The Pakistan OSM extract is updated weekly on Geofabrik. To refresh:

```bash
# Pull latest PBF
wget -c -O data/osm/pakistan-latest.osm.pbf \
  https://download.geofabrik.de/asia/pakistan-latest.osm.pbf

# Re-import
./scripts/import_osm_data.sh

# Reprocess OSRM (if roads changed significantly)
rm -rf data/osrm/
./scripts/start_osrm.sh
```

---

## Monitoring

```bash
# View all service logs
docker compose logs -f

# Individual service
docker compose logs -f backend
docker compose logs -f osrm
```

---

## Backup

```bash
# Backup PostgreSQL
docker compose exec postgres pg_dump -U rahnuma rahnuma | gzip > backup_$(date +%Y%m%d).sql.gz

# Restore
gunzip -c backup_20260301.sql.gz | docker compose exec -T postgres psql -U rahnuma rahnuma
```

---

## Scaling

For high-traffic deployments:
- Run multiple backend replicas behind Nginx upstream
- Add Redis Cluster for distributed caching
- Use a managed PostgreSQL service (e.g., Amazon RDS, Supabase)
- CDN (Cloudflare) for tile caching
