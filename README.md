# postgis-ldproxy

A Docker Compose demo stack that serves NYC spatial data from PostGIS as a standards-compliant OGC API Features service via [ldproxy](https://github.com/interactive-instruments/ldproxy).

## Stack

| Component | Version | Role |
|-----------|---------|------|
| PostgreSQL + PostGIS | 17 + 3.5 | Spatial database |
| ldproxy | 4.6.1 | OGC API Features server |

## Datasets

Five NYC layers loaded from the [PostGIS Workbook](https://postgis.gishub.org/) by Qiusheng Wu:

| Collection | Geometry | Records | Description |
|------------|----------|---------|-------------|
| `nyc_neighborhoods` | MultiPolygon | 129 | Named neighborhood boundaries |
| `nyc_census_blocks` | MultiPolygon | 36,592 | Census blocks with population breakdown by race |
| `nyc_streets` | MultiLineString | 19,091 | Street centerlines with type and direction |
| `nyc_subway_stations` | Point | 491 | Subway stations with routes and express/local info |
| `nyc_homicides` | Point | 3,982 | Homicide incidents 2003–2011 with weapon and date |

## Getting started

**Prerequisites:** Docker with Compose

```bash
git clone https://github.com/jeroenvanderzwam/postgis-ldproxy.git
cd postgis-ldproxy
docker compose up -d
```

On first start, PostGIS downloads and loads the NYC shapefiles automatically (~1–2 minutes). ldproxy waits for the database to be healthy before starting.

Once running, open: **http://localhost:7080/nyc**

## API endpoints

| Endpoint | Description |
|----------|-------------|
| `GET /nyc` | Landing page |
| `GET /nyc/conformance` | Supported OGC conformance classes |
| `GET /nyc/api` | OpenAPI definition |
| `GET /nyc/collections` | All collections |
| `GET /nyc/collections/{id}/items` | Features |
| `GET /nyc/collections/{id}/items/{fid}` | Single feature |
| `GET /nyc/collections/{id}/schema` | Property schema |
| `GET /nyc/collections/{id}/queryables` | Filterable properties |

## Features

### CQL2 filtering (`filter-lang=cql2-text`)

Attribute filters:
```
/nyc_neighborhoods/items?filter=boroname='Brooklyn'&filter-lang=cql2-text
/nyc_homicides/items?filter=weapon='gun' AND year=2009&filter-lang=cql2-text
/nyc_subway_stations/items?filter=routes LIKE '%A%'&filter-lang=cql2-text
```

Spatial filters:
```
/nyc_subway_stations/items?filter=S_INTERSECTS(geometry,BBOX(-74.00,40.74,-73.97,40.77))&filter-lang=cql2-text
/nyc_neighborhoods/items?filter=S_INTERSECTS(geometry,POLYGON((-73.98 40.76,-73.95 40.76,-73.95 40.80,-73.98 40.80,-73.98 40.76)))&filter-lang=cql2-text
```

Combined:
```
/nyc_homicides/items?filter=weapon='gun' AND S_INTERSECTS(geometry,BBOX(-74.02,40.70,-73.91,40.88))&filter-lang=cql2-text
```

### Property selection

Return only specific fields:
```
/nyc_neighborhoods/items?properties=name,boroname
/nyc_subway_stations/items?properties=name,routes,borough
```

### Coordinate reference systems

```
/nyc_neighborhoods/items?crs=http://www.opengis.net/def/crs/OGC/1.3/CRS84       # WGS84 (default)
/nyc_neighborhoods/items?crs=http://www.opengis.net/def/crs/EPSG/0/3857         # Web Mercator
/nyc_neighborhoods/items?crs=http://www.opengis.net/def/crs/EPSG/0/26918        # UTM Zone 18N (native)
```

## HTTP query files

The `http/` directory contains [REST Client](https://marketplace.visualstudio.com/items?itemName=humao.rest-client) files for VS Code:

| File | Contents |
|------|----------|
| `01_service.http` | Landing page, conformance, collections |
| `02_features.http` | Pagination, single features, CRS variants |
| `03_projections.http` | Schema, queryables, property selection |
| `04_cql2_attribute.http` | Attribute and temporal filters |
| `05_cql2_spatial.http` | BBOX, polygon, and combined filters |

## Useful commands

```bash
# Restart ldproxy after config changes
docker compose restart ldproxy

# Check ldproxy logs
docker logs postgis-ldproxy-ldproxy-1 --tail 50

# Query PostGIS directly
docker exec postgis-ldproxy-postgis-1 psql -U postgres -d nyc -c "\dt"

# Rebuild from scratch (re-downloads data)
docker compose down -v && docker compose up -d
```
