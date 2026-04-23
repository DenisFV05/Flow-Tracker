const express = require('express');
const router = express.Router();
const prisma = require('../prisma');
const authMiddleware = require('../middleware/auth');

router.use(authMiddleware);

router.post('/', async (req, res) => {
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

module.exports = router;