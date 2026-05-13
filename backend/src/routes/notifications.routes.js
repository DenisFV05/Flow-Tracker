const express = require('express');
const router = express.Router();
const prisma = require('../prisma');
const authMiddleware = require('../middleware/auth');

router.use(authMiddleware);

// Get all notifications for the user
router.get('/', async (req, res) => {
    try {
        const userId = req.user.id;

        const notifications = await prisma.notification.findMany({
            where: { userId },
            orderBy: { createdAt: 'desc' },
            take: 50
        });

        res.json(notifications);
    } catch (error) {
        console.error('[NOTIFICATIONS GET ERROR]', error.message);
        res.status(500).json({ error: 'Error carregant notificacions' });
    }
});

// Get unread count only (for badge polling)
router.get('/unread-count', async (req, res) => {
    try {
        const userId = req.user.id;
        const count = await prisma.notification.count({
            where: { userId, read: false }
        });
        res.json({ count });
    } catch (error) {
        console.error('[NOTIFICATIONS COUNT ERROR]', error.message);
        res.status(500).json({ error: 'Error carregant notificacions' });
    }
});

// Mark all notifications as read
router.put('/read-all', async (req, res) => {
    try {
        const userId = req.user.id;
        await prisma.notification.updateMany({
            where: { userId, read: false },
            data: { read: true }
        });
        res.json({ message: 'Notificacions marcades com llegides' });
    } catch (error) {
        console.error('[NOTIFICATIONS READ ERROR]', error.message);
        res.status(500).json({ error: 'Error actualitzant notificacions' });
    }
});

module.exports = router;
