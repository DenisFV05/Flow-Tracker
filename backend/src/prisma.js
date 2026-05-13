const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient({
    log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
});

prisma.$connect().catch(err => {
    console.error('[PRISMA] Connection failed:', err.message);
});

process.on('beforeExit', async () => {
    await prisma.$disconnect();
});

module.exports = prisma;
