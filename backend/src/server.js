const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');

const authRoutes = require('./routes/auth.routes');
const habitsRoutes = require('./routes/habits.routes');
const tagsRoutes = require('./routes/tags.routes');
const profileRoutes = require('./routes/profile.routes');
const friendsRoutes = require('./routes/friends.routes');
const feedRoutes = require('./routes/feed.routes');

const app = express();
const PORT = process.env.PORT || 3000;

// Middlewares
app.use(helmet());
app.use(cors({
    origin: process.env.ALLOWED_ORIGINS?.split(',') || '*',
    credentials: true
}));
app.use(express.json({ limit: '50mb' }));

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

// Error handling
app.use((err, req, res, next) => {
    console.error('Unhandled error:', err);
    res.status(500).json({ error: 'Internal server error' });
});

// Start server
app.listen(PORT, () => {
    const time = new Date().toLocaleTimeString('es-ES');

    console.log(`[${time}] Server running on port ${PORT}`);
});

