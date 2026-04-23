const express = require('express');
const router = express.Router();

const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const prisma = require('../prisma');
const authMiddleware = require('../middleware/auth');
router.post('/register', async (req, res) => {
    try {
        const { email, password,name,username } = req.body;

        const existingUser = await prisma.user.findUnique({
            where: { email }
        });

        if (existingUser) {
            return res.status(400).json({ error: 'User already exists' });
        }

        const hashedPassword = await bcrypt.hash(password, 10);

        const user = await prisma.user.create({
            data: {
                email,
                password: hashedPassword,
                name,
                username
            }
        });

        return res.status(201).json({
            id: user.id,
            email: user.email,
            name: user.name,
            username: user.username
        });

        } catch (error) {
            console.log(error);
            return res.status(500).json({ error: 'Server error' });
        }

});

router.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body;

        const user = await prisma.user.findUnique({
            where: { email }
        });

        if (!user) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }

        const validPassword = await bcrypt.compare(password, user.password);

        if (!validPassword) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }

        const token = jwt.sign(
            { userId: user.id, email: user.email },
            process.env.JWT_SECRET,
            { expiresIn: '1d' }
        );

        return res.json({
            token,
            user: {
                id: user.id,
                email: user.email,
                name: user.name
            }
        });

        } catch (error) {
            console.log(error); // 👈 AÑADE ESTO
            return res.status(500).json({ error: 'Server error' });
        }

});
router.get('/profile', authMiddleware, (req, res) => {
    res.json({
        user: req.user
    });
});

module.exports = router;
