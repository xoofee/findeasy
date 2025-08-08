Nice brief — great product idea. I’ll act like your CTO/architect and give a **practical progressive plan** you can actually implement with one engineer at start and grow into a medium-sized org by year 2–3. I’ll cover:

* recommended **architecture** and how it should **evolve** across three phases (MVP / Scale / Growth)
* technology choices (cost-sensitive, pragmatic) and **why**
* **security** for your core asset (.osm.gz map blobs) and anti-MITM considerations
* map storage / caching formats & conversion notes (DWG → indoor map)
* DevOps / CI/CD & when to introduce Docker / K8s / IaC / monitoring
* data & infra components (DB, queues, object store, ASR)
* **folder structures** for backend monorepo and the Flutter `findeasy` app (detailed)
* concrete migration roadmap and short example CI job templates you can start with

I’ll keep trade-offs and cost consequences explicit so you can pick what fits your tight budget.

---

# High level approach (progressive / “do the simplest thing that works”)

We define **three phases**:

* **Phase 0 — MVP (0–6 months)**

  * **Goal:** get a working product in 10 places, one engineer. Fast, cheap, minimal ops.
  * **Approach:** *monolith / modular monolith* or small set of co-located services, run on a single VPS or 1–2 small VMs, minimal infra. No K8s. Use managed DB & object store where it reduces ops. Use simple Docker Compose deployments.
* **Phase 1 — Scale (6–24 months)**

  * **Goal:** support \~1,000 places (thousands of parking spots). Team grows to several engineers. Need reliability, deployments, and some automation.
  * **Approach:** containerize everything, split into logical services (auth, map-service, place-service, ingestion, processors), introduce CI/CD, background workers, SQS/RabbitMQ/Redis streams. Start using managed services for Postgres, object storage, and K/V cache (Redis). Consider managed k8s (small cluster) near the end of Phase 1. Add observability (logs + basic metrics).
* **Phase 2 — Growth (24–36 months)**

  * **Goal:** global scale to \~100k places, many users. Need autoscaling, multi-region, strict security, professional DevOps.
  * **Approach:** full microservices (or well-orchestrated modular services), managed Kubernetes (GKE/EKS/AKS or cloud provider equivalent), Terraform, CI/CD pipelines with blue/green or canary deployments, Prometheus/Grafana/ELK or managed equivalents, WAF, KMS, IAM, rate limiting, multi-region object store and DB replicas, CDN for map blobs.

---

# Which components to change over time (summary)

* **Architecture**: Start as modular monolith → split to services when team grows / performance requires it.
* **Deployment**: Start with Docker Compose / direct VM deploy → containerized CI/CD with images → managed Kubernetes when you need autoscaling, multi-service orchestration.
* **Database**: Postgres + PostGIS from day 1. Scale read replicas and partitioning later. Add search index (Elasticsearch / OpenSearch) when text search & analytics need speed.
* **Object storage**: S3/compatible from day 1 for map blobs. Use signed URLs + encryption and controlled key distribution.
* **DevOps**: manual deploys → GitHub Actions CI + small CD to VM → formal CI/CD + infra as code (Terraform) → production-grade pipelines with automated testing + staging + canary.
* **Monitoring**: Sentry + basic metrics (Cloud provider) early → Prometheus/Grafana + centralized log pipeline later.
* **Security**: TLS everywhere from day 1; add envelope encryption + KMS & device-bound keys when protecting map blobs becomes critical.

---

# Technology stack (cost-aware & pragmatic)

**Backend language / framework (MVP)**

* **Fast pick:** **FastAPI (Python)** — low startup cost, developer friendly, many geospatial libs available. (You already referenced FastAPI previously.)
* Alternate: Node.js + NestJS if your engineer prefers JS/TS.

**Database**

* **Primary:** **Postgres + PostGIS** — spatial queries, indexing, geo-index on places and POIs. Mature, cheap, and scales well. Start with a managed Postgres (Heroku, AWS RDS, DigitalOcean Managed DB) or a single self-hosted instance initially.
* **Later (search / analytics):** **OpenSearch / Elasticsearch** for text search & analytics.

**Object Storage**

* **S3-compatible** (AWS S3, DigitalOcean Spaces, Wasabi) — store .osm.gz map caches, DWG uploads, processed tiles. Use lifecycle rules and cheaper tiers for older maps.

**Cache / Queue**

* **Redis** for caching, session store, pub/sub.
* **RabbitMQ** or **Redis Streams** for background jobs (map processing pipelines).

**Map processing & format**

* Start with gzipped **.osm** (.osm.gz). Later consider **MBTiles** / protobuf vector tiles for efficiency. Use **GDAL/OGR**, **OSM toolchain**, and a conversion pipeline (DWG → DXF → GeoJSON → OSM tags). (DWG conversion is handled separately below.)

**Authentication / Identity**

* OAuth2 + JWT for API tokens. Single sign-on later with Google / WeChat (use their SDKs and short-lived tokens). Allow anonymous usage offline; gate key operations (map download decryption key) behind a device token.

**ASR/TTS**

* MVP: rely on device offline TTS + third-party cloud ASR (Google Speech-to-Text or open-source Kaldi speech model) as an option. Offer offline lightweight ASR for some languages later. Start with a cloud provider for performance & low immediate cost.

**Mobile app**

* **Flutter** (you already are building Flutter) — a single codebase for all platforms. Use platform channels for native key storage and sensors.

**Analytics**

* Start with simple self-hosted analytics events stored in Postgres or a lightweight event-collector (pipelined to BigQuery / ClickHouse later). You can use Mixpanel/Amplitude if budget allows.

**DevOps / Infra**

* MVP: VPS (Hetzner/DigitalOcean) with docker-compose, managed Postgres & S3. GitHub Actions for CI.
* Scale: container registry + kubernetes (managed) + Terraform + ingress + autoscaling. Use CloudFlare CDN for static assets and API WAF later.

---

# Important architecture design principles (apply from day 0)

1. **Modular boundaries**: design auth, map ingestion, place management, mobile download API, and processing workflows as separate modules even if they run in one process. This makes future split easier.
2. **APIs first**: design clear REST/GraphQL APIs and stable contract for map downloads & decryption — the mobile app depends on this.
3. **Immutable artifacts**: produce map artifacts (.osm.gz, vector tiles, MBTiles) and treat them as immutable releases per `place:version`. This makes rollbacks simple.
4. **Idempotent processors**: map ingestion / conversion pipelines must be idempotent and resumable.
5. **Provenance & audit**: store uploader, version, timestamp and change logs for each place.
6. **Device binding for sensitive assets**: tie downloaded map keys to device ID or user token where possible (see security).

---

# Map storage, download & encryption (protecting .osm.gz from MITM and leaks)

You said: “Prevent bad guy use tools like mitmproxy to get our raw map data (.osm.gz). The map is core asset.”

Reality check: **If the client (mobile) can decrypt a map, a sufficiently motivated attacker who controls the device can extract it.** You can make extraction harder and deter mass leakage with the following layered approach (cost-sensitive):

**Minimum (MVP) — low cost, moderate protection**

* Serve map blobs from **S3** via **HTTPS** + **signed short-lived URLs** (e.g., expire in 5–15 minutes). This prevents unauthenticated bulk scraping.
* **Encrypt at rest** on S3 (server-side encryption is fine). Client receives file over TLS. Use short expiration signed URLs, but signed URL alone doesn't prevent someone using mitmproxy on the device. Acceptable early-stage trade-off.

**Better (Phase 1) — stronger protection without enormous cost**

* **Envelope encryption**:

  * For each map file generate a random **data key (AES-256)**. Encrypt file with this data key, store encrypted blob in S3.
  * Encrypt the data key with a **master KMS key** (e.g., AWS KMS) to store alongside metadata.
  * When the app requests a map, backend verifies device/user and returns the **data key** over an **authenticated** TLS API call (backend decrypts via KMS). The app then decrypts the blob locally.
  * Short-lived data keys: server returns the data key with limited validity and only to devices authorized for that place.
* **Device binding**: require the app to present a device fingerprint or device token (Android Keystore / iOS Keychain) to receive the data key. This increases complexity but reduces casual leaking.

**Best-effort (Phase 2) — strong anti-mass-leak measures**

* Use **hardware-backed keys** on device (Android Keystore / iOS Secure Enclave) so plaintext keys never leave secure hardware.
* Provide map file in **encrypted and compressed tile format** (cut maps into small chunks) and deliver only required chunks per session, reducing stolen bulk data attractiveness.
* Monitor download patterns and rate-limit or blacklist suspicious devices/IPs.

**Anti-MITM specifics**

* TLS everywhere. Pin TLS certs for mobile app (certificate pinning) to protect against device-level MITM (but remember pinning can cause ops overhead on cert rotations). Use **public key pinning** with careful rotation plan.
* Authenticate app requests using an app token + device ID + proof (HMAC of timestamp) to prevent simple replay. Rotate tokens periodically.

**Practical recommendation for your tight budget**

* Start with signed HTTPS S3 URLs + server-side encryption + short expiry. Use envelope encryption when you can afford KMS and a per-file key management flow (Phase 1). Implement device key binding only when you start seeing mass map theft attempts.

---

# Map formats & caching strategy

**Start (MVP)**

* **.osm.gz** (gzipped OSM XML) per place version. Pros: human readable, easy to generate from OSM-like pipeline, compatible with `easyroute`.
* Cache on S3 and provide a metadata API: `GET /places/{id}/metadata` returns version, size, hash, URL for download.

**Problems & future evolution**

* **.osm.gz** large for mobile. Later switch to:

  * **MBTiles (vector tiles)** or **protobuf PBF** to shrink footprint & speed parsing. MBTiles is popular for tile-based rendering; vector tiles make rendering faster.
  * Or a **custom binary format** tuned for indoor routing (nodes, edges, poi lists, serialized indices). Gains in size and parsing speed but needs client implementation.

**Tileization & partial download**

* When scaling, support **region/level-based partial download**: only download the floor(s) user needs. Break place into layers: Level -1, Level 0, Level 1. Fetch only required levels to save bandwidth.

**Map cache invalidation**

* Use `place:version` in filename and metadata so the app can detect updates. Keep old versions in S3 for rollbacks.

---

# DWG / PDF / image automatic parsing (map ingestion)

DWG parsing is notoriously messy and often requires commercial converters. Practical approach:

**MVP**

* **Require building staff to upload DXF, SVG, or high-resolution PDF** when possible. Accept DWG but treat it as “manual review required” (admin will review and convert). Use open-source tools that can read DXF/CAD formats (e.g., `LibreDWG` is limited; `ODA` libraries are commercial).
* Provide a **semi-automatic toolchain**:

  1. Convert DWG/PDF → raster/vector (use `pstoedit` / `pdf2svg` / commercial converter).
  2. Run **image processing / ML** to detect roads/entrances/parking polygons for initial extraction. Keep human-in-loop to validate results in admin portal.
  3. Produce geo-referenced geometry (GeoJSON) and then convert to OSM-like nodes/ways + tags.

**Phase 1+**

* Invest in a robust commercial DWG-to-GeoJSON converter or partner with a conversion vendor. The admin portal should allow manual edits in a JOSM-like editor.

---

# Backend service decomposition (start as modular monolith, split later)

Logical services/modules (design as modules in a monorepo initially; each can become a microservice later):

1. **auth\_service** — login, SSO, JWT tokens, device tokens, permission model
2. **user\_service** — profiles, roles, feedback, points system
3. **place\_service** — place metadata, levels, geo-indexing, queries by lat/lon + radius
4. **map\_service** — store map artifacts, upload endpoint, versioning, caching metadata, download signing & key delivery
5. **ingest\_processor** — background jobs for DWG → OSM workflows, map validation, easyroute connectivity checks
6. **routing\_service** — provide route validation, but **routing engine runs on mobile** (easyroute) to save cloud cost; server-side routing only for batch processing or prechecks.
7. **signal\_service** — bluetooth/wifi crowd data ingestion, cleaning, aggregation, export for localization model training
8. **asr\_service** — optional; use 3rd-party or hosted model endpoint for converting voice → text
9. **admin\_portal\_api** — APIs for map editing, audits, merchant approvals, and statistics
10. **analytics\_service** — usage events, route counts, DAU/MAU metrics

---

# Data model / DB suggestions (Postgres + PostGIS)

Tables (high level):

* `places` (id, name, bbox, polygon, levels\_count, owner\_id, status, version, created\_at) — place polygon with `geom` column
* `place_levels` (place\_id, level\_index, metadata)
* `pois` (id, place\_id, level\_index, geom, type, tags JSONB, label, is\_parking\_space boolean)
* `map_artifacts` (place\_id, version, file\_path (s3), checksum, size, encrypted bool, created\_at)
* `users`, `roles`, `permissions`
* `signal_samples` (place\_id, level, mac\_hash, rssi, timestamp, metadata JSONB) — store hashed MACs to reduce privacy concerns
* `events` (user actions) for analytics (or stream to ClickHouse / BigQuery later)

Indices: spatial index on `geom`, GIN index on JSONB tags. Partition `signal_samples` by place/time as volume grows.

---

# DevOps & CI/CD progressive plan

**MVP (0–6 months)**

* **Repos:** single monorepo (backend modules under `backend/`) and one `mobile/` repo or mono-repo. Single engineer is easier with monorepo.
* **Build & deploy:** GitHub (or GitLab) + **GitHub Actions** running tests, then deploy to a single VPS using simple scripts / `rsync`/ `docker-compose pull && docker-compose up -d`.
* **Backups:** nightly DB dump to S3, weekly full backups.
* **Monitoring:** Sentry for crash reports (app + backend), simple uptime check (UptimeRobot). Basic server logs to a file + rotate.
* **Infrastructure:** 1 small VM for web + API, managed Postgres, S3-compatible object storage, one Redis instance. Use `docker-compose` for local and production deployments.

**Sample GitHub Actions job (MVP)**

* `ci.yml`: run linters, unit tests, build docker image, push to private registry (optional).
* `deploy.yml`: on push to `main` build image and `ssh` to VPS and run `docker-compose pull && docker-compose up -d`.

**Phase 1 (6–24 months)**

* Break services into containers. Use **Docker** for every service and a private **container registry** (Docker Hub private or cloud provider).
* Move to multi-node deployment: either multiple VMs or a tiny managed k8s cluster (2–3 nodes) if you need rolling restarts, autoscaling, and more orchestration. Managed k8s (e.g., GKE, EKS, DO Kubernetes) is optional but recommended when you have more services.
* **CI/CD:** formalize with GitHub Actions: run unit tests, build images, push to registry, run integration tests, deploy to staging, run smoke tests, deploy to production with automated DB migrations.
* **IaC:** start using **Terraform** to declare managed DB, object store, DNS, VPC/Firewall.
* **Observability:** add Prometheus + Grafana (or managed metrics) and central logging with ELK or cloud logging (AWS CloudWatch).
* **Secrets management:** Use cloud KMS or Vault for keys.

**Phase 2 (24–36 months)**

* Full K8s with Helm charts, ingress controllers, horizontal pod autoscalers, cert-manager for TLS.
* Blue/green or canary deployments, and canary testing on a percentage of traffic.
* Multi-region DB replicas, read-replicas for Postgres, sharding by region if required.
* Add WAF, DDoS protections and SLA / runbooks, on-call rotations.

**When to adopt K8s?**

* Wait until you have **multiple services** and need automated scaling, or when team size > 4 and manual orchestration becomes costly. For cost reasons, avoid K8s for the single-engineer MVP stage — it’s operationally heavy. Migrate to k8s during Phase 1 when you need elasticity and easier rollouts.

---

# Cost-conscious cloud provider suggestions

* **MVP**: DigitalOcean, Hetzner, or a small AWS account using managed DB & S3; DigitalOcean Spaces is cheaper and simpler.
* **Phase 1**: Continue with DigitalOcean Managed Kubernetes or move to AWS/GCP depending on compliance / region.
* **Phase 2**: Use GKE/EKS for enterprise features and multi-region if budget allows.

---

# Observability / Logging / Error reporting (progressive)

* **MVP:** Sentry for errors + basic server metrics + simple logging files to disk (rotate).
* **Phase 1:** Centralized logs (ELK, Loki) + Prometheus + Grafana for metrics. Instrument key endpoints (map downloads counts, processing queue lag).
* **Phase 2:** Full tracing (OpenTelemetry), business dashboards with BI (Metabase or Looker).

---

# CI/CD snippet ideas

**MVP deploy flow (pseudocode)**

1. `push to main` → GitHub Actions runs tests & build → push Docker image to registry (optional).
2. On success, `ssh` to VPS and run:

```bash
cd /srv/findeasy
git pull origin main
docker-compose pull
docker-compose up -d --build
```

**Later (k8s)**

* Use GitHub Actions: build image → push to registry → `kubectl apply -f`/helm upgrade to staging → run smoke tests → promote to prod.

---

# Security & privacy notes (legal + data handling)

* **User privacy:** For Bluetooth/WiFi MACs, store hashed MAC addresses and obey local privacy laws. Offer opt-in for crowdsourced signal collection.
* **GDPR / region compliance:** if you expand to EU/JP/etc, implement data subject requests and data retention policy.
* **Auth:** use JWT with short lifetimes; refresh tokens stored securely. Use MFA for admin accounts.
* **Secrets:** store in cloud KMS or Vault — don’t keep keys in repo.
* **Backups:** encrypt DB dumps before uploading to object storage.

---

# Folder structure (backend monorepo) — recommended from day 0

A single repo with modular layout. This makes life easier for one engineer and migrates easily.

```
/repo-root
├─ .github/workflows/        # CI & CD
├─ infra/                    # Terraform (start empty, add later)
│   ├─ aws/
│   └─ do/
├─ deployments/              # docker-compose, k8s manifests, helm charts
│   ├─ docker-compose.yml
│   └─ k8s/
├─ backend/
│   ├─ services/
│   │   ├─ auth_service/
│   │   │   ├─ app/
│   │   │   ├─ tests/
│   │   │   └─ Dockerfile
│   │   ├─ place_service/
│   │   │   ├─ app/
│   │   │   ├─ tests/
│   │   │   └─ Dockerfile
│   │   ├─ map_service/
│   │   │   ├─ app/
│   │   │   ├─ artifact_store/   # s3 helpers
│   │   │   └─ Dockerfile
│   │   ├─ ingest_processor/     # workers, Celery/RQ/RabbitMQ consumers
│   │   └─ asr_service/          # optional, wrapper for third-party
│   ├─ libs/                     # shared libraries (db models, auth utils)
│   ├─ scripts/                  # maintenance scripts, migrate, backup
│   └─ Dockerfile                # top-level, for local development
├─ tools/
│   ├─ dwg_converter/           # scripts to convert DWG/PDF -> GeoJSON (prototype)
│   └─ map_validation/
├─ docs/
│   ├─ api.md
│   └─ arch.md
└─ mobile/                      # or separate repo for Flutter
    └─ (see Flutter structure below)
```

**Notes**:

* Put common models and types in `backend/libs` to avoid duplication.
* Each `service` has its own Dockerfile and tests. Use the monorepo to run `tox` or orchestrated testing.

---

# Detailed Flutter `findeasy` app folder structure

This layout assumes you want production-grade, maintainable structure using BLoC (you mentioned BLoC earlier) and separation of concerns.

```
/mobile-findeasy
├─ android/
├─ ios/
├─ lib/
│  ├─ main.dart
│  ├─ app.dart                     # app bootstrap, theme, routing
│  ├─ core/
│  │  ├─ config/                   # env config, feature flags
│  │  ├─ errors/
│  │  ├─ network/
│  │  │  ├─ http_client.dart       # wrapper for API with retry, cert pinning stub
│  │  │  └─ websocket.dart
│  │  ├─ storage/
│  │  │  └─ secure_storage.dart    # Android Keystore / iOS Keychain helpers
│  │  ├─ services/                 # cross-cutting services (tts, sensors)
│  │  └─ utils/
│  ├─ modules/
│  │  ├─ auth/
│  │  │  ├─ bloc/
│  │  │  ├─ views/
│  │  │  └─ repository/
│  │  ├─ map/
│  │  │  ├─ bloc/                  # MapBloc, MapDownloadBloc
│  │  │  ├─ widgets/               # map renderer widgets
│  │  │  ├─ models/
│  │  │  ├─ services/              # local parser for .osm.gz, cache manager
│  │  │  └─ storage/               # local DB / file structure for maps
│  │  ├─ navigation/
│  │  │  ├─ bloc/                  # RoutingBloc, LocalizationBloc
│  │  │  ├─ services/              # easyroute wrapper
│  │  │  └─ widgets/
│  │  ├─ asr/                      # voice recognition integration
│  │  └─ feedback/
│  ├─ data/
│  │  ├─ models/                   # DTOs / entities
│  │  ├─ datasources/              # REST API client, local store
│  │  └─ repositories/
│  ├─ features/
│  │  ├─ offline_map/              # offline download, decryption, caching
│  │  └─ ota/                      # update checker and OTA logic
│  ├─ generated/                   # codegen (json_serializable, protobuf)
│  └─ resources/
│     ├─ assets/
│     └─ i18n/
├─ test/
├─ build_scripts/
│  └─ build_and_sign.sh
├─ ci/
│  └─ flutter_ci.yml
└─ pubspec.yaml
```

**Key Flutter design decisions & notes**

* **Map storage on device**: store encrypted files under app-private storage; use Android Keystore / iOS Keychain (via `secure_storage`) for storing decryption keys. Decrypt to memory / ephemeral files only while rendering; purge caches on low disk.
* **Map parsing**: implement a small `.osm.gz` parser optimized for indoor (or reuse `easyroute` mobile-compatible parsing). Consider pre-parsing server-side into a compact binary payload to speed mobile startup.
* **Routing**: run `easyroute` native port or plugin on device to avoid server costs. Server only for precheck and validation.
* **Sensors**: use `flutter_compass`/`sensors` packages and integrate with the BLoC layer to provide heading & rotation.
* **ASR/TTS**: provide both cloud ASR (for best accuracy) and offline fallback (small language models). Use native TTS when possible.

---

# Example data-flow for map download & navigation (end-to-end)

1. App queries `GET /places/nearby?lat=..&lon=..&r=..`. Backend returns matching place(s) with `place_id` and `place:version`.
2. App requests `POST /places/{id}/request-download` providing device token (anonymous or logged-in). Backend verifies policy and returns **signed URL** and **(if encryption used) encrypted data-key token**.
3. App downloads encrypted `place:version.osm.gz.enc` from S3 via signed URL, fetches data-key from `GET /mapkeys/{artifact_id}` (authenticated) and decrypts locally using secure storage.
4. App loads map into in-memory graph, runs `easyroute` to compute route, start navigation.
5. App uploads feedback / visited POIs / signal samples (crowdsourced) to the `signal_service` for aggregation (opt-in).

---

# Operational / business suggestions

* **Start manual & human-in-the-loop**: for DWG conversion and admin review, accept manual review initially. This saves build time.
* **Monetization**: parking ads, merchant ads, premium features (saved maps, advanced voice packs). Keep payments for later after product-market fit.
* **Onboarding for managers**: provide simple checklist in merchant portal to verify map correctness (walk-through + mark checked POIs). This helps quality without heavy automation.
* **Collect metrics early**: even simple counters (map downloads, route requests, feedback reports) will help prioritize.

---

# Migration roadmap with timelines (concrete)

**Months 0–3 (MVP)**

* Implement modular monolith backend (FastAPI), Postgres + PostGIS managed, Redis, S3.
* Implement map upload endpoint (accept dxfs/pdfs), manual convert, produce `.osm.gz`.
* Implement mobile Flutter app with map download, render, easyroute routing, manual POI report, basic voice commands via device ASR.
* Deploy to one small VPS + managed DB. GitHub Actions + simple deploy script. Sentry + backups.

**Months 3–9**

* Build ingestion worker to automate conversion pipeline (image/PDF → vector). Add admin portal to validate maps.
* Implement envelope encryption for artifacts and device token flow. Add device binding basics.
* Add Redis-backed job queue and background worker. Start splitting map\_service & ingest\_processor into separate containers.

**Months 9–18**

* Migrate to containerized deployments, begin using a small managed k8s cluster or multiple VMs with orchestration.
* Add OpenSearch for search needs, Prometheus + Grafana.
* Improve map format for mobile (tileization or MBTiles) to reduce download sizes. Implement partial downloads per level.

**Months 18–36 (growth)**

* Full k8s with IaC (Terraform), multi-region object store or CDN for map assets, DB read replicas.
* Implement hardware-bound key storage for map decryption, improve anti-leak measures.
* Scale analytics to ClickHouse/BigQuery, add ML pipeline for bluetooth/wifi localization.

---

# Quick "what to do tomorrow" list for your one engineer

1. **Pick stack & repo layout** (use the folder structure above).
2. **Provision managed Postgres + S3** (DigitalOcean or AWS).
3. **Create FastAPI project skeleton** with modules for auth, places, and a map artifact endpoint. Build minimal APIs for `GET /places/nearby` and `POST /places/{id}/request-download`.
4. **Build a minimal Flutter app** that can call nearby API, download an `.osm.gz`, and parse & render it locally (2D). Integrate `easyroute` locally.
5. **Set up GitHub Actions**: run tests and deploy a basic `docker-compose` on a cheap VPS.
6. **Plan DWG conversion**: ask early customers to upload DXF/PDF, not raw DWG if possible.

---

# Final tips & trade-offs

* **Don’t prematurely microservice**. Start modular and split services when necessary. Microservices have an ops cost.
* **Use managed services** for DB & storage early — saves you ops time which is the most expensive resource (your engineer’s time).
* **Security**: balance cost/protection. Start with TLS + signed URLs + server-side encryption. Move to envelope encryption & device binding as needed.
* **Map format**: start with `.osm.gz`. Migrate to MBTiles/vector tiles/custom binary for performance at Phase 1.
* **K8s only when needed**: it reduces manual deployment pain later but is heavy for one dev.

---

If you want I can:

* produce detailed **API contract** (OpenAPI) for the key endpoints (places, map download, map upload, auth) so your mobile dev can start immediately; or
* produce a **starter GitHub Actions** `ci.yml` and a `docker-compose.yml` that you can paste to run MVP on a single VPS; or
* produce the **exact Flutter file skeleton** (main files + example BLoC) to speed app dev.

Which one do you want first? (If you pick one, I’ll give code + ready-to-run manifests you can use immediately.) 🚀
