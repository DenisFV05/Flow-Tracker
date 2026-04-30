const express = require('express');
const router = express.Router();
const prisma = require('../prisma');
const authMiddleware = require('../middleware/auth');
const { validateFriendRequest } = require('../middleware/validation');

router.use(authMiddleware);

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
                    { email: { contains: q, mode: 'insensitive' } },
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
        console.error('Error searching users:', error);
        res.status(500).json({ error: 'Server error' });
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
                friend,
                since: f.updatedAt
            };
        });

        res.json(friends);
    } catch (error) {
        console.error('Error fetching friends:', error);
        res.status(500).json({ error: 'Server error' });
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
            user: r.requester,
            createdAt: r.createdAt
        })));
    } catch (error) {
        console.error('Error fetching requests:', error);
        res.status(500).json({ error: 'Server error' });
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
            user: s.receiver,
            createdAt: s.createdAt
        })));
    } catch (error) {
        console.error('Error fetching sent requests:', error);
        res.status(500).json({ error: 'Server error' });
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

        res.status(201).json({
            id: friendship.id,
            status: friendship.status
        });
    } catch (error) {
        console.error('Error sending friend request:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

router.put('/request/:id', async (req, res) => {
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
        console.error('Error responding to friend request:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

router.delete('/:id', async (req, res) => {
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
        console.error('Error removing friend:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

module.exports = router;