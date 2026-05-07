const express = require('express');
const router = express.Router();
const prisma = require('../prisma');
const authMiddleware = require('../middleware/auth');

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

        const completedDates = logs
            .filter(l => l.completed)
            .map(l => new Date(l.date).toISOString().split('T')[0])
            .sort();

        if (completedDates.length > 0) {
            let currentStreak = 1;
            let maxInHabit = 1;
            for (let i = 1; i < completedDates.length; i++) {
                const prevDate = new Date(new Date(completedDates[i - 1]).getTime() + 86400000).toISOString().split('T')[0];
                if (completedDates[i] === prevDate) {
                    currentStreak++;
                    maxInHabit = Math.max(maxInHabit, currentStreak);
                } else {
                    currentStreak = 1;
                }
            }
            longestStreak = Math.max(longestStreak, maxInHabit);
        }
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

router.get('/:id', async (req, res) => {
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
