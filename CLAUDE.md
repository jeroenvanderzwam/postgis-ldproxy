# postgis-ldproxy

## Purpose
Development/demo environment serving NYC PostGIS spatial data as OGC API Features via ldproxy v4.6.1. Used for learning and testing OGC API / ldproxy with PostGIS Tutorial data.

## Tech Stack
- **PostGIS**: PostgreSQL 17 + PostGIS 3.5 (custom Dockerfile: [postgis/Dockerfile](postgis/Dockerfile))
- **ldproxy**: v4.6.1 OGC Web API server (`iide/ldproxy:latest`)
- **Data**: 5 NYC shapefile layers loaded via `shp2pgsql` (SRID 26918 / UTM Zone 18N)
- **Orchestration**: Docker Compose

## Key Directories
| Path | Purpose |
|------|---------|
| `postgis/` | Custom PostGIS image (adds `curl`, `unzip`, `postgis` CLI tools) |
| `initdb/` | DB init scripts — run once in alphabetical order by PostgreSQL |
| `ldproxy/` | Mounted as `/ldproxy/data` in container |
| `ldproxy/cfg.yml` | ldproxy app config (store sources, logging) |
| `ldproxy/store/entities/providers/nyc.yml` | Feature provider config (base) |
| `ldproxy/store/entities/services/nyc.yml` | OGC API service config (base) |
| `ldproxy/store/entities/instances/providers/nyc.yml` | Provider config overrides |
| `ldproxy/store/entities/instances/services/nyc.yml` | Service config overrides (active) |

## Essential Commands
```bash
# Start everything
docker compose up -d

# Restart ldproxy after config changes (no rebuild needed)
docker compose restart ldproxy

# Rebuild PostGIS image (after Dockerfile changes)
docker compose down -v && docker compose build postgis && docker compose up -d

# Check logs
docker logs postgis-ldproxy-ldproxy-1 --tail 50

# Verify data in PostGIS
docker exec postgis-ldproxy-postgis-1 psql -U postgres -d nyc -c "\dt"
```

## Service Endpoints
- Landing page: `http://localhost:7080/nyc`
- Collections: `http://localhost:7080/nyc/collections`
- Features: `http://localhost:7080/nyc/collections/{id}/items`

## Additional Documentation
- [.claude/docs/architectural_patterns.md](.claude/docs/architectural_patterns.md) — ldproxy config patterns, known issues, entity file structure
- [.claude/docs/ldproxy_config.md](.claude/docs/ldproxy_config.md) — ldproxy config structure: two-layer system, provider types, service building blocks
- [.claude/docs/findings.md](.claude/docs/findings.md) — key findings from debugging: geometry setup, sortKey requirement, instances/ activation

## PostGIS Learning Resources
Two separate resources — our data comes from the **workbook**:

- [PostGIS Workbook](https://postgis.gishub.org/chapters/postgis_intro.html) — "Spatial Data Management with PostgreSQL and PostGIS" by Qiusheng Wu. **Our data source** (`nyc_data.zip` from `github.com/giswqs/postgis`), includes `nyc_homicides`.
- [PostGIS Workshop](https://postgis.net/workshops/postgis-intro/) — official PostGIS workshop (different dataset: has `nyc_census_sociodata` instead of `nyc_homicides`)

## ldproxy Documentation
- [ldproxy Docs](https://docs.ldproxy.net/) — official documentation site
- [SQL/PostGIS Provider](https://docs.ldproxy.net/providers/feature/10-sql) — PostGIS connection config (`dialect: PGIS`, `connectionInfo`, etc.)
- [ldproxy GitHub](https://github.com/interactive-instruments/ldproxy) — source code, issues, releases
- [OGC API Features spec](https://ogcapi.ogc.org/features/) — underlying OGC standard

### Example Configurations (Vineyards demo)
- [Provider example](https://github.com/interactive-instruments/ldproxy/blob/master/demo/vineyards/store/entities/providers/vineyards.yml) — SQL provider with explicit geometry (`role: PRIMARY_GEOMETRY`)
- [Service example](https://github.com/interactive-instruments/ldproxy/blob/master/demo/vineyards/store/entities/services/vineyards.yml) — OGC API service with building blocks
