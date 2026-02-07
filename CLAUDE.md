# CLAUDE.md - Cargo-GO

## Project Overview

Cargo-GO is a **delivery, marketplace, and pharmacy ecosystem** for Farmacias Madrid, based in Tulancingo, Hidalgo, Mexico. The project consists of:

1. **Flutter Mobile App** (`lib/`) - The primary Android client with marketplace browsing, pharmacy ordering, delivery tracking, and Google Maps integration
2. **Driver PWA** (`app_repartidores/`) - Progressive Web App for delivery drivers with real-time delivery management
3. **Backend APIs** (external) - Two Flask REST APIs: Cargo-GO (port 5001) and Repartidores (port 5000), sharing a SQLite `farmacia.db` database

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Mobile App | Flutter (Dart SDK >=3.3.4 <4.0.0) |
| HTTP Client | `http` ^1.2.1 |
| Maps | `google_maps_flutter` ^2.5.3 |
| GPS/Location | `geolocator` ^12.0.0 |
| Geocoding | `geocoding` ^3.0.0 |
| URL Handling | `url_launcher` ^6.2.5 |
| Local Storage | `shared_preferences` ^2.2.2 |
| Linting | `flutter_lints` ^3.0.0 |
| Driver Web App | Vanilla HTML/CSS/JS, PWA with Service Worker |
| Backend APIs | Python Flask, Flask-CORS, SQLite3 |
| Database | SQLite3 (`farmacia.db`) - 47,982 pharmacy products |
| Android | minSdk 24, targetSdk 36, compileSdk 36 |

## Repository Structure

```
Cargo-GO/
├── lib/
│   ├── main.dart                    # Full app (~2,520 lines): models, data, screens, widgets
│   └── services/
│       └── api_service.dart         # HTTP client for both Flask APIs (281 lines)
│
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml      # Permissions, Google Maps API key, cleartext traffic
│
├── app_repartidores/                # Delivery driver PWA
│   ├── index.html                   # Full driver UI (~965 lines, self-contained)
│   ├── manifest.json                # PWA manifest (standalone, dark blue theme)
│   └── service-worker.js            # Network-first caching, offline API fallback
│
├── assets/
│   └── images/
│       ├── logo.png                 # Cargo-GO logo
│       └── farmacia_logo.png        # Farmacias Madrid logo
│
├── pubspec.yaml                     # Flutter dependencies and config
├── logo.png                         # Cargo-GO logo (root copy)
├── CLAUDE.md                        # This file
└── README.md                        # Project title
```

## Architecture

### Flutter App (`lib/main.dart`)

The entire app lives in a single file organized as follows:

**Data Models** (lines 47-110):
- `MenuItem` - Restaurant/bakery menu item (name, desc, price, popularity)
- `FarmItem` - Pharmacy product (name, lab, category, list price, stock, RX flag; `oferta` = 65% of list)
- `Negocio` - Marketplace business (id, name, emoji, zone, description, type, rating, orders, color)
- `Pedido` - Delivery order (folio, client, origin, dest, status, time, city, minutes, progress %)
- `Ruta` - Delivery route (name, distance, time, status, package count, color)
- `CartItem` - Shopping cart item (name, from, price, offer price, quantity)
- `Notif` - Notification (title, description, time, read status)
- `Addr` - Saved address
- `PayMethod` - Payment method
- `OrderHist` - Order history

**Static Demo Data** (hardcoded lists):
- `menuMama` (27 items) - Traditional Mexican food for "Cocina de Mama Rosa"
- `menuDulce` (20 items) - Desserts for "Dulce Tentacion"
- `farmacia` (26+ items) - Pharmacy products (generics, branded, biologics, oncology)
- `negHidalgo` (20 businesses) - Tulancingo marketplace
- `negCdmx` (50+ businesses) - Mexico City marketplace
- `pedidos` (12 orders) - Active deliveries
- `rutas` (6 routes) - Active delivery routes
- `notifs`, `addrs`, `pays`, `orderHist` - User data

**Screens & Navigation**:
- `SplashScreen` - Animated logo intro (1.5s)
- `LoginScreen` - Phone + 6-digit OTP, Facebook/Instagram OAuth, guest mode
- `MainApp` - 5-tab bottom navigation:
  1. **Inicio** - Dashboard with stats, featured businesses, map
  2. **Negocios** - Marketplace browser (Tulancingo + CDMX)
  3. **Pedidos** - Delivery tracking with folio lookup
  4. **Mudanzas** - Bulk/relocation delivery services
  5. **Perfil** - User profile and settings

**Theme** (`AppTheme` class):
- Background: `#060B18` (very dark blue)
- Accent: `#2D7AFF` (neon blue)
- Success: `#00D68F`, Error: `#FF4757`, Warning: `#FFA502`
- Text: `#EDF2F7`, Muted: `#8899B4`
- Custom dark Google Maps style matching the theme

### API Service (`lib/services/api_service.dart`)

Static class with `_get()`, `_post()`, `_put()` HTTP helpers (10-second timeout). Organized by domain:

- **Auth**: `login(usuario, password)`
- **Marketplace**: `getNegocios()`, `getNegocio(id)`, `getProductosNegocio(id)`, `registrarNegocio(data)`
- **Shipping**: `cotizar(cp, peso)`, `crearEnvio(data)`, `rastrear(folio)`, `getHistorial()`
- **Zones**: `getZonas()`, `detectarZona(cp)`
- **Drivers** (port 5000): `getEntregas()`, `iniciarEntrega(id)`, `completarEntrega(id)`, `getRepartidor(id)`, `getRepartidorStats(id)`
- **Pharmacy**: `getFarmaciaProductos()`, `buscarFarmacia(q)`, `getCategorias()`, `getOfertas()`, `crearPedidoFarmacia()`, `getPedidos()`, `actualizarEstadoPedido()`
- **Health**: `isOnline()`, `isRepartidoresOnline()`, `checkAllServices()`

**Base URLs** (hardcoded - local network):
- Cargo-GO API: `http://192.168.0.103:5001`
- Repartidores API: `http://192.168.0.103:5000`

### Driver PWA (`app_repartidores/`)

Self-contained single-page web app:
- Light theme (blue/orange palette, `#001A4D` primary)
- Delivery list with status management (pending, in-transit, completed)
- Driver info, stats, and map integration
- PWA installable via manifest.json
- Service worker: network-first for static files, network-only for APIs with offline JSON fallback

## API Endpoints

### Cargo-GO API (port 5001)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/login` | User authentication |
| GET | `/api/stats` | Dashboard statistics |
| GET | `/api/zonas` | Delivery zones |
| GET | `/api/detectar-zona/<cp>` | Detect zone by postal code |
| GET | `/api/repartidores` | List delivery drivers |
| POST | `/api/cotizar` | Quote delivery price (cp + peso) |
| POST | `/api/envios` | Create new shipment |
| GET | `/api/rastrear/<folio>` | Track shipment by folio |
| GET | `/api/historial` | Shipment history |
| GET | `/api/negocios` | List marketplace businesses |
| GET | `/api/negocios/<id>` | Business details |
| GET | `/api/negocios/<id>/productos` | Business product catalog |
| POST | `/api/negocios/registro` | Register new business |
| GET | `/api/farmacia/productos` | Pharmacy catalog (pagination: limite, offset, categoria, q) |
| GET | `/api/farmacia/buscar?q=` | Search pharmacy products |
| GET | `/api/farmacia/categorias` | Product categories |
| GET | `/api/farmacia/ofertas` | Current promotions |
| POST | `/api/farmacia/pedido` | Place pharmacy order |
| GET | `/api/farmacia/pedidos` | List orders (filterable by estado) |
| GET | `/api/farmacia/pedidos/<id>` | Order details |
| PUT | `/api/farmacia/pedidos/<id>/estado` | Update order status |
| GET | `/api/farmacia/pedidos/stats` | Order statistics |

### Repartidores API (port 5000)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/entregas` | List deliveries (filter: estado, repartidor_id) |
| GET | `/api/entregas/<id>` | Delivery details |
| POST | `/api/entregas/<id>/iniciar` | Start delivery (mark in-transit) |
| POST | `/api/entregas/<id>/completar` | Complete delivery |
| GET | `/api/repartidor/<id>` | Driver info |
| GET | `/api/stats/<repartidor_id>` | Driver statistics |

## Development Commands

### Flutter Mobile App

```bash
# Install dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Build Android APK
flutter build apk

# Analyze code
flutter analyze
```

### Driver PWA

No build step required. Serve the `app_repartidores/` directory with any static file server:

```bash
# Using Python
python3 -m http.server 8080 -d app_repartidores/

# Or open index.html directly in a browser
```

### Backend APIs (external - not in this repo)

```bash
pip install flask flask-cors
python api_cargo_go.py       # Port 5001
python api_repartidores.py   # Port 5000
```

## Android Configuration

- **Package**: Defined in android build config
- **Permissions**: INTERNET, ACCESS_FINE_LOCATION, ACCESS_COARSE_LOCATION
- **Google Maps**: API key placeholder in `AndroidManifest.xml` (`TU_GOOGLE_MAPS_API_KEY_AQUI` - must be replaced)
- **Cleartext traffic**: Enabled (`android:usesCleartextTraffic="true"`) for local HTTP API access
- **URL schemes**: Supports `https` and `geo` intents (for navigation app launching)

## Key Business Logic

- **Delivery zones**: Organized by postal code (CP), centered on Tulancingo, Hidalgo
- **Pricing**: Base rate + weight surcharge + IVA (16%)
- **Shipment folios**: Format `CGO-YYYYMMDD-XXXXX`
- **Pharmacy offers**: Calculated as 65% of list price (`FarmItem.oferta`)
- **Marketplace**: Multi-vendor with Tulancingo (20 businesses) and CDMX (50+ businesses)
- **Currency**: Mexican Pesos (MXN), formatted with `$` prefix
- **Language**: All user-facing text is in **Spanish**

## Testing

- `flutter_test` SDK is declared in dev_dependencies but no test files exist yet
- No CI/CD pipeline configured

## Known Issues

- Google Maps API key is a placeholder - needs a real key for maps to render
- API base URLs are hardcoded to `192.168.0.103` - must be updated per environment
- `main.dart` is a large single file (~2,520 lines) containing all models, data, and UI
- No environment configuration (.env) - URLs and keys are inline

## AI Assistant Guidelines

1. **Read before modifying** - Always read files before suggesting changes
2. **`main.dart` is large** (~2,520 lines) - Read specific line ranges, not the whole file
3. **Spanish UI** - All user-facing strings must be in Spanish
4. **Dark theme** - All new UI must use `AppTheme` color constants, not hardcoded colors
5. **Preserve existing patterns** - Match the terse model naming convention (single-letter fields like `n`, `d`, `p`)
6. **API coordination** - Both APIs share `farmacia.db`; the Flutter app talks to both via `ApiService`
7. **No build system in repo** - Android build files (build.gradle) are generated by Flutter, not checked in
8. **PWA is standalone** - `app_repartidores/` has no build step; edit HTML/CSS/JS directly
9. **Minimal changes** - Only modify what's directly requested; avoid unnecessary refactoring
10. **Map styling** - Google Maps uses a custom dark JSON style (`_darkMapStyle`) that must match `AppTheme`
