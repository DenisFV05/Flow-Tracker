const express = require('express');
const router = express.Router();
const prisma = require('../prisma');
const authMiddleware = require('../middleware/auth');
const { validateHabit } = require('../middleware/validation');

router.use(authMiddleware);

function localDateStr(d) {
    const y = d.getFullYear();
    const m = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    return `${y}-${m}-${day}`;
}

function dateOnlyStr(d) {
    return d.toISOString().split('T')[0];
}

function calculateStreak(logs) {
    if (!logs || logs.length === 0) return 0;

    const completedDates = logs
        .filter(log => log.completed)
        .map(log => dateOnlyStr(new Date(log.date)))
        .sort()
        .reverse();

    if (completedDates.length === 0) return 0;

    const now = new Date();
    const today = localDateStr(now);
    const yesterdayDate = new Date(now);
    yesterdayDate.setDate(yesterdayDate.getDate() - 1);
    const yesterday = localDateStr(yesterdayDate);

    if (completedDates[0] !== today && completedDates[0] !== yesterday) {
        return 0;
    }

    let streak = 1;
    let currentDate = new Date(completedDates[0]);

    for (let i = 1; i < completedDates.length; i++) {
        const prevDate = dateOnlyStr(new Date(currentDate.getTime() - 86400000));
        if (completedDates[i] === prevDate) {
            streak++;
            currentDate = new Date(completedDates[i]);
        } else {
            break;
        }
    }

    return streak;
}

function calculateMaxStreak(logs) {
    if (!logs || logs.length === 0) return 0;

    const completedDates = logs
        .filter(log => log.completed)
        .map(log => dateOnlyStr(new Date(log.date)))
        .sort();

    if (completedDates.length === 0) return 0;

    let maxStreak = 1;
    let currentStreak = 1;

    for (let i = 1; i < completedDates.length; i++) {
        const prevDate = dateOnlyStr(new Date(new Date(completedDates[i - 1]).getTime() + 86400000));
        if (completedDates[i] === prevDate) {
            currentStreak++;
            maxStreak = Math.max(maxStreak, currentStreak);
        } else {
            currentStreak = 1;
        }
    }

    return maxStreak;
}

router.post('/', validateHabit, async (req, res) => {
    try {
        const { name, description, tags } = req.body;
        const userId = req.user.id;

        if (!name) {
            return res.status(400).json({ error: 'Name is required' });
        }

        let tagConnections = [];
        if (tags && tags.length > 0) {
            for (const tagName of tags) {
                let tag = await prisma.tag.findFirst({
                    where: { name: tagName, userId }
                });
                if (!tag) {
                    tag = await prisma.tag.create({
                        data: { name: tagName, userId }
                    });
                }
                tagConnections.push({ id: tag.id });
            }
        }

        const habit = await prisma.habit.create({
            data: {
                name,
                description,
                userId,
                tags: {
                    connect: tagConnections
                }
            },
            include: { tags: true }
        });

        res.status(201).json(habit);
    } catch (error) {
        console.error('Error creating habit:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

router.get('/', async (req, res) => {
    try {
        const userId = req.user.id;

        const habits = await prisma.habit.findMany({
            where: { userId },
            include: { tags: true },
            orderBy: { createdAt: 'desc' }
        });

        res.json(habits);
    } catch (error) {
        console.error('Error fetching habits:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

router.get('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.user.id;

        const habit = await prisma.habit.findFirst({
            where: { id, userId },
            include: { tags: true }
        });

        if (!habit) {
            return res.status(404).json({ error: 'Habit not found' });
        }

        res.json(habit);
    } catch (error) {
        console.error('Error fetching habit:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

router.put('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { name, description, tags } = req.body;
        const userId = req.user.id;

        const existing = await prisma.habit.findFirst({
            where: { id, userId }
        });

        if (!existing) {
            return res.status(404).json({ error: 'Habit not found' });
        }

        let tagConnections = [];
        if (tags && tags.length > 0) {
            for (const tagName of tags) {
                let tag = await prisma.tag.findFirst({
                    where: { name: tagName, userId }
                });
                if (!tag) {
                    tag = await prisma.tag.create({
                        data: { name: tagName, userId }
                    });
                }
                tagConnections.push({ id: tag.id });
            }
        }

        const habit = await prisma.habit.update({
            where: { id },
            data: {
                ...(name && { name }),
                ...(description !== undefined && { description }),
                ...(tags && {
                    tags: {
                        set: tagConnections
                    }
                })
            },
            include: { tags: true }
        });

        res.json(habit);
    } catch (error) {
        console.error('Error updating habit:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

router.delete('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.user.id;

        const existing = await prisma.habit.findFirst({
            where: { id, userId }
        });

        if (!existing) {
            return res.status(404).json({ error: 'Habit not found' });
        }

        await prisma.habit.delete({
            where: { id }
        });

        res.json({ message: 'Habit deleted successfully' });
    } catch (error) {
        console.error('Error deleting habit:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

router.post('/:id/log', async (req, res) => {
    try {
        const { id } = req.params;
        const { date, completed } = req.body;
        const userId = req.user.id;

        const habit = await prisma.habit.findFirst({
            where: { id, userId }
        });

        if (!habit) {
            return res.status(404).json({ error: 'Habit not found' });
        }

        if (!date) {
            return res.status(400).json({ error: 'Date is required' });
        }

        const logDate = new Date(date);
        logDate.setHours(0, 0, 0, 0);

        const beforeLogs = await prisma.activityLog.findMany({
            where: { habitId: id },
            orderBy: { date: 'desc' }
        });
        const prevStreak = calculateStreak(beforeLogs);

        const log = await prisma.activityLog.upsert({
            where: {
                habitId_date: {
                    habitId: id,
                    date: logDate
                }
            },
            create: {
                habitId: id,
                userId,
                date: logDate,
                completed: completed !== false
            },
            update: {
                completed: completed !== false
            }
        });

        if (completed !== false) {
            const allLogs = await prisma.activityLog.findMany({
                where: { habitId: id },
                orderBy: { date: 'desc' }
            });
            const newStreak = calculateStreak(allLogs);
            const ACHIEVEMENT_MILESTONES = [7, 14, 30, 60, 90, 180, 365];
            
            if (ACHIEVEMENT_MILESTONES.includes(newStreak) && newStreak > prevStreak) {
                await prisma.post.create({
                    data: {
                        userId,
                        type: 'achievement',
                        content: `${newStreak} días seguidos de ${habit.name}!`,
                        habitId: id
                    }
                });
            }
        }

        res.json(log);
    } catch (error) {
        console.error('Error logging habit:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

router.delete('/:id/log/:date', async (req, res) => {
    try {
        const { id, date } = req.params;
        const userId = req.user.id;

        const habit = await prisma.habit.findFirst({
            where: { id, userId }
        });

        if (!habit) {
            return res.status(404).json({ error: 'Habit not found' });
        }

        const logDate = new Date(date);
        logDate.setHours(0, 0, 0, 0);

        await prisma.activityLog.deleteMany({
            where: {
                habitId: id,
                date: logDate
            }
        });

        res.json({ message: 'Log deleted successfully' });
    } catch (error) {
        console.error('Error deleting log:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

router.get('/:id/logs', async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.user.id;
        const { startDate, endDate } = req.query;

        const habit = await prisma.habit.findFirst({
            where: { id, userId }
        });

        if (!habit) {
            return res.status(404).json({ error: 'Habit not found' });
        }

        const where = { habitId: id };
        
        if (startDate || endDate) {
            where.date = {};
            if (startDate) where.date.gte = new Date(startDate);
            if (endDate) where.date.lte = new Date(endDate);
        }

        const logs = await prisma.activityLog.findMany({
            where,
            orderBy: { date: 'desc' }
        });

        res.json(logs);
    } catch (error) {
        console.error('Error fetching logs:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

router.get('/:id/stats', async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.user.id;

        const habit = await prisma.habit.findFirst({
            where: { id, userId }
        });

        if (!habit) {
            return res.status(404).json({ error: 'Habit not found' });
        }

        const logs = await prisma.activityLog.findMany({
            where: { habitId: id },
            orderBy: { date: 'desc' }
        });

        const completedLogs = logs.filter(log => log.completed);
        const totalDays = logs.length;
        const completedDays = completedLogs.length;
        const completionRate = totalDays > 0 ? Math.round((completedDays / totalDays) * 1000) / 10 : 0;

        const currentStreak = calculateStreak(logs);
        const maxStreak = calculateMaxStreak(logs);

        const lastCompletedLog = completedLogs[0];
        const lastCompletedDate = lastCompletedLog
            ? dateOnlyStr(new Date(lastCompletedLog.date))
            : null;

        const now = new Date();
        const todayStr = localDateStr(now);
        const todayCompleted = logs.some(log => {
            return dateOnlyStr(new Date(log.date)) === todayStr && log.completed;
        });

        res.json({
            habitId: id,
            currentStreak,
            maxStreak,
            totalDays,
            completedDays,
            completionRate,
            lastCompletedDate,
            completedToday: todayCompleted
        });
    } catch (error) {
        console.error('Error fetching stats:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

router.get('/:id/heatmap', async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.user.id;
        const { year } = req.query;

        const habit = await prisma.habit.findFirst({
            where: { id, userId }
        });

        if (!habit) {
            return res.status(404).json({ error: 'Habit not found' });
        }

        const targetYear = year ? parseInt(year) : new Date().getFullYear();
        const startOfYear = new Date(`${targetYear}-01-01`);
        const endOfYear = new Date(`${targetYear}-12-31`);

        const logs = await prisma.activityLog.findMany({
            where: {
                habitId: id,
                date: {
                    gte: startOfYear,
                    lte: endOfYear
                }
            }
        });

        const logMap = {};
        for (const log of logs) {
            const dateStr = new Date(log.date).toISOString().split('T')[0];
            logMap[dateStr] = log.completed;
        }

        const data = [];
        const current = new Date(startOfYear);
        const end = new Date(endOfYear);

        while (current <= end) {
            const dateStr = current.toISOString().split('T')[0];
            data.push({
                date: dateStr,
                completed: logMap[dateStr] || false
            });
            current.setDate(current.getDate() + 1);
        }

        res.json({
            habitId: id,
            year: targetYear,
            data
        });
    } catch (error) {
        console.error('Error fetching heatmap:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

router.get('/:id/weekly', async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.user.id;

        const habit = await prisma.habit.findFirst({
            where: { id, userId }
        });

        if (!habit) {
            return res.status(404).json({ error: 'Habit not found' });
        }

        const endDate = new Date();
        const startDate = new Date();
        startDate.setDate(startDate.getDate() - 6);

        const logs = await prisma.activityLog.findMany({
            where: {
                habitId: id,
                date: {
                    gte: startDate,
                    lte: endDate
                }
            }
        });

        const logMap = {};
        for (const log of logs) {
            const dateStr = new Date(log.date).toISOString().split('T')[0];
            logMap[dateStr] = log.completed;
        }

        const days = [];
        const current = new Date(startDate);

        for (let i = 0; i < 7; i++) {
            const dateStr = current.toISOString().split('T')[0];
            days.push({
                date: dateStr,
                completed: logMap[dateStr] || false
            });
            current.setDate(current.getDate() + 1);
        }

        res.json({
            habitId: id,
            days
        });
    } catch (error) {
        console.error('Error fetching weekly:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

router.get('/:id/monthly', async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.user.id;

        const habit = await prisma.habit.findFirst({
            where: { id, userId }
        });

        if (!habit) {
            return res.status(404).json({ error: 'Habit not found' });
        }

        const endDate = new Date();
        const startDate = new Date();
        startDate.setDate(startDate.getDate() - 29);

        const logs = await prisma.activityLog.findMany({
            where: {
                habitId: id,
                date: {
                    gte: startDate,
                    lte: endDate
                }
            }
        });

        const logMap = {};
        for (const log of logs) {
            const dateStr = new Date(log.date).toISOString().split('T')[0];
            logMap[dateStr] = log.completed;
        }

        const days = [];
        const current = new Date(startDate);

        for (let i = 0; i < 30; i++) {
            const dateStr = current.toISOString().split('T')[0];
            days.push({
                date: dateStr,
                completed: logMap[dateStr] || false
            });
            current.setDate(current.getDate() + 1);
        }

        res.json({
            habitId: id,
            days
        });
    } catch (error) {
        console.error('Error fetching monthly:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

module.exports = router;