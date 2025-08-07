# FindEasy - Progressive Architecture & Deployment Strategy

## Executive Summary

This document outlines a progressive architecture for FindEasy, an indoor navigation system designed to scale from 10 places (single engineer) to 100,000+ places worldwide (medium team) over 3 years. The solution prioritizes cost-effectiveness, maintainability, and gradual complexity introduction.

**Key Architectural Decisions:**
- **Client-side routing**: easyroute runs on mobile devices to reduce cloud costs
- **Distributed map data**: .osm.gz files distributed to clients for offline navigation
- **Server-light architecture**: Backend focuses on map management, not routing computation

## Technology Stack Overview

### Phase 1 (Months 1-6): MVP with Single Engineer
- **Backend**: Node.js + Express + SQLite (map management only)
- **Mobile**: Flutter + easyroute (client-side routing)
- **Database**: SQLite → PostgreSQL (when needed)
- **Deployment**: Single VPS (DigitalOcean/AWS EC2)
- **Map Storage**: Local file system + CloudFlare R2 (cheap S3 alternative)
- **Map Distribution**: .osm.gz files via CDN

### Phase 2 (Months 7-18): Scaling to 1000 Places
- **Backend**: Microservices with Node.js + Express (map management focus)
- **Mobile**: Flutter + easyroute (enhanced client-side routing)
- **Database**: PostgreSQL + Redis for caching
- **Deployment**: Docker containers on managed Kubernetes (GKE/AKS)
- **Map Storage**: CloudFlare R2 + CDN for .osm.gz distribution
- **Monitoring**: Prometheus + Grafana

### Phase 3 (Months 19-36): Global Scale (100,000+ Places)
- **Backend**: Microservices with auto-scaling (map management focus)
- **Mobile**: Flutter + easyroute (advanced client-side routing)
- **Database**: Multi-region PostgreSQL + Redis Cluster
- **Deployment**: Multi-region Kubernetes with Istio service mesh
- **Map Storage**: Multi-region CDN with edge caching for .osm.gz files
- **Monitoring**: Distributed tracing + advanced analytics

## Detailed Architecture

### 1. Backend Services Architecture

#### Core Services (Map Management Focus)
```
backend/
├── map-editor-service/      # OSM map editing & validation
├── map-distribution-service/ # .osm.gz file generation & distribution
├── place-management-service/ # Place metadata & boundaries
├── user-service/            # User management & profiles
├── feedback-service/        # User feedback & support
├── analytics-service/       # Usage analytics & statistics
├── notification-service/    # Push notifications & alerts
├── payment-service/         # Payment processing (future)
└── admin-service/          # Admin portal backend
```

**Note**: No routing service needed - routing happens client-side with easyroute

#### Service Communication
- **Phase 1**: Direct function calls within monolith
- **Phase 2**: REST APIs with service discovery
- **Phase 3**: gRPC with service mesh for performance

### 2. Data Architecture

#### Database Design
```sql
-- Core tables (map management focus)
users (id, email, phone, role, created_at, updated_at)
places (id, name, boundary_polygon, levels, osm_file_url, created_at, updated_at)
map_elements (id, place_id, osm_id, element_type, tags, geometry, created_at, updated_at)
map_edits (id, user_id, place_id, element_id, edit_type, changes, status, created_at)
user_sessions (id, user_id, place_id, start_time, end_time, created_at)
feedback (id, user_id, place_id, type, content, status, created_at, updated_at)

-- Analytics tables
user_analytics (id, user_id, action, metadata, timestamp)
place_analytics (id, place_id, metric, value, timestamp)
map_download_analytics (id, place_id, user_id, download_time, file_size)
```

#### Data Storage Strategy
- **Phase 1**: SQLite for development, PostgreSQL for production
- **Phase 2**: PostgreSQL with read replicas
- **Phase 3**: Multi-region PostgreSQL with sharding

### 3. Map Data Management (Updated Architecture)

#### Map Processing Pipeline
```
1. DWG/PDF Upload → 2. OCR/AI Recognition → 3. OSM Conversion → 4. Validation → 5. .osm.gz Generation → 6. CDN Distribution
```

#### Map Storage & Distribution Strategy
- **Raw files**: CloudFlare R2 (cheaper than S3)
- **Processed OSM**: Stored as .osm.gz files (compressed and encrypted)
- **Distribution**: CDN for global .osm.gz file delivery
- **Client caching**: Mobile apps cache .osm.gz files locally
- **Versioning**: Each place has versioned .osm.gz files

#### Map Data Flow
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Map Editor    │───►│  Map Service    │───►│  .osm.gz File   │
│   (Admin/Web)   │    │  (Backend)      │    │  (CDN)          │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                       │
                                ▼                       ▼
                       ┌─────────────────┐    ┌─────────────────┐
                       │   Database      │    │  Mobile App     │
                       │   (Metadata)    │    │  (easyroute)    │
                       └─────────────────┘    └─────────────────┘
```

#### Security Measures
- **Encryption**: AES-256 for .osm.gz files
- **Access Control**: JWT tokens with expiration
- **Rate Limiting**: Prevent abuse
- **Audit Logging**: Track all map edits and downloads

### 4. Mobile Architecture (Client-Side Routing)

#### Flutter App Structure
```
findeasy-app/
├── lib/
│   ├── services/
│   │   ├── map_download_service.dart    # Download .osm.gz files
│   │   ├── easyroute_service.dart       # Client-side routing
│   │   ├── navigation_service.dart      # Navigation logic
│   │   └── api_service.dart            # Backend communication
│   ├── models/
│   │   ├── place.dart
│   │   ├── poi.dart
│   │   └── route.dart
│   └── ui/
│       ├── map_screen.dart
│       ├── navigation_screen.dart
│       └── poi_selection_screen.dart
```

#### Client-Side Routing Flow
```dart
// 1. Download map data
final osmFile = await mapDownloadService.downloadPlaceMap(placeId);

// 2. Load into easyroute
await easyroute.loadFromOsmFile(osmFilePath: osmFile.path);

// 3. Generate route locally
final route = await easyroute.findPath(
  startPoint: userLocation,
  endPoint: destination,
);

// 4. Navigation happens entirely on device
final instructions = easyroute.generateNavigationInstructions(route);
```

### 5. Backend API Design (Lightweight)

#### Map Management APIs
```javascript
// Map editing
POST /api/places/:id/elements     // Add map elements
PUT /api/places/:id/elements/:elementId  // Update elements
DELETE /api/places/:id/elements/:elementId  // Delete elements

// Map distribution
GET /api/places/:id/map          // Get .osm.gz file URL
POST /api/places/:id/map/generate // Generate new .osm.gz file
GET /api/places/:id/map/version  // Get current map version

// Analytics (no routing data needed)
POST /api/analytics/map-download // Track map downloads
POST /api/analytics/user-session // Track user sessions
```

#### No Routing APIs Needed
- **No route calculation** on server
- **No real-time navigation** updates from server
- **No path optimization** on server
- **Server focuses** on map management and analytics

### 6. Cost Optimization Benefits

#### Server Resource Savings
- **No CPU-intensive routing** calculations
- **No real-time path** generation
- **Reduced bandwidth** (only map file downloads)
- **Simpler scaling** (map management vs routing)

#### Client-Side Benefits
- **Offline navigation** capability
- **Faster response** times (no network latency)
- **Reduced server** dependency
- **Better user** experience

### 7. Progressive Scaling Strategy

#### Phase 1: Simple Map Management
```javascript
// Single server handles everything
const app = express();
app.use('/api/places', placeRoutes);
app.use('/api/maps', mapRoutes);
app.use('/api/users', userRoutes);
```

#### Phase 2: Microservices for Map Management
```javascript
// Separate services for different concerns
const mapEditorService = new MapEditorService();
const mapDistributionService = new MapDistributionService();
const placeManagementService = new PlaceManagementService();
```

#### Phase 3: Global Map Distribution
```javascript
// Multi-region map distribution
const globalMapService = new GlobalMapDistributionService({
  regions: ['us-east', 'eu-west', 'asia-pacific'],
  cdn: 'cloudflare',
  storage: 'r2'
});
```

## Updated Deployment Strategy

### Phase 1: Lightweight Backend
- **Single VPS** with minimal resources
- **Focus on map management** APIs
- **CDN for .osm.gz** file distribution
- **Simple monitoring** (basic health checks)

### Phase 2: Map Management Scaling
- **Microservices** for map editing, distribution, analytics
- **Kubernetes** for orchestration
- **Advanced monitoring** for map download analytics
- **Multi-region CDN** for global map distribution

### Phase 3: Global Map Management
- **Multi-region** map management services
- **Advanced analytics** for map usage patterns
- **Automated map** validation and distribution
- **Global CDN** optimization

## Updated Cost Analysis

### Phase 1 (10 places)
- **Server**: $20/month (minimal resources needed)
- **CDN**: $10/month (map file distribution)
- **Total**: $30/month

### Phase 2 (1000 places)
- **Kubernetes**: $200/month
- **CDN**: $100/month (increased map distribution)
- **Total**: $300/month

### Phase 3 (100,000 places)
- **Multi-region**: $2000/month
- **Global CDN**: $500/month
- **Total**: $2500/month

**Key Savings**: No routing computation costs, only map management and distribution costs.

## Summary

This updated architecture reflects the **client-side routing** approach:

1. **Backend focuses** on map management, not routing
2. **Mobile apps** handle all routing with easyroute
3. **Map data** distributed as .osm.gz files via CDN
4. **Significant cost savings** from reduced server load
5. **Better user experience** with offline navigation
6. **Simpler scaling** (map management vs complex routing)

The architecture is now optimized for your specific requirements while maintaining the progressive scaling approach. 