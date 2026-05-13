# Flow-Tracker — Documentació Tècnica del Backend

**Versió:** 1.0 | **Tecnologia:** Node.js + Express + Prisma + PostgreSQL | **Entorn de producció:** Proxmox (LXC)

---

## 1. Arquitectura General

```
frontend (Flutter)
        │  HTTP + JWT
        ▼
  Nginx (reverse proxy :80/:443)
        │
        ▼
  Node.js / Express (port 3000)
        │
  ┌─────┴──────┐
  │  Middleware │  helmet · cors · auth (JWT) · validation (express-validator)
  └─────┬──────┘
        │
  ┌─────┴──────────────────────────────┐
  │           Routers                  │
  │  /api/auth  /api/habits            │
  │  /api/tags  /api/profile           │
  │  /api/friends  /api/feed           │
  └─────┬──────────────────────────────┘
        │
  Prisma ORM
        │
  PostgreSQL
```

### Fitxers principals

| Fitxer | Responsabilitat |
|--------|----------------|
| `src/server.js` | Punt d'entrada, middlewares globals, gestió d'errors |
| `src/prisma.js` | Instància singleton del PrismaClient |
| `src/middleware/auth.js` | Verifica JWT i carrega `req.user` |
| `src/middleware/validation.js` | Validació d'entrades amb express-validator |
| `src/routes/auth.routes.js` | Registre, login |
| `src/routes/habits.routes.js` | CRUD hàbits, logs, estadístiques |
| `src/routes/tags.routes.js` | CRUD tags de l'usuari |
| `src/routes/profile.routes.js` | Perfil propi i d'amics |
| `src/routes/friends.routes.js` | Sistema d'amistats |
| `src/routes/feed.routes.js` | Feed social, likes |
| `prisma/schema.prisma` | Esquema de la base de dades |

---

## 2. Variables d'Entorn (`.env`)

```env
DATABASE_URL="postgresql://user:password@localhost:5432/flowtracker"
JWT_SECRET="clau_secreta_molt_llarga"
PORT=3000
NODE_ENV=production
ALLOWED_ORIGINS="http://localhost,https://tudomini.com"
```

---

## 3. Esquema de la Base de Dades

```
User ──< Habit ──< ActivityLog
  │
  ├──< Tag >──< Habit        (relació M:N)
  ├──< Friendship
  ├──< Post ──< Like
  └──< Like
```

### Models Prisma

**User** — `id, name, username (unique), email (unique), password (bcrypt), role, avatar?, createdAt, updatedAt`

**Habit** — `id, name, description?, userId, tags[], logs[], createdAt, updatedAt`

**ActivityLog** — `id, habitId, userId, date (Date), completed (bool)` — Restricció única `[habitId, date]`

**Tag** — `id, name, userId` — Restricció única `[name, userId]`

**Friendship** — `id, requesterId, receiverId, status (pending|accepted|rejected)` — Restricció única `[requesterId, receiverId]`

**Post** — `id, userId, type (achievement|manual), content?, habitId?, likes[], createdAt`

**Like** — `id, userId, postId` — Restricció única `[userId, postId]`

---

## 4. Autenticació

Totes les rutes (excepte `/api/auth/*` i `/health`) requereixen el header:

```
Authorization: Bearer <JWT_TOKEN>
```

El token JWT té una caducitat de **24 hores** i conté `{ userId, email }`.

El middleware `auth.js` verifica el token, consulta l'usuari a la BD, i injecta `req.user` (objecte User complet).

---

## 5. Referència de l'API

### 5.1 Autenticació — `/api/auth`

#### `POST /api/auth/register`
Crea un nou compte d'usuari.

**Body:**
```json
{
  "email": "usuari@exemple.com",
  "password": "minim6cars",
  "name": "Nom Complet",
  "username": "nomdusuari"
}
```

**Respostes:**
- `201 Created` — `{ id, email, name, username }`
- `400` — Email ja existent / Username ja pres / Validació fallida
- `500` — Error de servidor

---

#### `POST /api/auth/login`
Inicia sessió i retorna un token JWT.

**Body:**
```json
{
  "email": "usuari@exemple.com",
  "password": "lacontrasenya"
}
```

**Resposta `200 OK`:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": { "id", "email", "name", "username" }
}
```

- `401` — Credencials incorrectes

---

#### `GET /api/auth/profile` 🔒
Retorna les dades bàsiques de l'usuari autenticat (des del token).

**Resposta `200`:** `{ user: { id, email, ... } }`

---

### 5.2 Hàbits — `/api/habits` 🔒

#### `GET /api/habits`
Llista tots els hàbits de l'usuari autenticat, inclou tags.

**Resposta `200`:**
```json
[
  {
    "id": "uuid",
    "name": "Córrer",
    "description": "30 min al matí",
    "userId": "uuid",
    "tags": [{ "id": "uuid", "name": "esport" }],
    "createdAt": "2026-03-05T...",
    "updatedAt": "2026-03-05T..."
  }
]
```

---

#### `POST /api/habits`
Crea un nou hàbit. Si els tags no existeixen, els crea automàticament.

**Body:**
```json
{
  "name": "Meditar",
  "description": "10 minuts cada dia",
  "tags": ["mindfulness", "salut"]
}
```

**Resposta `201`:** Objecte Habit complet amb tags.

- `400` — Nom buit

---

#### `GET /api/habits/:id`
Retorna un hàbit específic de l'usuari.

- `404` — No trobat o no pertany a l'usuari

---

#### `PUT /api/habits/:id`
Actualitza nom, descripció i/o tags d'un hàbit. Els tags es substitueixen completament (operació `set`).

**Body:** (tots opcionals)
```json
{
  "name": "Nou nom",
  "description": "Nova descripció",
  "tags": ["tag1", "tag2"]
}
```

**Resposta `200`:** Hàbit actualitzat.

---

#### `DELETE /api/habits/:id`
Elimina un hàbit i tots els seus registres (ActivityLog) en cascada.

**Resposta `200`:** `{ "message": "Habit deleted successfully" }`

---

#### `POST /api/habits/:id/log`
Registra o actualitza el compliment d'un hàbit per a una data concreta (upsert). Si s'arriba a un fita de ratxa (7, 14, 30, 60, 90, 180, 365 dies), es crea un Post d'assoliment automàticament al feed.

**Body:**
```json
{
  "date": "2026-05-08",
  "completed": true
}
```

**Resposta `200`:** Objecte ActivityLog.

- `400` — Data requerida
- `404` — Hàbit no trobat

---

#### `DELETE /api/habits/:id/log/:date`
Elimina el registre d'un hàbit per a una data concreta.

**Resposta `200`:** `{ "message": "Log deleted successfully" }`

---

#### `GET /api/habits/:id/logs`
Obté tots els registres d'un hàbit. Suporta filtratge per dates.

**Query params (opcionals):**
- `startDate` — Data mínima (ISO 8601)
- `endDate` — Data màxima (ISO 8601)

**Resposta `200`:** Array d'ActivityLog ordenat per data descendent.

---

#### `GET /api/habits/:id/stats`
Estadístiques de compliment d'un hàbit concret.

**Resposta `200`:**
```json
{
  "habitId": "uuid",
  "currentStreak": 7,
  "maxStreak": 14,
  "totalDays": 30,
  "completedDays": 22,
  "completionRate": 73.3,
  "lastCompletedDate": "2026-05-08"
}
```

---

#### `GET /api/habits/:id/heatmap`
Dades de compliment de tot un any, en format compatible amb heatmaps estil GitHub.

**Query params (opcionals):**
- `year` — Any (per defecte: any actual)

**Resposta `200`:**
```json
{
  "habitId": "uuid",
  "year": 2026,
  "data": [
    { "date": "2026-01-01", "completed": false },
    { "date": "2026-01-02", "completed": true },
    ...
  ]
}
```

---

#### `GET /api/habits/:id/weekly`
Dades dels últims 7 dies (avui inclòs).

**Resposta `200`:**
```json
{
  "habitId": "uuid",
  "days": [
    { "date": "2026-05-02", "completed": false },
    ...
    { "date": "2026-05-08", "completed": true }
  ]
}
```

---

#### `GET /api/habits/:id/monthly`
Dades dels últims 30 dies.

**Resposta `200`:** Mateixa estructura que `/weekly` però amb 30 elements.

---

### 5.3 Tags — `/api/tags` 🔒

#### `GET /api/tags`
Llista tots els tags de l'usuari, ordenats alfabèticament.

**Resposta `200`:** `[{ "id", "name", "userId" }]`

---

#### `POST /api/tags`
Crea un nou tag. Evita duplicats per usuari.

**Body:** `{ "name": "fitness" }`

**Resposta `201`:** `{ id, name, userId }`

- `400` — Tag ja existent

---

#### `DELETE /api/tags/:id`
Elimina un tag de l'usuari.

- `404` — No trobat o no pertany a l'usuari

---

### 5.4 Perfil — `/api/profile` 🔒

#### `GET /api/profile`
Retorna les dades del perfil de l'usuari autenticat.

**Resposta `200`:**
```json
{
  "id": "uuid",
  "name": "Nom",
  "username": "nomdusuari",
  "email": "mail@exemple.com",
  "avatar": "https://... o data:image/png;base64,...",
  "createdAt": "2026-03-05T..."
}
```

---

#### `PUT /api/profile`
Actualitza nom i/o avatar de l'usuari. L'avatar pot ser una URL o un string Base64 (`data:image/...`).

**Body:** (tots opcionals)
```json
{
  "name": "Nou Nom",
  "avatar": "https://exemple.com/foto.jpg"
}
```

**Resposta `200`:** Perfil actualitzat.

---

#### `GET /api/profile/stats`
Retorna estadístiques globals de l'usuari i el progrés d'avui.

**Resposta `200`:**
```json
{
  "totalHabits": 5,
  "totalLogs": 120,
  "completedLogs": 87,
  "overallCompletionRate": 72.5,
  "longestStreak": 14,
  "todayCompleted": 3,
  "todayTotal": 4
}
```

---

#### `GET /api/profile/:id`
Retorna el perfil públic d'un amic (verificació d'amistat). Inclou estadístiques de l'amic.

- `400` — Si s'intenta accedir al perfil propi per aquesta ruta
- `403` — Si no sou amics
- `404` — Usuari no trobat

**Resposta `200`:** `{ id, name, username, avatar, createdAt, totalHabits, overallCompletionRate, longestStreak, ... }`

---

### 5.5 Amistats — `/api/friends` 🔒

#### `GET /api/friends/search?q=<query>`
Cerca usuaris per username, email o nom. Retorna si ja sou amics o si ja hi ha una sol·licitud enviada.

**Query params:** `q` (mínim 2 caràcters)

**Resposta `200`:**
```json
[
  {
    "id": "uuid",
    "username": "amic1",
    "name": "Nom Amic",
    "avatar": null,
    "isFriend": false,
    "requestSent": true
  }
]
```

---

#### `GET /api/friends`
Llista tots els amics acceptats de l'usuari.

**Resposta `200`:**
```json
[
  {
    "friendshipId": "uuid",
    "friend": { "id", "username", "name", "avatar" },
    "since": "2026-04-01T..."
  }
]
```

---

#### `GET /api/friends/requests`
Llista les sol·licituds d'amistat rebudes i pendents.

**Resposta `200`:** `[{ "id", "user": { id, username, name, avatar }, "createdAt" }]`

---

#### `GET /api/friends/sent`
Llista les sol·licituds d'amistat enviades i pendents.

---

#### `POST /api/friends/request`
Envia una sol·licitud d'amistat per username.

**Body:** `{ "username": "nomdusuari" }`

**Resposta `201`:** `{ id, status: "pending" }`

- `400` — Ja amics / Sol·licitud ja enviada / Un mateix
- `404` — Usuari no trobat

---

#### `PUT /api/friends/request/:id`
Accepta o rebutja una sol·licitud d'amistat rebuda.

**Body:** `{ "action": "accept" | "reject" }`

**Resposta `200`:** `{ id, status: "accepted" | "rejected" }`

- `400` — Acció invàlida
- `404` — Sol·licitud no trobada

---

#### `DELETE /api/friends/:id`
Elimina una amistat existent (per `friendshipId`).

**Resposta `200`:** `{ "message": "Friend removed successfully" }`

---

### 5.6 Feed Social — `/api/feed` 🔒

#### `GET /api/feed`
Obté el feed de publicacions de l'usuari i els seus amics (ordre cronològic invers). Suporta paginació per cursor.

**Query params (opcionals):**
- `limit` — Nombre de posts (per defecte: 20)
- `cursor` — Data ISO del darrer post rebut (per paginar)

**Resposta `200`:**
```json
{
  "posts": [
    {
      "id": "uuid",
      "user": { "id", "username", "name", "avatar" },
      "type": "achievement",
      "content": "7 días seguidos de Córrer!",
      "habitId": "uuid",
      "habitName": "Córrer",
      "createdAt": "2026-05-08T...",
      "liked": false,
      "isOwn": true
    }
  ],
  "nextCursor": "2026-05-01T12:00:00.000Z"
}
```

> **Nota:** Si `nextCursor` és `null`, no hi ha més posts.

---

#### `POST /api/feed`
Crea una publicació manual de tipus `manual`.

**Body:** `{ "content": "Avui he superat el meu rècord!" }`

**Resposta `201`:** Post creat.

---

#### `GET /api/feed/:id/likes`
Llista els usuaris que han donat like a un post.

**Resposta `200`:** `[{ id, user: { id, username, name, avatar }, createdAt }]`

---

#### `POST /api/feed/:id/like`
Dona like a un post.

**Resposta `201`:** Objecte Like.

- `400` — Ja has donat like

---

#### `DELETE /api/feed/:id/like`
Treu el like d'un post.

**Resposta `200`:** `{ "message": "Like removed" }`

---

#### `DELETE /api/feed/:id`
Elimina un post propi. Només el propietari del post pot eliminar-lo.

**Resposta `200`:** `{ "message": "Publicació eliminada" }`

- `403` — No ets el propietari del post
- `404` — Post no trobat

---

## 6. Endpoint especial: Health Check

#### `GET /health`
No requereix autenticació. Útil per a monitoring i verificar que el servidor funciona.

**Resposta `200`:** `{ "status": "ok", "timestamp": "2026-05-08T21:00:00.000Z" }`

---

## 7. Lògica de Negoci Clau

### Càlcul de Ratxes

La funció `calculateStreak(logs)` calcula la ratxa actual:
1. Filtra només els logs `completed = true`
2. Ordena les dates de més recent a més antiga
3. Comprova si el primer dia és avui o ahir (si no, ratxa = 0)
4. Compta dies consecutius cap enrere

La funció `calculateMaxStreak(logs)` calcula la ratxa màxima histèrica de forma similar però recorrent tota la llista.

### Assoliments Automàtics al Feed

Quan es fa un `POST /api/habits/:id/log` amb `completed: true`, el sistema:
1. Calcula la ratxa anterior
2. Guarda el nou log
3. Recalcula la nova ratxa
4. Si la nova ratxa és un dels **milestones** `[7, 14, 30, 60, 90, 180, 365]` dies i és major que l'anterior, crea automàticament un `Post` de tipus `achievement` al feed de l'usuari.

### Paginació del Feed per Cursor

El feed usa paginació per cursor (cursor-based pagination) en lloc de paginació per offset. El `cursor` és la data de creació (`createdAt`) del darrer post rebut. Això evita duplicats quan es creen posts nous entre pàgines.

---

## 8. Gestió d'Errors

El servidor té un middleware d'errors global que captura:

| Tipus d'error | Codi HTTP | Resposta |
|---------------|-----------|----------|
| JSON invàlid al body | 400 | `{ "error": "Invalid JSON in request body" }` |
| Error Prisma (BD) | 400 | `{ "error": "Database error", "code": "P2002" }` |
| Error validació Prisma | 400 | `{ "error": "Invalid request data" }` |
| Qualsevol altre error | 500 | `{ "error": "Internal server error" }` |
| Ruta no trobada | 404 | `{ "error": "Not found" }` |

---

## 9. Instal·lació i Posada en Marxa

### Prerequisits
- Node.js >= 18
- PostgreSQL >= 14
- npm >= 9

### Instal·lació local

```bash
# 1. Clonar el repositori
git clone https://github.com/DenisFV05/Flow-Tracker.git
cd Flow-Tracker/backend

# 2. Instal·lar dependències
npm install

# 3. Configurar variables d'entorn
cp .env.example .env
# Editar .env amb les credencials de la BD i JWT_SECRET

# 4. Crear i migrar la base de dades
npx prisma migrate dev --name init

# 5. Generar el client Prisma
npx prisma generate

# 6. Arrencar el servidor de desenvolupament
npm run dev
```

### Desplegament en Producció (Proxmox / LXC)

```bash
# 1. Instal·lar dependències de producció
npm install --omit=dev

# 2. Aplicar migracions a producció
npx prisma migrate deploy

# 3. Arrencar amb PM2
pm2 start src/server.js --name flow-tracker-api
pm2 save
pm2 startup

# 4. Verificar que funciona
curl http://localhost:3001/health
```

### Configuració Nginx (exemple)

```nginx
server {
    listen 80;
    server_name tudomini.com;
    client_max_body_size 20M;

    location /api/ {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Authorization $http_authorization;
    }

    location /health {
        proxy_pass http://localhost:3001/health;
    }
}
```

---

## 10. Dependències Principals

| Paquet | Versió | Ús |
|--------|--------|-----|
| `express` | ^5.x | Framework HTTP |
| `@prisma/client` | ^5.x | ORM per PostgreSQL |
| `bcrypt` | ^6.x | Hash de contrasenyes |
| `jsonwebtoken` | ^9.x | Generació i verificació de JWT |
| `express-validator` | ^7.x | Validació d'entrades |
| `helmet` | ^8.x | Headers de seguretat HTTP |
| `cors` | ^2.x | Control d'origen creuat (CORS) |
| `hpp` | ^0.x | Protecció contra HTTP Parameter Pollution |
| `dotenv` | ^17.x | Variables d'entorn |

---

*Documentació actualitzada el 13/05/2026 — Flow-Tracker v1.0 — DAM AMS2 — MP13 Crèdit de Síntesi*


#### `GET /health`
No requereix autenticació. Útil per a monitoring i verificar que el servidor funciona.

**Resposta `200`:** `{ "status": "ok", "timestamp": "2026-05-08T21:00:00.000Z" }`

---

## 7. Lògica de Negoci Clau

### Càlcul de Ratxes

La funció `calculateStreak(logs)` calcula la ratxa actual:
1. Filtra només els logs `completed = true`
2. Ordena les dates de més recent a més antiga
3. Comprova si el primer dia és avui o ahir (si no, ratxa = 0)
4. Compta dies consecutius cap enrere

La funció `calculateMaxStreak(logs)` calcula la ratxa màxima histèrica de forma similar però recorrent tota la llista.

### Assoliments Automàtics al Feed

Quan es fa un `POST /api/habits/:id/log` amb `completed: true`, el sistema:
1. Calcula la ratxa anterior
2. Guarda el nou log
3. Recalcula la nova ratxa
4. Si la nova ratxa és un dels **milestones** `[7, 14, 30, 60, 90, 180, 365]` dies i és major que l'anterior, crea automàticament un `Post` de tipus `achievement` al feed de l'usuari.

### Paginació del Feed per Cursor

El feed usa paginació per cursor (cursor-based pagination) en lloc de paginació per offset. El `cursor` és la data de creació (`createdAt`) del darrer post rebut. Això evita duplicats quan es creen posts nous entre pàgines.

---

## 8. Gestió d'Errors

El servidor té un middleware d'errors global que captura:

| Tipus d'error | Codi HTTP | Resposta |
|---------------|-----------|----------|
| JSON invàlid al body | 400 | `{ "error": "Invalid JSON in request body" }` |
| Error Prisma (BD) | 400 | `{ "error": "Database error", "code": "P2002" }` |
| Error validació Prisma | 400 | `{ "error": "Invalid request data" }` |
| Qualsevol altre error | 500 | `{ "error": "Internal server error" }` |
| Ruta no trobada | 404 | `{ "error": "Not found" }` |

---

## 9. Instal·lació i Posada en Marxa

### Prerequisits
- Node.js >= 18
- PostgreSQL >= 14
- npm >= 9

### Instal·lació local

```bash
# 1. Clonar el repositori
git clone https://github.com/DenisFV05/Flow-Tracker.git
cd Flow-Tracker/backend

# 2. Instal·lar dependències
npm install

# 3. Configurar variables d'entorn
cp .env.example .env
# Editar .env amb les credencials de la BD i JWT_SECRET

# 4. Crear i migrar la base de dades
npx prisma migrate dev --name init

# 5. Generar el client Prisma
npx prisma generate

# 6. Arrencar el servidor de desenvolupament
npm run dev
```

### Desplegament en Producció (Proxmox / LXC)

```bash
# 1. Instal·lar dependències de producció
npm install --omit=dev

# 2. Aplicar migracions a producció
npx prisma migrate deploy

# 3. Arrencar amb PM2
pm2 start src/server.js --name flow-tracker-api
pm2 save
pm2 startup

# 4. Verificar que funciona
curl http://localhost:3000/health
```

### Configuració Nginx (exemple)

```nginx
server {
    listen 80;
    server_name tudomini.com;

    location /api/ {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Authorization $http_authorization;
    }

    location /health {
        proxy_pass http://localhost:3000/health;
    }
}
```

---

## 10. Dependències Principals

| Paquet | Versió | Ús |
|--------|--------|----|
| `express` | ^4.x | Framework HTTP |
| `@prisma/client` | ^5.x | ORM per PostgreSQL |
| `bcrypt` | ^5.x | Hash de contrasenyes |
| `jsonwebtoken` | ^9.x | Generació i verificació de JWT |
| `express-validator` | ^7.x | Validació d'entrades |
| `helmet` | ^7.x | Headers de seguretat HTTP |
| `cors` | ^2.x | Control d'origen creuat (CORS) |
| `dotenv` | ^16.x | Variables d'entorn |

---

*Documentació generada el 08/05/2026 — Flow-Tracker v1.0 — DAM AMS2 — MP13 Crèdit de Síntesi*
