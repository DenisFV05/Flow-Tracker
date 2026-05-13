# Flow-Tracker — Guia del Desenvolupador

**DAM AMS2 · MP13 Projecte · Crèdit de Síntesi — Maig 2026**

Referència interna per a l'equip de desenvolupament. Explica com funciona tot plegat: on viu cada peça, com flueix la informació i per on cal passar quan s'afegeix o es modifica alguna funcionalitat.

---

## 1. Visió General de la Comunicació

```
Flutter (client)
    │
    │  HTTP/HTTPS + JWT header
    ▼
Nginx  (:80 → :443 via HTTPS, reverse proxy)
    │
    │  proxy_pass localhost:3001
    ▼
Express (Node.js, port 3001, gestionat per PM2)
    │
    ├─ Middlewares (ordre d'aplicació):
    │   1. helmet          → Headers de seguretat (CSP, HSTS, X-Frame-Options...)
    │   2. cors            → Filtra orígens permesos (ALLOWED_ORIGINS al .env)
    │   3. hpp             → Protecció contra duplicació de paràmetres HTTP
    │   4. express.json    → Parseja el body JSON (límit 8 MB per a Base64)
    │   5. morgan          → Log de peticions (format: [timestamp] METHOD /path)
    │   6. authMiddleware  → Verifica JWT i injecta req.user (per rutes protegides)
    │
    ├─ Routers:
    │   /api/auth      → auth.routes.js
    │   /api/habits    → habits.routes.js
    │   /api/tags      → tags.routes.js
    │   /api/profile   → profile.routes.js
    │   /api/friends   → friends.routes.js
    │   /api/feed      → feed.routes.js
    │   /health        → resposta directa (sense auth)
    │
    ▼
Prisma ORM → PostgreSQL (port 5432)
```

---

## 2. Autenticació: com funciona exactament

### Registre (`POST /api/auth/register`)

1. `validation.js` valida els camps (nom, email, username, password mínim 6 caràcters)
2. Es comprova que email i username no existeixin ja a la BD
3. La contrasenya es processa amb `bcrypt.hash(password, 10)`
4. Es crea l'usuari a la BD via Prisma
5. Es retorna `{ id, email, name, username }` (sense token — l'usuari ha de fer login)

### Login (`POST /api/auth/login`)

1. Es cerca l'usuari per email
2. `bcrypt.compare(password, hash)` verifica la contrasenya
3. Si és correcta: `jwt.sign({ userId, email }, JWT_SECRET, { expiresIn: '24h' })`
4. Es retorna `{ token, user: { id, email, name, username } }`

### Rutes protegides (`authMiddleware`)

El middleware `src/middleware/auth.js` s'aplica amb `router.use(authMiddleware)` a tots els routers excepte `/api/auth`.

Funcionament:
1. Extreu el token de `req.headers.authorization` (format `Bearer <token>`)
2. `jwt.verify(token, JWT_SECRET)` decodifica el payload
3. Consulta l'usuari complet a la BD: `prisma.user.findUnique({ where: { id: payload.userId } })`
4. Injecta `req.user` = objecte User complet (disponible a totes les rutes posteriors)
5. Si el token és invàlid o l'usuari no existeix → `401 Unauthorized`

---

## 3. Estructura del Frontend Flutter

### Punt d'entrada

```
lib/main.dart
  └─ MultiProvider (registra tots els Providers)
       └─ MaterialApp → MainScreen
```

### Navegació principal

`MainScreen` (`views/mainScreen.dart`) decideix quina pantalla mostrar:
- En pantalles grans (> 600px ample): mostra el `Sidebar` + el contingut principal (`ScreensExample`)
- En pantalles petites (mòbil): mostra un `Drawer` amb el `Sidebar` i un `AppBar` amb la icona de notificacions

`ScreensExample` (`screens.dart`) fa un `switch` sobre `controller.selectedIndex`:

```dart
case 0: DashboardView       // índex 0
case 1: StatsScreen         // índex 1
case 2: FeedView            // índex 2
case 3: NotificationsView   // índex 3
case 4: AmicsView           // índex 4
case 5: perfilView          // índex 5
```

El `Sidebar` (`sidebar.dart`) és un widget personalitzat (no usa el paquet `sidebarx` internament per al layout) que escolta el `SidebarXController` via `AnimatedBuilder`. Quan l'usuari prem un ítem, crida `controller.selectIndex(index)`.

### Patró Provider

Cada funcionalitat té el seu Provider que hereta de `ChangeNotifier`:

| Provider | Fitxer | Responsabilitat |
|----------|--------|----------------|
| `HabitProvider` | `providers/habitProvider.dart` | Llista d'hàbits, dashboard stats, toggle |
| `FeedProvider` | `providers/feedProvider.dart` | Posts, likes, paginació |
| `ProfileProvider` | `providers/profileProvider.dart` | Dades del perfil, stats globals |
| `ThemeProvider` | `providers/themeProvider.dart` | Mode clar/fosc, persistència |
| `NotificationsProvider` | `providers/notifications_provider.dart` | Notificacions, badge count |

Totes les crides HTTP passen per `ApiClient` (`services/api_client.dart`), que:
- Afegeix automàticament el header `Authorization: Bearer <token>`
- Parseja les respostes JSON
- Llança `Exception` amb el missatge d'error del servidor si el codi no és 2xx
- Gestiona errors de validació (array `errors[].msg`) i errors simples (`error`)

---

## 4. Flux Complet: Exemple amb "Marcar Hàbit com a Completat"

```
1. Usuari prem el toggle del HabitCard al DashboardView
2. DashboardView crida context.read<HabitProvider>().toggleHabit(habitId, completed)
3. HabitProvider crida ApiClient.post('/api/habits/$id/log', body: {date, completed})
4. ApiClient afegeix el JWT header i fa la petició HTTP
5. Nginx rep la petició → proxy a Express port 3001
6. authMiddleware verifica el JWT → injecta req.user
7. habits.routes.js rep la petició a POST /:id/log
8. Prisma fa un UPSERT a ActivityLog (crea o actualitza)
9. Si completed=true, recalcula la ratxa:
     a. Si nova ratxa és milestone → crea Post(type='achievement') + Notification
10. El servidor retorna l'objecte ActivityLog
11. HabitProvider actualitza l'estat local i crida notifyListeners()
12. DashboardView es reconstrueix amb el nou estat
```

---

## 5. Model de Dades: Prisma Schema

```prisma
model User {
  id        String   @id @default(uuid())
  name      String
  username  String   @unique
  email     String   @unique
  password  String   // bcrypt hash
  avatar    String?  // URL o Base64
  role      String   @default("user")
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  habits        Habit[]
  logs          ActivityLog[]
  tags          Tag[]
  posts         Post[]
  likes         Like[]
  friendsSent   Friendship[]   @relation("requester")
  friendsRecv   Friendship[]   @relation("receiver")
  notifications Notification[]
}

model Habit {
  id          String        @id @default(uuid())
  name        String
  description String?
  userId      String
  user        User          @relation(...)
  tags        Tag[]         // M:N via _HabitToTag
  logs        ActivityLog[]
  posts       Post[]
  createdAt   DateTime      @default(now())
  updatedAt   DateTime      @updatedAt
}

model ActivityLog {
  id        String   @id @default(uuid())
  habitId   String
  userId    String
  date      DateTime @db.Date
  completed Boolean  @default(true)

  @@unique([habitId, date])   // Un sol registre per hàbit per dia
}

model Tag {
  id     String  @id @default(uuid())
  name   String
  userId String
  habits Habit[]

  @@unique([name, userId])    // Tags únics per usuari
}

model Friendship {
  id          String @id @default(uuid())
  requesterId String
  receiverId  String
  status      String @default("pending")  // pending | accepted | rejected
  createdAt   DateTime @default(now())

  @@unique([requesterId, receiverId])
}

model Post {
  id          String   @id @default(uuid())
  userId      String
  type        String   // 'achievement' | 'manual'
  content     String?
  habitId     String?
  imageBase64 String?  // Imatge en Base64 (per a posts manuals)
  likes       Like[]
  createdAt   DateTime @default(now())
}

model Like {
  id     String @id @default(uuid())
  userId String
  postId String

  @@unique([userId, postId])  // Un like per usuari per post
}

model Notification {
  id        String   @id @default(uuid())
  userId    String
  type      String   // 'like' | 'friend_request' | 'achievement'
  message   String
  read      Boolean  @default(false)
  createdAt DateTime @default(now())
}
```

---

## 6. Com Afegir una Nova Funcionalitat

### Backend: Nou endpoint

1. Afegir la ruta al router corresponent o crear un nou fitxer `nova_funcio.routes.js`
2. Registrar el router a `server.js`: `app.use('/api/nova', require('./routes/nova_funcio.routes'))`
3. Si cal guardar dades noves: afegir el model a `schema.prisma` → `npx prisma migrate dev --name descripcio` → `npx prisma generate`
4. Al servidor de producció: `npx prisma migrate deploy` + `pm2 restart server`

### Frontend: Nova pantalla

1. Crear el fitxer a `lib/views/nova_pantalla.dart`
2. Si necessita dades externes: crear `lib/providers/nova_pantalla_provider.dart` i registrar-lo a `main.dart`
3. Afegir l'import i el `case N:` al `switch` de `screens.dart`
4. Afegir l'ítem corresponent a la llista `_items` de `sidebar.dart`
5. Afegir el títol a `_titles` de `mainScreen.dart`

> Important: els índexs de `_items` (sidebar), `_titles` (mainScreen) i els `case` (screens.dart) han de coincidir exactament.

---

## 7. Decisions de Disseny

### Per què no s'usa WebSocket per a les notificacions?

L'arquitectura actual fa **polling** cada 60 segons des del `NotificationsProvider`. Es va valorar usar WebSockets però es va descartar per:
- Complexitat addicional de gestió de connexions al servidor
- L'entorn Proxmox LXC no té configuració especial per a connexions persistents
- Per a la mida del projecte, el polling és suficient i simplifica el codi significativament

### Per què cursor-based pagination al feed?

La paginació tradicional per offset (`LIMIT x OFFSET y`) té un problema conegut: si es creen posts nous mentre l'usuari navega, els resultats es desplacen i es poden repetir posts o saltar-se'n. La paginació per cursor usa la data del darrer post rebut com a punt de tall, garantint resultats estables.

### Per què imatges en Base64 i no com a fitxers pujats?

Descartar el sistema de fitxers simplifica enormement el backend:
- No cal gestionar un directori de pujades, permisos, ni neteja de fitxers orfes
- L'imatge viatja com a part del JSON (un únic camp `imageBase64`)
- El límit de 8 MB al body de Express i a Nginx controla la mida màxima
- La contrapartida és que les respostes de l'API són més pesades

### Per què Provider i no Riverpod o Bloc?

Provider és el patró més senzill i el que el Flutter team recomana com a punt d'entrada. Per a la mida i complexitat d'aquest projecte, Provider és suficient. Riverpod i Bloc ofereixen avantatges (testabilitat, granularitat) que no compensen la corba d'aprenentatge addicional.

---

## 8. Desplegament Ràpid (Referència)

### Actualitzar el Backend (SSH)
```bash
cd /home/super/Flow-Tracker
git pull origin main
cd backend
npm install --omit=dev
npx prisma generate
pm2 restart server
pm2 logs server --lines 20
```

### Publicar Nova Versió Web (des del PC)
```powershell
cd frontend
flutter build web --release
Compress-Archive -Path build\web\* -DestinationPath flowtracker_web.zip -Force
scp -P 20127 flowtracker_web.zip flow-tracker@ieticloudpro.ieti.cat:/tmp/
```
```bash
# Al servidor SSH:
sudo unzip -o /tmp/flowtracker_web.zip -d ~/Flow-Tracker/frontend/frontend/build/web/
# Anti-cache:
sudo sed -i "s/flutter_bootstrap.js/flutter_bootstrap.js?v=$(date +%s)/g" ~/Flow-Tracker/frontend/frontend/build/web/index.html
```

### Publicar Nova APK (des del PC)
```powershell
cd frontend
flutter build apk --release
scp -P 20127 build\app\outputs\flutter-apk\app-release.apk flow-tracker@ieticloudpro.ieti.cat:~/Flow-Tracker/frontend/frontend/build/web/flow.apk
```

---

## 9. Variables d'Entorn de Producció

| Variable | Descripció |
|----------|-----------|
| `DATABASE_URL` | URL de connexió a PostgreSQL (format `postgresql://user:pass@localhost:5432/db`) |
| `JWT_SECRET` | Clau secreta per signar tokens JWT (mínim 32 caràcters) |
| `PORT` | Port on escolta Express (3001 en producció) |
| `NODE_ENV` | `production` o `development` |
| `ALLOWED_ORIGINS` | Llista d'orígens permesos per CORS, separats per comes |

> El fitxer `.env` mai s'ha de pujar al repositori. Està inclòs al `.gitignore`.

---

## 10. Eines de Diagnòstic

```bash
# Estat del servidor API
pm2 status
pm2 logs server --lines 50

# Verificar que l'API respon
curl https://flow-tracker.ieti.site/health

# Inspeccionar la base de dades
cd /home/super/Flow-Tracker/backend
npx prisma studio   # Obre una interfície web a localhost:5555

# Verificar Nginx
sudo nginx -t
sudo systemctl status nginx
sudo tail -f /var/log/nginx/error.log

# Verificar PostgreSQL
sudo systemctl status postgresql
psql -U flow_tracker -h localhost -d flowtracker -c "SELECT count(*) FROM \"User\";"
```

---

*Flow-Tracker v1.0 — DAM AMS2 — MP13 Crèdit de Síntesi — Maig 2026*
