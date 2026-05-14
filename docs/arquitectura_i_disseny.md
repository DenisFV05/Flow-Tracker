# Flow-Tracker — Arquitectura, Disseny i Decisions Tècniques

**DAM AMS2 · MP13 Projecte · Crèdit de Síntesi — Maig 2026**

---

## 1. Visió General del Projecte

Flow-Tracker neix com a resposta a una necessitat real: moltes apps de seguiment de hàbits són solitàries i avorridas. La nostra aposta ha estat combinar el **tracking personal** amb una **capa social lleugerada**, permetent als usuaris compartir els seus assoliments i competir amicalment amb els seus amics.

L'aplicació és **multiplataforma** (Windows, Android, Web) gràcies a Flutter, amb un backend centralitzat que serveix totes les plataformes.

---

## 2. Arquitectura del Sistema

### Diagrama de Capes

```
┌─────────────────────────────────────────────┐
│           Clients (Usuaris Finals)           │
│  ┌──────────┐  ┌──────────┐  ┌───────────┐  │
│  │ Windows  │  │ Android  │  │    Web    │  │
│  │ (Flutter)│  │ (Flutter)│  │ (Flutter) │  │
│  └────┬─────┘  └────┬─────┘  └─────┬─────┘  │
└───────┼─────────────┼──────────────┼─────────┘
        │             │              │
        └─────────────┼──────────────┘
                 HTTP + JWT
                      │
┌─────────────────────▼───────────────────────┐
│         Proxmox LXC (Ubuntu Server)          │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │    Nginx (Reverse Proxy :80/:443)    │   │
│  └──────────────────┬───────────────────┘   │
│                     │                        │
│  ┌──────────────────▼───────────────────┐   │
│  │   Node.js + Express (PM2, port 3001) │   │
│  │   ┌─────────────────────────────┐    │   │
│  │   │ Middleware: helmet, hpp,    │    │   │
│  │   │ cors, auth (JWT), validator │    │   │
│  │   └─────────────┬───────────────┘    │   │
│  │   ┌─────────────▼───────────────┐    │   │
│  │   │         API Routers         │    │   │
│  │   │ /auth /habits /tags         │    │   │
│  │   │ /profile /friends /feed     │    │   │
│  │   └─────────────┬───────────────┘    │   │
│  │   ┌─────────────▼───────────────┐    │   │
│  │   │       Prisma ORM            │    │   │
│  │   └─────────────┬───────────────┘    │   │
│  └─────────────────┼─────────────────────┘   │
│                    │                          │
│  ┌─────────────────▼───────────────────┐     │
│  │   PostgreSQL (port 5432)            │     │
│  └──────────────────────────────────────┘    │
└──────────────────────────────────────────────┘
```

### Flux d'una Petició Típica

```
1. Flutter envia HTTP + JWT Header
2. Nginx rep la petició i la redirigeix al port 3001
3. Express aplica middlewares (helmet, cors, hpp)
4. auth.js verifica el JWT i injecta req.user
5. El router corresponent processa la lògica
6. Prisma executa la consulta SQL segura
7. La resposta torna al client (JSON)
```

---

## 3. Disseny de la Base de Dades

### Diagrama Entitat-Relació

```
┌───────────────────┐          ┌───────────────────┐          ┌────────────────────────┐
│       User        │──1:N────▶│       Habit        │──1:N────▶│      ActivityLog       │
│                   │          │                   │          │                        │
│ id (uuid, PK)     │          │ id (uuid, PK)     │          │ id (uuid, PK)          │
│ name              │          │ name              │          │ habitId (FK→Habit)     │
│ username (unique) │          │ description?      │          │ userId  (FK→User)      │
│ email (unique)    │          │ userId (FK→User)  │          │ date    (@db.Date)     │
│ password (bcrypt) │          │ tags  (M:N)       │          │ completed (bool=false) │
│ avatar?           │          │ logs  (1:N)       │          │ createdAt              │
│ role (=user)      │          │ posts (1:N)       │          │                        │
│ createdAt         │          │ createdAt         │          │ UNIQUE[habitId, date]  │
│ updatedAt         │          │ updatedAt         │          └────────────────────────┘
└───────────────────┘          └───────────────────┘
         │
         ├──M:N────▶ ┌───────────────────┐
         │            │        Tag        │
         │            │ id (uuid, PK)     │
         │            │ name              │
         │            │ userId (FK→User)  │
         │            │ habits (M:N)      │
         │            │ UNIQUE[name,      │
         │            │        userId]    │
         │            └───────────────────┘
         │
         ├──1:N────▶ ┌───────────────────┐
         │            │    Friendship     │
         │            │ id (uuid, PK)     │
         │            │ requesterId       │  (FK→User)
         │            │ receiverId        │  (FK→User)
         │            │ status            │  pending|accepted|rejected
         │            │ createdAt         │
         │            │ updatedAt         │
         │            │ UNIQUE[requester  │
         │            │        ,receiver] │
         │            └───────────────────┘
         │
         ├──1:N────▶ ┌───────────────────┐    1:N    ┌──────────────────┐
         │            │       Post        │──────────▶│       Like       │
         │            │ id (uuid, PK)     │            │ id (uuid, PK)    │
         │            │ userId (FK→User)  │            │ userId (FK→User) │
         │            │ type              │            │ postId (FK→Post) │
         │            │  achievement|     │            │ createdAt        │
         │            │  manual           │            │ UNIQUE[userId,   │
         │            │ content?          │            │        postId]   │
         │            │ habitId? (FK→     │            └──────────────────┘
         │            │          Habit)   │
         │            │ createdAt         │
         │            └───────────────────┘
         │
         └──1:N────▶ ┌───────────────────┐
                      │   Notification    │
                      │ id (uuid, PK)     │
                      │ userId (FK→User)  │
                      │ type              │  like|friend_request|achievement
                      │ message           │
                      │ read (bool=false) │
                      │ createdAt         │
                      └───────────────────┘
```


### Decisions de Disseny de la BD

**IDs com a UUID:** Tots els models usen `@default(uuid())`. Decidit per:
- Impossibilitat d'endevinar IDs (seguretat)
- Compatibilitat amb sistemes distribuïts
- Evitar enumeració seqüencial d'usuaris o recursos

**`ActivityLog` amb restricció única `[habitId, date]`:** Garanteix que no hi pugui haver dos registres del mateix hàbit per al mateix dia. S'usa `upsert` per actualitzar o crear en una sola operació.

**`Friendship` amb restricció única `[requesterId, receiverId]`:** Evita duplicats. La lògica verifica les dues direccions possibles (`OR`) per assegurar que no es puguin crear dues relacions inverses.

**`Post.type` com a String en lloc d'Enum:** Es va optar per String (`'achievement'|'manual'`) per flexibilitat, en previsió de futurs tipus de publicació sense necessitat de migrar l'esquema.

---

## 4. Arquitectura del Frontend (Flutter)

### Patró d'Arquitectura: Provider + Service Layer

```
┌─────────────────────────────────────────┐
│               Views (UI)                │
│  dashboardView, feedView, perfilView... │
│       Llegeixen estat via context       │
└────────────────────┬────────────────────┘
                     │ watch / read
┌────────────────────▼────────────────────┐
│              Providers                  │
│  HabitProvider, FeedProvider,           │
│  ProfileProvider, ThemeProvider...      │
│    Gestionen estat i notifiquen UI      │
└────────────────────┬────────────────────┘
                     │ criden
┌────────────────────▼────────────────────┐
│             Services (API)              │
│  habit_service.dart, feed_service.dart  │
│  friends_service.dart...                │
│  Encapsulen les crides HTTP             │
└────────────────────┬────────────────────┘
                     │ HTTP + JWT
┌────────────────────▼────────────────────┐
│           Backend (API REST)            │
└─────────────────────────────────────────┘
```

### Pantalles Principals

| Vista | Descripció |
|-------|-----------|
| `login_screen.dart` | Login i Registre |
| `dashboardView.dart` | Resum diari: hàbits d'avui, progrés, heatmap |
| `habitesView.dart` | Llista i gestió de tots els hàbits |
| `HabitDetailView.dart` | Detall d'un hàbit: stats, gràfiques, historial |
| `feedView.dart` | Feed social, publicació de posts, likes |
| `amicsView.dart` | Gestió d'amics i sol·licituds |
| `perfilView.dart` | Perfil de l'usuari, estadístiques globals, exportació CSV |
| `inputEstil.dart` | Formulari de creació/edició d'hàbits |

### Gestió d'Estat

S'ha usat el paquet **Provider** (patró ChangeNotifier) per:
- **Senzillesa** i corba d'aprenentatge baixa
- **Integració nativa** amb Flutter
- **Escalabilitat suficient** per a la mida del projecte

Alternativa considerada: **Riverpod** — descartada per complexitat addicional innecessària.

### Tema i Colors

S'ha implementat un sistema de tema dual (clar/fosc) amb **extensions de context**:
- `AppTheme.lightTheme` i `AppTheme.darkTheme` definits centralment a `app_theme.dart`
- Extensions `context.surfaceColor`, `context.surfaceLightColor` per accedir a colors adaptats al tema des de qualsevol widget
- `ThemeProvider` gestiona el canvi de tema en calent, persistint la preferència

---

## 5. Decisions Tècniques Clau

### 5.1 Perquè Flutter?

- **Multiplataforma real:** Una sola base de codi per Windows, Android i Web
- **Rendiment natiu:** Compilació a codi natiu, no webview
- **Ecosistema ric:** fl_chart per gràfiques, file_picker per imatges, Provider per estat
- **Disseny consistent** entre totes les plataformes

### 5.2 Perquè Node.js + Express?

- **JavaScript full-stack:** Reutilització de coneixements i sintaxi similar
- **Velocitat de desenvolupament:** API funcional en hores, no dies
- **Ecosistema npm:** Accés fàcil a JWT, bcrypt, Prisma, etc.
- **Rendiment suficient** per a les necessitats del projecte

### 5.3 Perquè Prisma com a ORM?

- **Seguretat automàtica** contra SQL Injection (consultes parametritzades)
- **Type-safety** parcial a JavaScript
- **Migracions gestionades** amb `prisma migrate`
- **Prisma Studio** per inspeccionar la BD visualment durant el desenvolupament

### 5.4 Perquè PostgreSQL?

- **Robustesa** i maduresa del sistema
- **Restriccions d'integritat referencial** (FOREIGN KEY, UNIQUE)
- **Suport per a dades complexes** si el projecte creixés
- Familiar per a l'equip gràcies a formació prèvia

### 5.5 Autenticació amb JWT

- **Sense estat al servidor:** El token conté tota la informació necessària
- **Caducitat:** 24 hores, equilibri entre seguretat i comoditat
- **Doble canal:** Header `Authorization: Bearer` (app) i query param `?token=` (exportació CSV al navegador)

### 5.6 Paginació del Feed per Cursor

En lloc de paginació per offset (`LIMIT x OFFSET y`), s'usa **cursor-based pagination**:
- El `cursor` és la data (`createdAt`) del darrer post rebut
- **Avantatge:** Evita posts duplicats o omesos quan es creen nous posts entre càrregues successives
- **Ideal** per a feeds socials on el contingut canvia constantment

---

## 6. Mesures de Seguretat Implementades

| Mesura | Implementació | Protecció |
|--------|--------------|-----------|
| Hash de contrasenyes | `bcrypt` (salt rounds: 10) | Evita compromís en cas de filtratge de BD |
| Autenticació | JWT + `authMiddleware` en totes les rutes protegides | Accés no autoritzat |
| SQL Injection | Prisma ORM (consultes parametritzades) | Injecció de SQL maliciós |
| Headers HTTP | `helmet` (X-Frame-Options, CSP, HSTS...) | Clickjacking, XSS, sniffing |
| CORS | Orígens permesos via `ALLOWED_ORIGINS` en `.env` | Accés des d'orígens no autoritzats |
| HPP | `hpp` middleware | HTTP Parameter Pollution |
| Validació d'entrades | `express-validator` + UUID validation | Dades malformades o malicioses |
| Verificació de propietat | `where: { id, userId }` en totes les consultes | Accés a recursos d'altres usuaris |
| Limit de payload | `express.json({ limit: '8mb' })` | Atacs DoS per payloads gegants |

---

## 7. Dificultats Trobades i Solucions

### 7.1 Desincronització d'IDs (Tipus String vs Int)

**Problema:** Els IDs dels hàbits es passaven com a `int` en alguns llocs del frontend i com a `String` en altres, causant que els "ticks verds" del dashboard no s'actualitzessin correctament.

**Solució:** Normalitzar tots els IDs a `String` al frontend i usar `where: { id: habitId.toString() }` de forma consistent.

### 7.2 Error de CMake en Canviar Estructura de Carpetes

**Problema:** En moure el projecte Flutter de `frontend/frontend/` a `frontend/`, la CMake cache (`CMakeCache.txt`) guardava les rutes antigues i feia fallar la compilació Windows.

**Solució:** Eliminar manualment la carpeta `build/` i executar `flutter clean` + `flutter pub get` per forçar una reconfiguració completa.

### 7.3 Dates i Fusos Horaris (UTC vs Local)

**Problema:** El servidor guarda les dates en UTC. L'app mostrava salutacions incorrectes ("Bon dia" a les 2AM) i les ratxes no calculaven bé a certs fusos horaris.

**Solució:**
- Usar `DateTime.now().toLocal()` al frontend per a les salutacions
- Crear funcions `localDateStr()` al backend que treballen amb la data local del servidor
- Usar `@db.Date` a Prisma per guardar només la data (sense hora) a `ActivityLog`

### 7.4 Conflicte de Validació amb Imatges Base64 al Feed

**Problema:** En afegir validació de longitud màxima als posts (1000 caràcters), les imatges en Base64 (que poden tenir milers de caràcters) causaven errors `400`.

**Solució:** Augmentar el límit del validador a 10,000,000 caràcters (aprox. 10MB) i el límit del body de Express a 8MB per suportar imatges.

### 7.5 Rate Limiter i Polling del Feed

**Problema:** La app fa polling automàtic cada 30 segons i moltes peticions en paral·lel en iniciar (habits, perfil, feed...). Amb un límit de 100 peticions per 15 minuts, els usuaris veien l'error "Too many requests" en menys d'un minut d'ús normal.

**Solució:** Eliminar el rate limiter global (que donava falsos positius) i mantenir les altres mesures de seguretat (Helmet, HPP, validació d'entrades).

### 7.6 X-Forwarded-For i Trust Proxy

**Problema:** Amb Nginx com a proxy invers, `express-rate-limit` llançava errors de validació perquè detectava la capçalera `X-Forwarded-For` però Express no estava configurat per confiar en el proxy.

**Solució:** Afegir `app.set('trust proxy', 1)` per indicar a Express que confiï en el primer proxy (Nginx).

### 7.7 Branding i Noms de l'Aplicació

**Problema:** El projecte Flutter va ser iniciat amb el nom genèric `exercici09`. El títol de la finestra Windows, el nom de l'APK i el títol de la web web mostraven aquest nom.

**Solució:** Actualitzar manualment:
- `windows/CMakeLists.txt` → `set(BINARY_NAME "flow_tracker")`
- `windows/runner/main.cpp` → `L"Flow-Tracker"`
- `android/app/src/main/AndroidManifest.xml` → `android:label="Flow-Tracker"`
- `web/index.html` → `<title>Flow-Tracker</title>`

---

## 8. Desviacions Respecte la Planificació

| Tasca original | Estat | Observació |
|----------------|-------|-----------|
| B25 — APK Android | ✅ Compila | No s'ha distribuït (fora d'abast) |
| O01 — Likes al feed | ✅ Implementat | Opcional completat |
| O02 — Publicació manual al feed | ✅ Implementat | Inclou imatges |
| O03 — Mode clar/fosc | ✅ Implementat | Context-aware amb extensions |
| O04 — Exportació CSV | ✅ Implementat | Inclou metadades d'hàbits |
| O05 — Ranking entre amics | ✅ Implementat | Leaderboard amb ratxa màxima |
| Eliminar posts propis | ✅ Nou (no planificat) | Afegit a petició de l'usuari |
| Notificacions en temps real | Parcial | Polling cada 60s; notificacions de likes, amistats i assoliments implementades |
| Tests automatitzats | ❌ Parcial | Proves manuals realitzades |

**Resum:** El projecte ha superat les expectatives inicials. Tots els ítems opcionals han estat implementats, i s'han afegit funcionalitats addicionals no planificades (eliminació de posts, imatges al feed).

---

*Flow-Tracker v1.0 — DAM AMS2 — MP13 Crèdit de Síntesi — Maig 2026*

App en producció: https://flow-tracker.ieti.site
