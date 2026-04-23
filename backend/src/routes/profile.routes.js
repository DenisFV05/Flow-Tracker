const express = require('express');
const router = express.Router();
const prisma = require('../prisma');
const authMiddleware = require('../middleware/auth');

router.use(authMiddleware);

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

        res.json(user);
    } catch (error) {
        console.error('Error fetching profile:', error);
        res.status(500).json({ error: 'Server error' });
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
        console.error('Error updating profile:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

router.get('/stats', async (req, res) => {
    try {
        const userId = req.user.id;

        const habits = await prisma.habit.findMany({
            where: { userId },
            include: {
                logs: true
            }
        });

        let totalHabits = habits.length;
        let totalLogs = 0;
        let completedLogs = 0;
        let longestStreak = 0;

        for (const habit of habits) {
            const logs = habit.logs;
            totalLogs += logs.length;
            completedLogs += logs.filter(l => l.completed).length;

            if (logs.length > 0) {
                const completedDates = logs
                    .filter(l => l.completed)
                    .map(l => new Date(l.date).toISOString().split('T')[0])
                    .sort();

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

        const today = new Date().toISOString().split('T')[0];
        const todayLogs = await prisma.activityLog.findMany({
            where: {
                userId,
                date: {
                    gte: new Date(today)
                }
            }
        });

        const todayCompleted = todayLogs.filter(l => l.completed).length;
        const todayTotal = todayLogs.length;

        res.json({
            totalHabits,
            totalLogs,
            completedLogs,
            overallCompletionRate,
            longestStreak,
            todayCompleted,
            todayTotal
        });
    } catch (error) {
        console.error('Error fetching profile stats:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

module.exports = router;