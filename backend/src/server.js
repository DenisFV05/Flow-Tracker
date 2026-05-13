const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const hpp = require('hpp');

const authRoutes = require('./routes/auth.routes');
const habitsRoutes = require('./routes/habits.routes');
const tagsRoutes = require('./routes/tags.routes');
const profileRoutes = require('./routes/profile.routes');
const friendsRoutes = require('./routes/friends.routes');
const feedRoutes = require('./routes/feed.routes');
const notificationsRoutes = require('./routes/notifications.routes');

const app = express();
app.set('trust proxy', 1); // Trust first proxy (Nginx, etc.)
const PORT = process.env.PORT || 3000;

// Middlewares
app.use(helmet());
app.use(cors({
    origin: process.env.ALLOWED_ORIGINS?.split(',') || '*',
    credentials: true
}));
app.use(express.json({ limit: '8mb' }));
app.use(hpp()); // Prevent HTTP Parameter Pollution

// Health check
app.get('/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.use((req, res, next) => {
    const now = new Date();

    const readableTime = now.toLocaleString('es-ES', {
        dateStyle: 'short',
        timeStyle: 'medium'
    });

    console.log(`[${readableTime}] ${req.method} ${req.originalUrl}`);
    next();
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/habits', habitsRoutes);
app.use('/api/tags', tagsRoutes);
app.use('/api/profile', profileRoutes);
app.use('/api/friends', friendsRoutes);
app.use('/api/feed', feedRoutes);
app.use('/api/notifications', notificationsRoutes);

// 404 handler
app.use((req, res) => {
    res.status(404).json({ error: 'Not found' });
});

// Error handling
app.use((err, req, res, next) => {
    try {
        console.error('[SERVER ERROR]', err.message, err.stack?.split('\n')[1] || '');

        if (err.type === 'entity.parse.failed') {
            return res.status(400).json({ error: 'Invalid JSON in request body' });
        }
        if (err.name === 'PrismaClientKnownRequestError') {
            console.error('[PRISMA ERROR]', err.code, err.message);
            return res.status(400).json({ error: 'Database error', code: err.code });
        }
        if (err.name === 'PrismaClientValidationError') {
            console.error('[PRISMA VALIDATION ERROR]', err.message);
            return res.status(400).json({ error: 'Invalid request data' });
        }
        console.error('[SERVER ERROR]', err.message);
        res.status(500).json({ error: 'Internal server error' });
    } catch (handlerError) {
        console.error('[FATAL] Error handler crashed:', handlerError);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// Start server
app.listen(PORT, () => {
    const time = new Date().toLocaleTimeString('es-ES');
    console.log(`[${time}] Server running on port ${PORT}`);
});
