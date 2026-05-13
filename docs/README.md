# Flow-Tracker — Documentació del Projecte

**Tracker de Hàbits i Xarxa Social** | DAM AMS2 · MP13 Projecte · Crèdit de Síntesi
**Presentació:** 15 de Maig 2026

---

## Índex de Documentació

| Fitxer | Contingut |
|--------|-----------|
| [README.md](./README.md) | Aquest fitxer: índex i visió general |
| [arquitectura_i_disseny.md](./arquitectura_i_disseny.md) | Disseny, arquitectura, decisions tècniques, dificultats |
| [manual_desplegament.md](./manual_desplegament.md) | Manual complet de desplegament al servidor |
| [frontend_docs.md](./frontend_docs.md) | Documentació de l'aplicació Flutter |
| [backend_api_docs.md](./backend_api_docs.md) | Referència completa de l'API REST |
| [flow_tracker_planificacio_final.docx.md](./flow_tracker_planificacio_final.docx.md) | Backlog, sprints i calendarització del projecte |
| [preproyecto_flow_tracker.md](./preproyecto_flow_tracker.md) | Pre-projecte original |

---

## Descripció General

**Flow-Tracker** és una aplicació de seguiment de hàbits amb component social. Permet als usuaris:

- 🎯 **Crear i gestionar hàbits** amb etiquetes personalitzades
- ✅ **Registrar el compliment diari** de cada hàbit
- 📊 **Visualitzar estadístiques** (ratxes, taxes de compleció, heatmaps anuals)
- 👥 **Connectar amb amics** i veure el seu progrés
- 📣 **Feed social** amb publicacions i assoliments automàtics
- 📤 **Exportar dades** en format CSV

---

## Pila Tecnològica

| Capa | Tecnologia |
|------|-----------|
| **Frontend** | Flutter (Dart) — multiplataforma: Windows, Android, Web |
| **Backend** | Node.js + Express.js |
| **Base de Dades** | PostgreSQL + Prisma ORM |
| **Autenticació** | JWT (JSON Web Tokens) + bcrypt |
| **Desplegament** | Proxmox LXC + Nginx + PM2 |
| **Control de versió** | Git / GitHub |

---

## Estructura del Repositori

```
Flow-Tracker/
├── backend/          # API REST Node.js
│   ├── src/
│   │   ├── routes/   # Endpoints de l'API
│   │   ├── middleware/  # Auth, validació
│   │   └── server.js
│   └── prisma/       # Esquema i migracions de BD
├── frontend/         # App Flutter
│   └── lib/
│       ├── views/    # Pantalles de l'app
│       ├── providers/  # Gestió d'estat (Provider)
│       ├── services/ # Crides a l'API
│       └── widgets/  # Components reutilitzables
└── docs/             # Tota la documentació
```

---

*Flow-Tracker v1.0 — DAM AMS2 — MP13 Crèdit de Síntesi — Maig 2026*
