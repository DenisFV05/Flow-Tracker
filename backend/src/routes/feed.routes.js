const express = require('express');
const router = express.Router();
const prisma = require('../prisma');
const authMiddleware = require('../middleware/auth');
const { validatePost } = require('../middleware/validation');

router.use(authMiddleware);

const ACHIEVEMENT_MILESTONES = [7, 14, 30, 60, 90, 180, 365];

async function checkAndCreateAchievementPost(userId, habitId, habitName, newStreak) {
    if (!ACHIEVEMENT_MILESTONES.includes(newStreak)) return;
    
    const message = `${newStreak} días seguidos de ${habitName}!`;
    
    await prisma.post.create({
        data: {
            userId,
            type: 'achievement',
            content: message,
            habitId
        }
    });
}

async function getFriendIds(userId) {
    const friendships = await prisma.friendship.findMany({
        where: {
            OR: [
                { requesterId: userId, status: 'accepted' },
                { receiverId: userId, status: 'accepted' }
            ]
        }
    });
    
    return friendships.map(f => 
        f.requesterId === userId ? f.receiverId : f.requesterId
    );
}

router.get('/', async (req, res) => {
    try {
        const userId = req.user.id;
        const { cursor, limit = '20' } = req.query;

        const friendIds = await getFriendIds(userId);
        const allUserIds = [userId, ...friendIds];

        const where = {
            userId: { in: allUserIds },
            type: { in: ['achievement', 'manual'] }
        };

        if (cursor) {
            where.createdAt = { lt: new Date(cursor) };
        }

        const posts = await prisma.post.findMany({
            where,
            include: {
                user: {
                    select: { id: true, username: true, name: true, avatar: true }
                },
                likes: {
                    where: { userId },
                    select: { id: true }
                },
                _count: {
                    select: { likes: true }
                },
                habit: {
                    select: { name: true }
                }
            },
            orderBy: { createdAt: 'desc' },
            take: parseInt(limit) + 1
        });

        let nextCursor = null;
        if (posts.length > parseInt(limit)) {
            const nextPost = posts.pop();
            nextCursor = nextPost.createdAt.toISOString();
        }

        const result = posts.map(post => ({
            id: post.id,
            user: {
                id: post.user.id,
                username: post.user.username,
                name: post.user.name,
                avatar: post.user.avatar
            },
            type: post.type,
            content: post.content,
            habitId: post.habitId,
            habitName: post.habit?.name,
            createdAt: post.createdAt.toISOString(),
            liked: post.likes.length > 0,
            likesCount: post._count.likes,
            isOwn: post.userId === userId
        }));

        res.json({
            posts: result,
            nextCursor
        });
    } catch (error) {
        console.error('[FEED ERROR]', error.message);
        res.status(500).json({ error: 'Error carregant el feed', details: process.env.NODE_ENV === 'development' ? error.message : undefined });
    }
});

router.post('/', validatePost, async (req, res) => {
    try {
        const userId = req.user.id;
        const { content, habitId } = req.body;

        if (!content) {
            return res.status(400).json({ error: 'Content is required' });
        }

        // Verify the habit belongs to the user if provided
        if (habitId) {
            const habit = await prisma.habit.findFirst({ where: { id: habitId, userId } });
            if (!habit) return res.status(404).json({ error: 'Habit not found' });
        }

        const post = await prisma.post.create({
            data: {
                userId,
                type: 'manual',
                content,
                ...(habitId && { habitId })
            },
            include: {
                user: {
                    select: { id: true, username: true, name: true, avatar: true }
                },
                habit: { select: { name: true } }
            }
        });

        res.status(201).json({
            id: post.id,
            user: post.user,
            habit: post.habit,
            type: post.type,
            content: post.content,
            createdAt: post.createdAt.toISOString(),
            liked: false,
            isOwn: true
        });
    } catch (error) {
        console.error('[FEED POST ERROR]', error.message);
        res.status(500).json({ error: 'Error creant publicació' });
    }
});

router.get('/:id/likes', async (req, res) => {
    try {
        const { id } = req.params;

        const post = await prisma.post.findUnique({
            where: { id }
        });

        if (!post) {
            return res.status(404).json({ error: 'Post not found' });
        }

        const likes = await prisma.like.findMany({
            where: { postId: id },
            include: {
                user: {
                    select: { id: true, username: true, name: true, avatar: true }
                }
            },
            orderBy: { createdAt: 'desc' }
        });

        res.json(likes.map(l => ({
            id: l.id,
            user: l.user,
            createdAt: l.createdAt.toISOString()
        })));
    } catch (error) {
        console.error('[FEED LIKES ERROR]', error.message);
        res.status(500).json({ error: 'Error carregant likes' });
    }
});

router.post('/:id/like', async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.user.id;

        const post = await prisma.post.findUnique({
            where: { id }
        });

        if (!post) {
            return res.status(404).json({ error: 'Post not found' });
        }

        const existing = await prisma.like.findUnique({
            where: {
                userId_postId: {
                    userId,
                    postId: id
                }
            }
        });

        if (existing) {
            return res.status(400).json({ error: 'Already liked' });
        }

        const like = await prisma.like.create({
            data: {
                userId,
                postId: id
            },
            include: { user: { select: { name: true } } }
        });

        // Notify post owner (if they are not the one liking)
        if (post.userId !== userId) {
            await prisma.notification.create({
                data: {
                    userId: post.userId,
                    type: 'like',
                    message: `${like.user.name} ha donat like a la teva publicació`
                }
            }).catch(() => {}); // Non-blocking
        }

        res.status(201).json(like);
    } catch (error) {
        console.error('[FEED LIKE ERROR]', error.message);
        res.status(500).json({ error: 'Error fent like' });
    }
});

router.delete('/:id/like', async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.user.id;

        const existing = await prisma.like.findUnique({
            where: {
                userId_postId: {
                    userId,
                    postId: id
                }
            }
        });

        if (!existing) {
            return res.status(404).json({ error: 'Like not found' });
        }

        await prisma.like.delete({
            where: { id: existing.id }
        });

        res.json({ message: 'Like removed' });
    } catch (error) {
        console.error('[FEED UNLIKE ERROR]', error.message);
        res.status(500).json({ error: 'Error treient like' });
    }
});

module.exports = router;
