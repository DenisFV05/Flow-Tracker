# Flow-Tracker

> Tracker de Hàbits i Xarxa Social — DAM AMS2 · MP13 Projecte · Crèdit de Síntesi · Maig 2026

Aplicació multiplataforma per registrar hàbits diaris, visualitzar estadístiques i compartir el progrés amb amics.

---

## Funcionalitats

- **Crear i gestionar hàbits** amb etiquetes personalitzades
- **Registre diari** de compliment per hàbit
- **Estadístiques**: ratxa actual, ratxa màxima, heatmap anual, gràfiques setmanal/mensual
- **Xarxa social**: sistema d'amistats, feed, likes i publicacions manuals
- **Assoliments automàtics**: post al feed i notificació en assolir fites de ratxa (7, 14, 30, 60, 90, 180, 365 dies)
- **Sistema de notificacions**: likes, sol·licituds d'amistat i assoliments
- **Mode clar / fosc**
- **Exportació CSV** de l'historial d'activitat
- **Imatges al feed** (upload en Base64)
- **Leaderboard** entre amics

---

## Stack Tecnològic

| Capa | Tecnologia |
|------|-----------|
| **Frontend** | Flutter 3 (Dart) — Windows, Android, Web |
| **Backend** | Node.js 18 + Express 5 |
| **Base de Dades** | PostgreSQL 14 + Prisma ORM |
| **Autenticació** | JWT + bcrypt |
| **Servidor** | Proxmox LXC + Nginx + PM2 |

---

## Estructura del Repositori

```
Flow-Tracker/
├── backend/              # API REST Node.js
│   ├── src/
│   │   ├── routes/       # Endpoints (/auth, /habits, /tags, /feed, /friends, /profile)
│   │   ├── middleware/   # auth.js (JWT), validation.js (express-validator)
│   │   └── server.js     # Punt d'entrada, middlewares globals
│   └── prisma/
│       ├── schema.prisma # Esquema de la BD
│       └── migrations/   # Historial de migracions
│
├── frontend/             # App Flutter
│   └── lib/
│       ├── views/        # Pantalles (dashboard, feed, amics, perfil...)
│       ├── widgets/      # Components reutilitzables
│       ├── providers/    # Gestió d'estat (Provider / ChangeNotifier)
│       ├── services/     # Crides a l'API (api_client.dart)
│       └── config/       # Tema, colors, configuració de l'app
│
└── docs/                 # Documentació completa del projecte
    ├── README.md                    # Índex de documentació
    ├── arquitectura_i_disseny.md    # Decisions tècniques, BD, dificultats
    ├── backend_api_docs.md          # Referència completa de l'API REST
    ├── frontend_docs.md             # Estructura Flutter, providers, pantalles
    ├── manual_desplegament.md       # Guia de desplegament al servidor
    └── developer_guide.md           # Guia tècnica interna per a desenvolupadors
```

---

## Posada en Marxa Local

### Backend

```bash
cd backend
npm install
# Crear .env amb DATABASE_URL i JWT_SECRET (veure docs/manual_desplegament.md)
npx prisma migrate dev
npm run dev
# API disponible a http://localhost:3001
```

### Frontend

```bash
cd frontend
flutter pub get
flutter run -d windows   # Desktop Windows
flutter run -d chrome    # Navegador web
```

---

## Accés en Producció

| Servei | URL |
|--------|-----|
| **App Web** | https://flow-tracker.ieti.site |
| **APK Android** | https://flow-tracker.ieti.site/flow.apk |

---

## Documentació

Tota la documentació es troba a [`/docs`](./docs/):

- **[Índex de documentació](./docs/README.md)**
- **[Arquitectura i Disseny](./docs/arquitectura_i_disseny.md)** — Decisions tècniques, BD, dificultats trobades
- **[Referència API REST](./docs/backend_api_docs.md)** — Tots els endpoints documentats
- **[Documentació Frontend](./docs/frontend_docs.md)** — Estructura Flutter, providers, pantalles
- **[Manual de Desplegament](./docs/manual_desplegament.md)** — Guia pas a pas per desplegar al servidor
- **[Guia del Desenvolupador](./docs/developer_guide.md)** — Referència interna: flux de dades, com afegir funcionalitats

---

*Flow-Tracker v1.0 — Denis FV — DAM AMS2 — IETI — MP13 Crèdit de Síntesi — Maig 2026*