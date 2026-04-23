# Flow-Tracker

## Architecture

- **backend/**: Node.js + Express API with Prisma ORM + PostgreSQL
- **frontend/**: Flutter app (Android, Web, Windows, Linux)

## Running the Backend

```bash
cd backend
npm install
# Ensure PostgreSQL is running at localhost:5432/flowtracker_db
# Credentials: flowtracker / flowadmin
npm run dev     # Auto-reload with nodemon (Recommended)
npm start       # Production
```

## Prisma Commands

```bash
cd backend
npx prisma generate      # Regenerate client after schema changes
npx prisma db push      # Push schema to database
npx prisma migrate dev # Run migrations
```

## Environment

Backend requires `.env` with:
```
DATABASE_URL=postgresql://flowtracker:flowadmin@localhost:5432/flowtracker_db
JWT_SECRET=your-secret-key
PORT=3000
```

## API Endpoints

- `POST /api/auth/register` - Create user
- `POST /api/auth/login` - Get JWT token
- `GET /api/auth/profile` - Protected (requires `Authorization: Bearer <token>`)

## Key Files

- `backend/src/server.js` - Entry point
- `backend/src/routes/auth.routes.js` - Auth handlers
- `backend/src/prisma.js` - Prisma client instance
- `backend/prisma/schema.prisma` - Database schema