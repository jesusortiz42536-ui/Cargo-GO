# CLAUDE.md - Cargo-GO / Farmacias Madrid Ecosystem

## Project Overview

This is a multi-component business ecosystem for **Farmacias Madrid** in Tulancingo, Hidalgo, Mexico. It consists of:

1. **SISTEMA.py** - Desktop POS (Point of Sale) system built with Python/Tkinter
2. **Cargo-GO PWA** - Package delivery & marketplace web app (Flask + vanilla JS)
3. **Cargo-GO Mobile** - React Native Android app (`com.cargogoapp`) with Firebase
4. **API Repartidores** - Flask REST API for delivery drivers
5. **Utility scripts** - Catalog management, pricing, imports, backups

## Tech Stack

| Component | Technology |
|-----------|-----------|
| POS Desktop | Python 3.8+, Tkinter, SQLite3, Pillow, openpyxl |
| Cargo-GO API | Python Flask, Flask-CORS, SQLite3 |
| Cargo-GO PWA | Vanilla JS, CSS3, Service Workers (PWA) |
| Mobile App | React Native 0.83, Firebase (app + messaging) |
| Database | SQLite3 (`farmacia.db`) - shared across components |
| Android Build | Gradle 8.13, compileSdk 36, targetSdk 36, minSdk 24 |

## Repository Structure

### pntventa/ (POS + Backend)
```
pntventa/
├── SISTEMA.py                  # Main POS system (~12,800 lines, Tkinter)
├── INSTALAR.py                 # Database installer (creates farmacia.db)
├── farmacia.db                 # SQLite database (47,982 products)
│
├── api_cargo_go.py             # Cargo-GO Flask API (port 5001)
├── api_repartidores.py         # Delivery drivers Flask API (port 5000)
│
├── app_cargo_go/               # Cargo-GO PWA frontend
│   ├── index.html              # Main HTML (dashboard UI)
│   ├── app.js                  # App logic (navigation, API calls, etc.)
│   ├── styles.css              # Full CSS stylesheet
│   ├── manifest.json           # PWA manifest
│   └── service-worker.js       # Offline caching
│
├── app_repartidores/           # Delivery driver web app
│   ├── index.html
│   ├── manifest.json
│   └── service-worker.js
│
├── whatsapp_service.py         # WhatsApp integration
├── backup_automatico.py        # Automated backup system
│
├── ACTUALIZAR_PRECIOS.py       # Price update utility
├── AGREGAR_HOSPITALARIOS.py    # Hospital products importer
├── AGREGAR_MAYORISTAS.py       # Wholesale products importer
├── COMBINAR_CATALOGO.py        # Catalog combiner
├── CORREGIR_PRECIOS.py         # Price correction utility
├── EXPORTAR_EXCEL.py           # Excel exporter
├── IMPORTAR_DESDE_EXCEL.py     # Excel importer
├── INTEGRAR_COFEPRIS.py        # COFEPRIS regulatory data integration
├── MARCAR_CONTROLADOS.py       # Controlled substance marker
│
├── imagenes/                   # System images/assets
├── tarjetas/                   # Payment card receipts/PDFs
├── presentacion/               # Presentation materials
├── logo.png                    # System logo
└── README.txt                  # Credentials and documentation
```

### Cargo-GO/ (React Native Mobile App)
```
CargoGOApp/                     # On local machine (C:\Windows\System32\CargoGOApp)
├── android/                    # Android native project (Gradle)
├── ios/                        # iOS project (if applicable)
├── src/                        # React Native source
├── node_modules/               # Dependencies
│   ├── @react-native-firebase/app     # Firebase core (v23.8.6)
│   └── @react-native-firebase/messaging  # Push notifications
├── package.json
├── metro.config.js
└── index.js
```

## API Endpoints

### Cargo-GO API (`api_cargo_go.py` - port 5001)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/login` | User authentication |
| GET | `/api/zonas` | List delivery zones |
| GET | `/api/detectar-zona/<cp>` | Detect zone by postal code |
| GET | `/api/repartidores` | List delivery drivers |
| POST | `/api/cotizar` | Quote delivery price |
| POST | `/api/envios` | Create new shipment |
| GET | `/api/rastrear/<folio>` | Track shipment by folio |
| GET | `/api/historial` | Shipment history |
| GET | `/api/negocios` | List marketplace businesses |
| GET | `/api/negocios/<id>` | Business details |
| GET | `/api/negocios/<id>/productos` | Business product catalog |
| POST | `/api/negocios/registro` | Register new business |
| GET | `/api/stats` | Dashboard statistics |
| GET | `/api/farmacia/productos` | Pharmacy product catalog |
| GET | `/api/farmacia/buscar` | Search pharmacy products |
| GET | `/api/farmacia/categorias` | Product categories |
| GET | `/api/farmacia/ofertas` | Current offers |
| POST | `/api/farmacia/pedido` | Place pharmacy order |
| GET | `/api/farmacia/pedidos` | List orders |
| PUT | `/api/farmacia/pedidos/<id>/estado` | Update order status |
| GET | `/api/farmacia/pedidos/stats` | Order statistics |

### Repartidores API (`api_repartidores.py` - port 5000)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/entregas` | List deliveries (filterable) |
| GET | `/api/entregas/<id>` | Delivery details |
| POST | `/api/entregas/<id>/iniciar` | Mark delivery as in-transit |
| POST | `/api/entregas/<id>/completar` | Mark delivery as completed |
| GET | `/api/repartidor/<id>` | Driver info |
| GET | `/api/stats/<repartidor_id>` | Driver statistics |

## Database Schema (Key Tables)

Shared SQLite database `farmacia.db`:
- **productos** - Product catalog (47,982 COFEPRIS items)
- **ventas / detalle_ventas** - Sales transactions
- **clientes** - Customer records with loyalty points
- **repartidores** - Delivery drivers
- **entregas** - Home delivery tracking
- **negocios_marketplace** - Marketplace businesses
- **productos_marketplace** - Marketplace product listings
- **pedidos_marketplace** - Marketplace orders
- **items_pedido** - Order line items
- **traspasos / detalle_traspasos** - Inter-branch transfers
- **usuarios** - System users with roles
- **auditoria** - Audit trail

## Development Commands

### POS System
```bash
pip install Pillow openpyxl
python INSTALAR.py          # First-time DB setup
python SISTEMA.py           # Run POS
```

### Cargo-GO API
```bash
pip install flask flask-cors
python api_cargo_go.py      # Starts on port 5001
```

### Repartidores API
```bash
python api_repartidores.py  # Starts on port 5000
```

### React Native Mobile App
```bash
cd CargoGOApp
npm install
npx react-native run-android   # Build & run on emulator
npx react-native start          # Metro bundler (port 8081)
```

## Default Credentials

| User | Password | Role |
|------|----------|------|
| admin | admin123 | ADMINISTRADOR |
| super | root123 | ADMINISTRADOR |
| jperez | pass123 | VENDEDOR |

## Key Business Logic

- **Delivery zones**: Organized by postal code (CP), primarily Tulancingo area
- **Pricing**: Base rate + weight surcharge + IVA (16%)
- **Shipment folios**: Format `CGO-YYYYMMDD-XXXXX`
- **Marketplace**: Multi-vendor with business registration, catalog, and ordering
- **POS**: Barcode scanning, mixed payments (cash/card/voucher), home delivery

## Known Issues

- Gradle 8.13 deprecation warnings (incompatible with Gradle 9.0) - non-blocking
- Metro port 8081 conflicts if already running - use `--port 8082` or kill existing process
- `nul` file on Windows causes git errors - excluded in .gitignore

## AI Assistant Guidelines

1. **Read before modifying** - Always read files before suggesting changes
2. **SISTEMA.py is massive** (~12,800 lines) - Read specific sections, not the whole file
3. **Shared database** - Changes to DB schema affect all components (POS, API, PWA)
4. **Spanish UI** - All user-facing text must be in Spanish
5. **Preserve patterns** - Match existing code style and conventions
6. **Minimal changes** - Only modify what's directly requested
7. **Test on Windows** - POS uses `winsound` and Windows-specific paths
8. **API consistency** - Both APIs share the same `farmacia.db`; coordinate schema changes
