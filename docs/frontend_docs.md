# Flow-Tracker — Documentació del Frontend (Flutter)

**DAM AMS2 · MP13 Projecte · Crèdit de Síntesi — Maig 2026**

---

## 1. Tecnologia i Requisits

| Element | Detall |
|---------|--------|
| **Framework** | Flutter 3.x (Dart) |
| **Plataformes suportades** | Windows (debug/release), Android (APK), Web |
| **Flutter SDK mínim** | 3.0.0 |
| **Dart SDK** | inclòs amb Flutter |
| **IDE recomanat** | VS Code + extensió Flutter / Android Studio |

### Instal·lació de l'Entorn de Desenvolupament

```bash
# 1. Descarregar Flutter SDK: https://flutter.dev/docs/get-started/install
# 2. Afegir Flutter al PATH del sistema
# 3. Verificar la instal·lació:
flutter doctor

# 4. Clonar el repositori:
git clone https://github.com/DenisFV05/Flow-Tracker.git
cd Flow-Tracker/frontend

# 5. Instal·lar dependències:
flutter pub get

# 6. Executar en Windows:
flutter run -d windows

# 7. Executar al navegador:
flutter run -d chrome
```

---

## 2. Estructura de Fitxers

```
frontend/lib/
├── main.dart               # Punt d'entrada. Inicialitza providers i ruta inicial
├── screens.dart            # Exportacions de pantalles
├── sidebar.dart            # Barra de navegació lateral
│
├── config/
│   ├── app_config.dart     # Configuració global (URL API, token JWT)
│   └── app_theme.dart      # Tema visual (colors, tipografia, extensions de context)
│
├── models/
│   └── habit.dart          # Model de dades Habit
│
├── providers/              # Gestió d'estat (ChangeNotifier)
│   ├── habitProvider.dart       # Estat dels hàbits: llista, toggles, estadístiques
│   ├── feedProvider.dart        # Estat del feed: posts, likes, paginació
│   ├── profileProvider.dart     # Estat del perfil i amics
│   ├── theme_provider.dart      # Mode clar/fosc
│   └── notifications_provider.dart  # Notificacions
│
├── services/               # Capes d'accés a l'API
│   ├── habit_service.dart       # Crides a /api/habits
│   ├── feed_service.dart        # Crides a /api/feed
│   ├── friends_service.dart     # Crides a /api/friends
│   └── notifications_service.dart  # Crides a /api/notifications
│
├── views/                  # Pantalles principals
│   ├── login_screen.dart        # Login + Registre
│   ├── mainScreen.dart          # Contenidor principal (layout amb sidebar)
│   ├── dashboardView.dart       # Dashboard: progrés d'avui + heatmap
│   ├── habitesView.dart         # Llista de tots els hàbits
│   ├── inputEstil.dart          # Formulari crear/editar hàbit
│   ├── feedView.dart            # Feed social
│   ├── amicsView.dart           # Amics i sol·licituds
│   └── perfilView.dart          # Perfil, stats, exportació CSV
│
├── utils/
│   └── date_utils.dart         # Utilitats de dates
│
└── widgets/                # Widgets reutilitzables
    ├── habits/
    │   ├── HabitCard.dart          # Targeta d'un hàbit (llista)
    │   ├── HabitDetailView.dart    # Detall d'hàbit: stats, gràfiques, heatmap
    │   └── HabitProgressWidget.dart
    └── ...
```

---

## 3. Configuració de l'API

La URL del backend es configura a `lib/config/app_config.dart`. Aquest fitxer carrega la configuració al inici de l'app i emmagatzema el token JWT.

```dart
// Exemple de app_config.dart (concepte simplificat):
class AppConfig extends ChangeNotifier {
  static final AppConfig instance = AppConfig._();
  String apiBaseUrl = 'http://localhost:3001'; // Canviar per producció
  String? token;
  bool get isAuthenticated => token != null;
}
```

Per canviar entre entorns (local/producció), modificar `apiBaseUrl`.

---

## 4. Gestió d'Estat (Providers)

L'estat global es gestiona amb el paquet `provider` (patró ChangeNotifier). Tots els providers s'inicialitzen a `main.dart` via `MultiProvider`.

### HabitProvider

Responsable de:
- Llista de hàbits de l'usuari (`List<Habit> habits`)
- Toggle de compliment diari d'un hàbit
- Estadístiques per hàbit
- CRUD de hàbits

```dart
// Exemple d'ús des d'un widget:
final provider = context.read<HabitProvider>();
await provider.toggleHabit(habitId, date, completed);
```

### FeedProvider

Responsable de:
- Llista de posts del feed (`feedPosts`)
- Paginació infinita per cursor (`feedNextCursor`)
- Crear posts (text i imatge)
- Donar/treure likes
- Eliminar posts propis

### ProfileProvider

Responsable de:
- Dades del perfil de l'usuari
- Llista d'amics
- Sol·licituds d'amistat rebudes/enviades
- Leaderboard entre amics

### ThemeProvider

Responsable de:
- Mode clar/fosc (`themeMode`)
- Persistència de la preferència de tema

---

## 5. Sistema de Tema i Colors

El sistema de tema es defineix completament a `lib/config/app_theme.dart`.

### Paleta de Colors Principal

| Token | Color | Ús |
|-------|-------|----|
| `AppTheme.primary` | `#5C6BC0` (Indigo) | Color principal, botons, accents |
| `AppTheme.secondary` | `#26C6DA` (Cyan) | Accents secundaris |
| `AppTheme.success` | `#66BB6A` (Green) | Confirmacions, hàbits completats |
| `AppTheme.warning` | `#FFA726` (Orange) | Advertències, assoliments |

### Extensions de Context

Per accedir a colors adaptats al tema actual des de qualsevol widget:

```dart
// Ús:
Container(color: context.surfaceColor)         // Fons targeta (blanc/gris fosc)
Container(color: context.surfaceLightColor)    // Fons subtil (gris molt clar/gris mig)
Icon(Icons.star, color: context.primaryColor)  // Color primari adaptat
```

Això permet que tota la UI es comporti correctament en mode clar i fosc sense if/else.

---

## 6. Autenticació i Flux de Sessió

```
App inicia
    │
    ▼
SplashScreen
    │
    ├── Token guardat? ──── SÍ ──▶ Carregar perfil
    │                                   │
    │                          Error o perfil buit?
    │                                   │
    │                         SÍ ──▶ LoginScreen
    │                         NO ──▶ MainScreen
    │
    └── NO ──▶ LoginScreen
```

El token JWT es guarda via `AppConfig` (SharedPreferences o similar) i s'envia automàticament a totes les crides de l'API com a header `Authorization: Bearer <token>`.

---

## 7. Pantalles Detallades

### Dashboard (`dashboardView.dart`)

- **Salutació dinàmica**: "Bon dia", "Bona tarda", "Bona nit" en funció de l'hora local del dispositiu
- **Progrés d'avui**: Llista d'hàbits amb checkbox. Tick verd quan está completat. S'actualitza en temps real.
- **Heatmap anual**: Visualització de l'activitat de l'any en curs per l'hàbit seleccionat, estil GitHub

### Detall d'Hàbit (`HabitDetailView.dart`)

- **Estadístiques**: Ratxa actual, ratxa màxima, dies totals, dies completats, tasa de compleció
- **Gràfica setmanal**: Últims 7 dies (fl_chart BarChart)
- **Gràfica mensual**: Últims 30 dies
- **Heatmap anual**: Tots els dies de l'any
- **Historial**: Llista de logs

### Feed Social (`feedView.dart`)

- **Compositor de posts**: Camp de text + adjunt d'imatge
- **Imatges**: S'envien com a Base64 embegut al contingut (`[IMG]...[/IMG]`)
- **Polling**: S'actualitza automàticament cada 30 segons
- **Paginació infinita**: Carrega més posts en fer scroll fins al final
- **Posts d'assoliment**: Estil daurat diferenciats dels posts manuals
- **Likes**: Tap a la icona de cor per donar/treure like
- **Eliminar**: Menú de 3 punts visible només als posts propis

### Perfil (`perfilView.dart`)

- **Avatar**: Es pot canviar amb imatge de la galeria (s'envia com a Base64)
- **Estadístiques globals**: Hàbits totals, dies completats, ratxa màxima, taxa de compleció
- **Exportació CSV**: Descàrrega directa d'un fitxer amb tot l'historial d'activitat
- **Mode clar/fosc**: Toggle al perfil

---

## 8. Compilació per Plataformes

### Windows (Debug — per a proves)

```bash
flutter run -d windows
```

### Windows (Release — per a distribució)

```bash
flutter build windows --release
# Resultat: build/windows/x64/runner/Release/flow_tracker.exe
```

### Web (Production)

```bash
flutter build web --release
# Resultat: build/web/ (carpeta completa per al servidor)
```

### Android APK

```bash
# Requereix Android SDK
flutter build apk --release
# Resultat: build/app/outputs/flutter-apk/app-release.apk
```

---

## 9. Dependències Principals

| Paquet | Versió | Ús |
|--------|--------|----|
| `provider` | ^6.x | Gestió d'estat global |
| `http` | ^1.x | Crides HTTP a l'API |
| `fl_chart` | ^0.x | Gràfiques (barres, heatmap) |
| `file_picker` | ^8.x | Selecció de fitxers/imatges |
| `shared_preferences` | ^2.x | Persistència local (token, tema) |

---

## 10. Configuració per Plataforma

### Web — `web/index.html`

```html
<title>Flow-Tracker</title>
<meta name="description" content="Flow-Tracker — Tracker de Hàbits i Xarxa Social">
```

### Android — `android/app/src/main/AndroidManifest.xml`

```xml
<application android:label="Flow-Tracker" ...>
```

Permisos necessaris (declarats al manifest):
- `INTERNET` — per a les crides a l'API

### Windows — `windows/CMakeLists.txt`

```cmake
set(BINARY_NAME "flow_tracker")
set(APPLICATION_ID "com.ieti.flow-tracker")
```

### Windows — `windows/runner/main.cpp`

```cpp
// Títol de la finestra
CreateAndShow(L"Flow-Tracker");
```

---

*Flow-Tracker v1.0 — DAM AMS2 — MP13 Crèdit de Síntesi — Maig 2026*
