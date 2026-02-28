#!/bin/bash
set -e

echo "Downloading NYC tutorial data..."
curl -sL -o /tmp/nyc_data.zip \
  "https://github.com/giswqs/postgis/raw/master/data/nyc_data.zip"

echo "Extracting..."
mkdir -p /tmp/nyc_data
unzip -q /tmp/nyc_data.zip -d /tmp/nyc_data

cd /tmp/nyc_data

echo "Loading shapefiles into PostGIS (SRID 26918)..."

for shp in \
  nyc_census_blocks \
  nyc_neighborhoods \
  nyc_streets \
  nyc_subway_stations \
  nyc_homicides
do
  if [ -f "${shp}.shp" ]; then
    echo "  Loading ${shp}..."
    shp2pgsql -s 26918 -I "${shp}.shp" "public.${shp}" \
      | psql -U "$POSTGRES_USER" "$POSTGRES_DB"
  else
    echo "  Skipping ${shp} (file not found)"
  fi
done

echo "NYC data loaded successfully."
rm -rf /tmp/nyc_data /tmp/nyc_data.zip
