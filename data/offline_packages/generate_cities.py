#!/usr/bin/env python3
"""
Generate city-level MBTiles offline packages for Rahnuma.
Uses tilemill / tippecanoe + osmium toolchain.

Usage:
    python3 generate_cities.py [--city karachi] [--zoom-min 10] [--zoom-max 16]
"""

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent
CITIES_FILE = SCRIPT_DIR / 'cities.json'
OSM_PBF = SCRIPT_DIR.parent / 'osm' / 'pakistan-latest.osm.pbf'
OUTPUT_DIR = SCRIPT_DIR

def load_cities():
    with open(CITIES_FILE) as f:
        return json.load(f)

def run(cmd, **kwargs):
    print(f'$ {" ".join(cmd)}')
    result = subprocess.run(cmd, check=True, **kwargs)
    return result

def extract_city(city, pbf_path, output_pbf):
    """Extract a city bounding box from the Pakistan PBF using osmium."""
    bbox = city['bbox']
    run([
        'osmium', 'extract',
        '--bbox', f'{bbox[0]},{bbox[1]},{bbox[2]},{bbox[3]}',
        '--strategy', 'complete-ways',
        str(pbf_path),
        '-o', str(output_pbf),
        '--overwrite',
    ])

def generate_mbtiles(city, pbf_path, output_mbtiles, zoom_min, zoom_max):
    """Convert city PBF to MBTiles using tippecanoe + osm2geojson."""
    geojson_path = output_mbtiles.with_suffix('.geojson')

    # Convert OSM PBF to GeoJSON (roads + POIs)
    run([
        'osmium', 'export',
        str(pbf_path),
        '--geometry-types=linestring,point',
        '-o', str(geojson_path),
        '--overwrite',
    ])

    # Generate vector tiles
    run([
        'tippecanoe',
        '-o', str(output_mbtiles),
        '--minimum-zoom', str(zoom_min),
        '--maximum-zoom', str(zoom_max),
        '--name', city['name'],
        '--description', f'Rahnuma offline tiles for {city["name"]}',
        '--force',
        str(geojson_path),
    ])

    # Clean up temporary GeoJSON
    geojson_path.unlink(missing_ok=True)

def main():
    parser = argparse.ArgumentParser(description='Generate Rahnuma city MBTiles packages')
    parser.add_argument('--city', help='City ID to generate (default: all)')
    parser.add_argument('--zoom-min', type=int, default=10)
    parser.add_argument('--zoom-max', type=int, default=16)
    args = parser.parse_args()

    if not OSM_PBF.exists():
        print(f'ERROR: OSM PBF not found at {OSM_PBF}')
        print('Run: ./scripts/import_osm_data.sh first')
        sys.exit(1)

    cities = load_cities()
    if args.city:
        cities = [c for c in cities if c['id'] == args.city]
        if not cities:
            print(f'ERROR: City "{args.city}" not found in cities.json')
            sys.exit(1)

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    for city in cities:
        print(f'\n=== Generating tiles for {city["name"]} ===')
        city_pbf = OUTPUT_DIR / f'{city["id"]}.osm.pbf'
        city_mbtiles = OUTPUT_DIR / f'{city["id"]}.mbtiles'

        zoom_min = city.get('zoom_min', args.zoom_min)
        zoom_max = city.get('zoom_max', args.zoom_max)

        try:
            extract_city(city, OSM_PBF, city_pbf)
            generate_mbtiles(city, city_pbf, city_mbtiles, zoom_min, zoom_max)
            city_pbf.unlink(missing_ok=True)
            print(f'✓ {city["name"]}: {city_mbtiles}')
        except subprocess.CalledProcessError as e:
            print(f'✗ {city["name"]}: {e}')

if __name__ == '__main__':
    main()
