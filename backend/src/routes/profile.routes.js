const express = require('express');
const router = express.Router();
const prisma = require('../prisma');
const authMiddleware = require('../middleware/auth');
const { validateUUID } = require('../middleware/validation');
const { calculateMaxStreak } = require('../utils/streak');

router.use(authMiddleware);

function computeStats(habits) {
    let totalHabits = habits.length;
    let totalLogs = 0;
    let completedLogs = 0;
    let longestStreak = 0;

    for (const habit of habits) {
        const logs = habit.logs || [];
        totalLogs += logs.length;
        completedLogs += logs.filter(l => l.completed).length;
        const maxStreakForHabit = calculateMaxStreak(logs);
        longestStreak = Math.max(longestStreak, maxStreakForHabit);
    }

    const overallCompletionRate = totalLogs > 0 
        ? Math.round((completedLogs / totalLogs) * 1000) / 10 
        : 0;

    return { totalHabits, totalLogs, completedLogs, overallCompletionRate, longestStreak };
}

router.get('/', async (req, res) => {
    try {
        const userId = req.user.id;

        const user = await prisma.user.findUnique({
            where: { id: userId },
            select: {
                id: true,
                name: true,
                username: true,
                email: true,
                avatar: true,
                createdAt: true
            }
        });

        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }

        res.json(user);
    } catch (error) {
        console.error('[PROFILE GET ERROR]', error.message);
        res.status(500).json({ error: 'Error carregant perfil' });
    }
});

router.put('/', async (req, res) => {
    try {
        const userId = req.user.id;
        const { name, avatar } = req.body;

        const user = await prisma.user.update({
            where: { id: userId },
            data: {
                ...(name && { name }),
                ...(avatar !== undefined && { avatar })
            },
            select: {
                id: true,
                name: true,
                username: true,
                email: true,
                avatar: true
            }
        });

        res.json(user);
    } catch (error) {
        console.error('[PROFILE UPDATE ERROR]', error.message);
        res.status(500).json({ error: 'Error actualitzant perfil' });
    }
});

router.get('/stats', async (req, res) => {
    try {
        const userId = req.user.id;

        const habits = await prisma.habit.findMany({
            where: { userId },
            include: { logs: true }
        });

        const stats = computeStats(habits);

        const now = new Date();
        const startOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate());
        const startOfTomorrow = new Date(startOfToday);
        startOfTomorrow.setDate(startOfTomorrow.getDate() + 1);

        const todayLogs = await prisma.activityLog.findMany({
            where: {
                userId,
                date: {
                    gte: startOfToday,
                    lt: startOfTomorrow
                }
            }
        });

        const todayCompleted = todayLogs.filter(l => l.completed).length;
        const todayTotal = todayLogs.length;
        const todayCompletedHabitIds = todayLogs
            .filter(l => l.completed)
            .map(l => l.habitId);

        res.json({
            ...stats,
            todayCompleted,
            todayTotal,
            todayCompletedHabitIds
        });
    } catch (error) {
        console.error('[PROFILE STATS ERROR]', error.message);
        res.status(500).json({ error: 'Error carregant estadístiques' });
    }
});

router.get('/export', async (req, res) => {
    try {
        const userId = req.user.id;
        const logs = await prisma.activityLog.findMany({
            where: { userId },
            include: { habit: { select: { name: true, description: true, tags: true } } },
            orderBy: { date: 'desc' }
        });

        const escapeCSV = (value) => {
            if (value == null) return '';
            const str = String(value);
            if (str.includes(',') || str.includes('"') || str.includes('\n')) {
                return `"${str.replace(/"/g, '""')}"`;
            }
            return str;
        };

        let csv = 'Data,Habit,Descripcio,Tags,Completat\n';
        logs.forEach(log => {
            const date = new Date(log.date).toISOString().split('T')[0];
            const habitName = escapeCSV(log.habit.name);
            const habitDesc = escapeCSV(log.habit.description || '');
            const habitTags = (log.habit.tags || []).map(tag => tag.name).join('; ');
            const tagsValue = escapeCSV(habitTags);
            csv += `${date},${habitName},${habitDesc},${tagsValue},${log.completed ? 'Si' : 'No'}\n`;
        });

        res.setHeader('Content-Type', 'text/csv');
        res.setHeader('Content-Disposition', 'attachment; filename=flowtracker_history.csv');
        res.status(200).send(csv);
    } catch (error) {
        console.error('[EXPORT ERROR]', error.message);
        res.status(500).json({ error: 'Error exportant dades' });
    }
});

router.get('/:id', validateUUID('id'), async (req, res) => {
    try {
        const friendId = req.params.id;
        const userId = req.user.id;

        if (!friendId || friendId.trim() === '') {
            return res.status(400).json({ error: 'ID invàlid' });
        }

        if (friendId === userId) {
            return res.status(400).json({ error: 'Usa /api/profile per al teu propi perfil' });
        }

        const friendship = await prisma.friendship.findFirst({
            where: {
                OR: [
                    { requesterId: userId, receiverId: friendId, status: 'accepted' },
                    { requesterId: friendId, receiverId: userId, status: 'accepted' }
                ]
            }
        });

        if (!friendship) {
            return res.status(403).json({ error: 'No sou amics' });
        }

        const user = await prisma.user.findUnique({
            where: { id: friendId },
            select: {
                id: true,
                name: true,
                username: true,
                avatar: true,
                createdAt: true
            }
        });

        if (!user) {
            return res.status(404).json({ error: 'Usuari no trobat' });
        }

        const habits = await prisma.habit.findMany({
            where: { userId: friendId },
            include: { logs: true }
        });

        const stats = computeStats(habits);

        res.json({
            ...user,
            ...stats
        });
    } catch (error) {
        console.error('[PROFILE FRIEND ERROR]', error.message);
        res.status(500).json({ error: 'Error carregant perfil de l\'amic' });
    }
});

module.exports = router;

