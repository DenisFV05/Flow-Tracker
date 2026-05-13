# Flow-Tracker — Manual de Desplegament

**DAM AMS2 · MP13 Projecte · Crèdit de Síntesi — Maig 2026**

---

## Prerequisits del Servidor

| Requisit | Versió mínima | Verificació |
|----------|--------------|-------------|
| Ubuntu Server (LXC Proxmox) | 22.04 LTS | `lsb_release -a` |
| Node.js | 18.x | `node --version` |
| npm | 9.x | `npm --version` |
| PostgreSQL | 14.x | `psql --version` |
| Nginx | any | `nginx -v` |
| PM2 | any | `pm2 --version` |
| Git | any | `git --version` |

---

## 1. Configuració Inicial del Servidor (només primer cop)

### 1.1 Instal·lar Node.js 18

```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### 1.2 Instal·lar PostgreSQL

```bash
sudo apt install postgresql postgresql-contrib -y
sudo systemctl enable postgresql
sudo systemctl start postgresql
```

### 1.3 Crear la Base de Dades i l'Usuari

```bash
sudo -u postgres psql
```

```sql
CREATE USER flow_tracker WITH PASSWORD 'la_teva_contrasenya';
CREATE DATABASE flowtracker OWNER flow_tracker;
GRANT ALL PRIVILEGES ON DATABASE flowtracker TO flow_tracker;
\q
```

### 1.4 Instal·lar PM2 globalment

```bash
sudo npm install -g pm2
```

### 1.5 Instal·lar Nginx

```bash
sudo apt install nginx -y
sudo systemctl enable nginx
```

---

## 2. Desplegament del Backend

### 2.1 Clonar o Actualitzar el Repositori

```bash
# Primera vegada:
git clone https://github.com/DenisFV05/Flow-Tracker.git /home/flow-tracker/Flow-Tracker
cd /home/flow-tracker/Flow-Tracker

# Actualitzacions posteriors:
cd /home/flow-tracker/Flow-Tracker
git pull origin main
```

### 2.2 Configurar Variables d'Entorn

```bash
cd /home/flow-tracker/Flow-Tracker/backend
nano .env
```

Contingut del fitxer `.env`:

```env
DATABASE_URL="postgresql://flow_tracker:la_teva_contrasenya@localhost:5432/flowtracker"
JWT_SECRET="una_clau_molt_llarga_i_secreta_de_almenys_32_caracters"
PORT=3001
NODE_ENV=production
ALLOWED_ORIGINS="http://localhost,https://el-teu-domini.cat"
```

> [!IMPORTANT]
> El fitxer `.env` mai s'ha de pujar a Git. Verificar que `.gitignore` el inclou.

### 2.3 Instal·lar Dependències

```bash
cd /home/flow-tracker/Flow-Tracker/backend
npm install --omit=dev
```

### 2.4 Aplicar Migracions de la Base de Dades

```bash
# Primera vegada (crea totes les taules):
npx prisma migrate deploy

# Genera el client Prisma:
npx prisma generate
```

> [!NOTE]
> `prisma migrate deploy` aplica les migracions pendents sense crear-ne de noves. Ideal per a producció.

### 2.5 Iniciar amb PM2

```bash
# Primera vegada:
pm2 start src/server.js --name flow-tracker-api

# Guardar configuració PM2 (sobreviu a reinicis):
pm2 save
pm2 startup
# Executar la comanda que PM2 mostri

# Verificar que funciona:
pm2 status
curl http://localhost:3001/health
```

---

## 3. Configuració de Nginx

### 3.1 Crear el Fitxer de Configuració

```bash
sudo nano /etc/nginx/sites-available/flow-tracker
```

```nginx
server {
    listen 80;
    server_name ieticloudpro.ieti.cat;  # o el teu domini

    # Augmentar límit per a imatges en Base64
    client_max_body_size 20M;

    # API Backend
    location /api/ {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Authorization $http_authorization;
        proxy_pass_header Authorization;
    }

    # Health Check
    location /health {
        proxy_pass http://localhost:3001/health;
    }

    # Frontend Web (Flutter)
    location / {
        root /var/www/flow-tracker;
        index index.html;
        try_files $uri $uri/ /index.html;  # Necessari per a Flutter web (SPA)
    }
}
```

### 3.2 Activar el Lloc i Recarregar Nginx

```bash
sudo ln -s /etc/nginx/sites-available/flow-tracker /etc/nginx/sites-enabled/
sudo nginx -t  # Verificar sintaxi
sudo systemctl reload nginx
```

---

## 4. Desplegament del Frontend Web (Flutter)

### 4.1 Compilar des del PC de Desenvolupament

```bash
cd frontend

# Configurar la URL de l'API per a producció
# Editar lib/config/app_config.dart per apuntar al servidor

flutter build web --release
```

### 4.2 Pujar al Servidor

**Opció A: Comprimir i pujar per SCP**

```bash
# Al PC de desenvolupament:
Compress-Archive -Path frontend\build\web\* -DestinationPath web.zip -Force
scp -P 20127 web.zip flow-tracker@ieticloudpro.ieti.cat:/tmp/
```

**Opció B: Directament via SCP (sense comprimir)**

```bash
scp -P 20127 -r frontend/build/web/* flow-tracker@ieticloudpro.ieti.cat:/var/www/flow-tracker/
```

### 4.3 Descomprimir al Servidor

```bash
# Al servidor:
sudo mkdir -p /var/www/flow-tracker
cd /var/www/flow-tracker
sudo unzip /tmp/web.zip -o  # -o sobreescriu sense preguntar
```

> [!TIP]
> Per evitar problemes de cache del navegador, sempre esborra el contingut antic abans de descomprimir el nou:
> `sudo rm -rf /var/www/flow-tracker/* && sudo unzip /tmp/web.zip -d /var/www/flow-tracker/`

---

## 5. Actualitzar l'Aplicació en Producció

### 5.1 Actualitzar el Backend

```bash
cd /home/flow-tracker/Flow-Tracker
git pull origin main

cd backend
npm install --omit=dev
npx prisma migrate deploy
npx prisma generate

pm2 restart flow-tracker-api
pm2 logs flow-tracker-api --lines 20  # Verificar que arrenca bé
```

### 5.2 Actualitzar el Frontend Web

```bash
# Al PC de desenvolupament:
flutter build web --release

# Pujar els nous fitxers (vegues secció 4.2)
# Al servidor, esborrar els antics i descomprimir els nous
```

---

## 6. Gestió i Monitorització

### Comandes PM2 Útils

```bash
pm2 status                        # Estat de tots els processos
pm2 logs flow-tracker-api         # Veure logs en temps real
pm2 logs flow-tracker-api --lines 50  # Últimes 50 línies
pm2 restart flow-tracker-api      # Reiniciar l'API
pm2 stop flow-tracker-api         # Parar l'API
pm2 start flow-tracker-api        # Arrencar l'API
pm2 monit                         # Monitor en temps real (CPU, RAM)
```

### Verificar que tot funciona

```bash
# Health check de l'API:
curl http://localhost:3001/health
# Resposta esperada: {"status":"ok","timestamp":"..."}

# Verificar Nginx:
sudo systemctl status nginx

# Verificar PostgreSQL:
sudo systemctl status postgresql

# Verificar connexió a la BD:
cd /home/flow-tracker/Flow-Tracker/backend
npx prisma db pull  # Llegeix l'esquema actual de la BD
```

### Veure Logs de Nginx

```bash
sudo tail -f /var/log/nginx/access.log   # Peticions entrants
sudo tail -f /var/log/nginx/error.log    # Errors
```

---

## 7. Còpies de Seguretat de la Base de Dades

### Crear un Backup

```bash
pg_dump -U flow_tracker -h localhost flowtracker > backup_$(date +%Y%m%d).sql
```

### Restaurar un Backup

```bash
psql -U flow_tracker -h localhost flowtracker < backup_20260513.sql
```

---

## 8. Configuració del Port SSH (Referència)

El servidor Proxmox de l'institut utilitza un port SSH no estàndard:

```bash
# Connexió al servidor:
ssh -p 20127 flow-tracker@ieticloudpro.ieti.cat

# Copiar fitxers via SCP:
scp -P 20127 fitxer.zip flow-tracker@ieticloudpro.ieti.cat:/ruta/destino/
```

---

## 9. Resolució de Problemes Comuns

### L'API no arrenca després d'un `git pull`

```bash
cd backend
npm install  # Potser hi ha noves dependències
npx prisma generate  # Regenerar el client Prisma
pm2 restart flow-tracker-api
pm2 logs flow-tracker-api
```

### Error "Cannot connect to database"

```bash
# Verificar PostgreSQL:
sudo systemctl status postgresql
# Verificar les credencials del .env:
cat /home/flow-tracker/Flow-Tracker/backend/.env
# Provar connexió manual:
psql -U flow_tracker -h localhost -d flowtracker
```

### El frontend web mostra la versió antiga (cache)

1. Al servidor: esborrar la carpeta `/var/www/flow-tracker/` i descomprimir de nou
2. Al navegador: Ctrl+F5 (refresc forçat sense cache)

### Nginx retorna 502 Bad Gateway

```bash
# L'API no està funcionant:
pm2 status
pm2 start flow-tracker-api
pm2 logs flow-tracker-api
```

---

*Flow-Tracker v1.0 — DAM AMS2 — MP13 Crèdit de Síntesi — Maig 2026*
