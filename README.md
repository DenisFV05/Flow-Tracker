# Flow-Tracker 🔥

> **Tracker de Hàbits i Xarxa Social** · DAM AMS2 · MP13 Projecte · Crèdit de Síntesi · Maig 2026

Aplicació multiplataforma per registrar hàbits diaris, visualitzar estadístiques i compartir el progrés amb amics.

---

## ✨ Funcionalitats

- 🎯 **Crear i gestionar hàbits** amb etiquetes personalitzades
- ✅ **Registre diari** de compliment per hàbit
- 📊 **Estadístiques**: ratxa actual, ratxa màxima, heatmap anual, gràfiques setmanal/mensual
- 👥 **Xarxa social**: sistema d'amistats, feed, likes i publicacions manuals
- 🏆 **Assoliments automàtics**: posts generats en assolir fites de ratxa (7, 14, 30... dies)
- 🌙 **Mode clar/fosc**
- 📤 **Exportació CSV** de l'historial d'activitat
- 🖼️ **Imatges al feed** (upload en Base64)
- 🏅 **Leaderboard** entre amics

---

## 🛠️ Stack Tecnològic

| Capa | Tecnologia |
|------|-----------|
| **Frontend** | Flutter 3 (Dart) — Windows, Android, Web |
| **Backend** | Node.js 18 + Express 5 |
| **Base de Dades** | PostgreSQL 14 + Prisma ORM |
| **Autenticació** | JWT + bcrypt |
| **Servidor** | Proxmox LXC + Nginx + PM2 |

---

## 📁 Estructura del Repositori

```
Flow-Tracker/
├── backend/              # API REST Node.js
│   ├── src/
│   │   ├── routes/       # Endpoints (/auth, /habits, /feed, /friends, /profile)
│   │   ├── middleware/   # auth.js (JWT), validation.js
│   │   └── server.js     # Punt d'entrada
│   └── prisma/
│       ├── schema.prisma # Esquema de la BD
│       └── migrations/   # Historial de migracions
│
├── frontend/             # App Flutter
│   └── lib/
│       ├── views/        # Pantalles
│       ├── providers/    # Gestió d'estat (Provider)
│       ├── services/     # Crides a l'API
│       └── config/       # Tema, configuració
│
└── docs/                 # Documentació completa
    ├── README.md                          # Índex de documentació
    ├── arquitectura_i_disseny.md          # Arquitectura, decisions, dificultats
    ├── manual_desplegament.md             # Manual de desplegament
    ├── frontend_docs.md                   # Documentació del Frontend
    ├── backend_api_docs.md                # Referència API REST
    └── flow_tracker_planificacio_final.docx.md  # Planificació i sprints
```

---

## 🚀 Posada en Marxa Local

### Backend

```bash
cd backend
npm install
# Crear .env amb DATABASE_URL i JWT_SECRET
npx prisma migrate dev
npm run dev
# API disponible a http://localhost:3001
```

### Frontend

```bash
cd frontend
flutter pub get
flutter run -d windows   # Windows
flutter run -d chrome    # Web
```

---

## 🌍 Accés en Producció

| Servei | URL |
|--------|-----|
| **App Web** | http://ieticloudpro.ieti.cat |
| **API** | http://ieticloudpro.ieti.cat/api |
| **Health Check** | http://ieticloudpro.ieti.cat/health |

---

## 📚 Documentació

Tota la documentació del projecte es troba a la carpeta [`/docs`](./docs/):

- **[Índex de documentació](./docs/README.md)**
- **[Arquitectura i Disseny](./docs/arquitectura_i_disseny.md)** — Decisions tècniques, dificultats trobades, desviacions
- **[Manual de Desplegament](./docs/manual_desplegament.md)** — Guia pas a pas per desplegar al servidor
- **[Documentació Frontend](./docs/frontend_docs.md)** — Estructura Flutter, providers, pantalles
- **[Referència API REST](./docs/backend_api_docs.md)** — Tots els endpoints documentats

---

*Flow-Tracker v1.0 — Denis FV — DAM AMS2 — IETI — MP13 Crèdit de Síntesi — Maig 2026*