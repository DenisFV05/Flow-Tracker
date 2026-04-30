const express = require('express');
const router = express.Router();
const prisma = require('../prisma');
const authMiddleware = require('../middleware/auth');

router.use(authMiddleware);

router.get('/', async (req, res) => {
    try {
        const userId = req.user.id;

        const tags = await prisma.tag.findMany({
            where: { userId },
            orderBy: { name: 'asc' }
        });

        res.json(tags);
    } catch (error) {
        console.error('Error fetching tags:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

router.post('/', async (req, res) => {
    try {
        const { name } = req.body;
        const userId = req.user.id;

        if (!name) {
            return res.status(400).json({ error: 'Tag name is required' });
        }

        const existing = await prisma.tag.findFirst({
            where: { name, userId }
        });

        if (existing) {
            return res.status(400).json({ error: 'Tag already exists' });
        }

        const tag = await prisma.tag.create({
            data: { name, userId }
        });

        res.status(201).json(tag);
    } catch (error) {
        console.error('Error creating tag:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

router.delete('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.user.id;

        const existing = await prisma.tag.findFirst({
            where: { id, userId }
        });

        if (!existing) {
            return res.status(404).json({ error: 'Tag not found' });
        }

        await prisma.tag.delete({
            where: { id }
        });

        res.json({ message: 'Tag deleted successfully' });
    } catch (error) {
        console.error('Error deleting tag:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

module.exports = router;