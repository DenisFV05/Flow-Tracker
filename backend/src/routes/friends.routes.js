const express = require('express');
const router = express.Router();
const prisma = require('../prisma');
const authMiddleware = require('../middleware/auth');
const { validateFriendRequest, validateUUID } = require('../middleware/validation');

router.use(authMiddleware);

function mapUser(user) {
    return {
        id: user.id,
        username: user.username,
        name: user.name,
        avatar: user.avatar
    };
}

router.get('/search', async (req, res) => {
    try {
        const userId = req.user.id;
        const { q } = req.query;

        if (!q || q.length < 2) {
            return res.status(400).json({ error: 'Search query must be at least 2 characters' });
        }

        const users = await prisma.user.findMany({
            where: {
                id: { not: userId },
                OR: [
                    { username: { contains: q, mode: 'insensitive' } },
                    { name: { contains: q, mode: 'insensitive' } }
                ]
            },
            select: {
                id: true,
                username: true,
                name: true,
                avatar: true
            },
            take: 20
        });

        const sentRequests = await prisma.friendship.findMany({
            where: { requesterId: userId },
            select: { receiverId: true }
        });
        const sentRequestIds = sentRequests.map(r => r.receiverId);

        const friendships = await prisma.friendship.findMany({
            where: {
                OR: [
                    { requesterId: userId },
                    { receiverId: userId }
                ],
                status: 'accepted'
            },
            select: {
                requesterId: true,
                receiverId: true
            }
        });
        const friendIds = friendships.map(f => 
            f.requesterId === userId ? f.receiverId : f.requesterId
        );

        const result = users.map(user => ({
            ...user,
            isFriend: friendIds.includes(user.id),
            requestSent: sentRequestIds.includes(user.id)
        }));

        res.json(result);
    } catch (error) {
        console.error('[FRIENDS SEARCH ERROR]', error.message);
        res.status(500).json({ error: 'Error cercant usuaris' });
    }
});

router.get('/', async (req, res) => {
    try {
        const userId = req.user.id;

        const friendships = await prisma.friendship.findMany({
            where: {
                OR: [
                    { requesterId: userId, status: 'accepted' },
                    { receiverId: userId, status: 'accepted' }
                ]
            },
            include: {
                requester: {
                    select: { id: true, username: true, name: true, avatar: true }
                },
                receiver: {
                    select: { id: true, username: true, name: true, avatar: true }
                }
            },
            orderBy: { updatedAt: 'desc' }
        });

        const friends = friendships.map(f => {
            const friend = f.requesterId === userId ? f.receiver : f.requester;
            return {
                friendshipId: f.id,
                friend: mapUser(friend),
                since: f.updatedAt
            };
        });

        res.json(friends);
    } catch (error) {
        console.error('[FRIENDS LIST ERROR]', error.message);
        res.status(500).json({ error: 'Error carregant amics' });
    }
});

router.get('/requests', async (req, res) => {
    try {
        const userId = req.user.id;

        const requests = await prisma.friendship.findMany({
            where: {
                receiverId: userId,
                status: 'pending'
            },
            include: {
                requester: {
                    select: { id: true, username: true, name: true, avatar: true }
                }
            },
            orderBy: { createdAt: 'desc' }
        });

        res.json(requests.map(r => ({
            id: r.id,
            user: mapUser(r.requester),
            createdAt: r.createdAt
        })));
    } catch (error) {
        console.error('[FRIENDS REQUESTS ERROR]', error.message);
        res.status(500).json({ error: 'Error carregant sol·licituds' });
    }
});

router.get('/sent', async (req, res) => {
    try {
        const userId = req.user.id;

        const sent = await prisma.friendship.findMany({
            where: {
                requesterId: userId,
                status: 'pending'
            },
            include: {
                receiver: {
                    select: { id: true, username: true, name: true, avatar: true }
                }
            },
            orderBy: { createdAt: 'desc' }
        });

        res.json(sent.map(s => ({
            id: s.id,
            user: mapUser(s.receiver),
            createdAt: s.createdAt
        })));
    } catch (error) {
        console.error('[FRIENDS SENT ERROR]', error.message);
        res.status(500).json({ error: 'Error carregant sol·licituds enviades' });
    }
});

router.post('/request', validateFriendRequest, async (req, res) => {
    try {
        const userId = req.user.id;
        const { username } = req.body;

        if (!username) {
            return res.status(400).json({ error: 'Username is required' });
        }

        const receiver = await prisma.user.findUnique({
            where: { username }
        });

        if (!receiver) {
            return res.status(404).json({ error: 'User not found' });
        }

        if (receiver.id === userId) {
            return res.status(400).json({ error: 'Cannot send friend request to yourself' });
        }

        const existing = await prisma.friendship.findFirst({
            where: {
                OR: [
                    { requesterId: userId, receiverId: receiver.id },
                    { requesterId: receiver.id, receiverId: userId }
                ]
            }
        });

        if (existing) {
            if (existing.status === 'accepted') {
                return res.status(400).json({ error: 'Already friends' });
            }
            if (existing.status === 'pending' && existing.requesterId === userId) {
                return res.status(400).json({ error: 'Request already sent' });
            }
            if (existing.status === 'pending' && existing.receiverId === userId) {
                return res.status(400).json({ error: 'Pending request from this user' });
            }
            if (existing.status === 'rejected') {
                await prisma.friendship.delete({
                    where: { id: existing.id }
                });
            }
        }

        const friendship = await prisma.friendship.create({
            data: {
                requesterId: userId,
                receiverId: receiver.id,
                status: 'pending'
            }
        });

        // Notify receiver
        await prisma.notification.create({
            data: {
                userId: receiver.id,
                type: 'friend_request',
                message: `${req.user.name} t'ha enviat una sol·licitud d'amistat`
            }
        }).catch(() => {});

        res.status(201).json({
            id: friendship.id,
            status: friendship.status
        });
    } catch (error) {
        console.error('[FRIENDS REQUEST ERROR]', error.message);
        res.status(500).json({ error: 'Error enviant sol·licitud' });
    }
});

router.put('/request/:id', validateUUID('id'), async (req, res) => {
    try {
        const { id } = req.params;
        const { action } = req.body;
        const userId = req.user.id;

        if (!action || !['accept', 'reject'].includes(action)) {
            return res.status(400).json({ error: 'Action must be accept or reject' });
        }

        const request = await prisma.friendship.findFirst({
            where: {
                id,
                receiverId: userId,
                status: 'pending'
            }
        });

        if (!request) {
            return res.status(404).json({ error: 'Request not found' });
        }

        const status = action === 'accept' ? 'accepted' : 'rejected';

        const updated = await prisma.friendship.update({
            where: { id },
            data: { status }
        });

        res.json({
            id: updated.id,
            status: updated.status
        });
    } catch (error) {
        console.error('[FRIENDS RESPOND ERROR]', error.message);
        res.status(500).json({ error: 'Error responent sol·licitud' });
    }
});

router.delete('/:id', validateUUID('id'), async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.user.id;

        const friendship = await prisma.friendship.findFirst({
            where: {
                id,
                OR: [
                    { requesterId: userId },
                    { receiverId: userId }
                ]
            }
        });

        if (!friendship) {
            return res.status(404).json({ error: 'Friendship not found' });
        }

        await prisma.friendship.delete({
            where: { id }
        });

        res.json({ message: 'Friend removed successfully' });
    } catch (error) {
        console.error('[FRIENDS DELETE ERROR]', error.message);
        res.status(500).json({ error: 'Error eliminant amic' });
    }
});

async function getStatsForUser(userId) {
    const habits = await prisma.habit.findMany({
        where: { userId },
        include: { logs: true }
    });

    let longestStreak = 0;
    for (const habit of habits) {
        const completedDates = (habit.logs || [])
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
    return { longestStreak, totalHabits: habits.length };
}

router.get('/leaderboard', async (req, res) => {
    try {
        const userId = req.user.id;

        // Get friends
        const friendships = await prisma.friendship.findMany({
            where: {
                OR: [
                    { requesterId: userId, status: 'accepted' },
                    { receiverId: userId, status: 'accepted' }
                ]
            },
            include: {
                requester: { select: { id: true, username: true, name: true, avatar: true } },
                receiver: { select: { id: true, username: true, name: true, avatar: true } }
            }
        });

        const userIds = [userId, ...friendships.map(f => f.requesterId === userId ? f.receiverId : f.requesterId)];
        const users = await prisma.user.findMany({
            where: { id: { in: userIds } },
            select: { id: true, username: true, name: true, avatar: true }
        });

        const leaderboard = await Promise.all(users.map(async (user) => {
            const stats = await getStatsForUser(user.id);
            return {
                ...user,
                longestStreak: stats.longestStreak,
                totalHabits: stats.totalHabits
            };
        }));

        leaderboard.sort((a, b) => b.longestStreak - a.longestStreak);

        res.json(leaderboard);
    } catch (error) {
        console.error('[LEADERBOARD ERROR]', error.message);
        res.status(500).json({ error: 'Error carregant rànquing' });
    }
});

module.exports = router;
