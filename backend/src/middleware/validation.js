const { body, validationResult } = require('express-validator');

const handleValidationErrors = (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }
    next();
};

const validateRegister = [
    body('email').isEmail().normalizeEmail().withMessage('Valid email required'),
    body('password')
        .isLength({ min: 6, max: 128 })
        .withMessage('Password must be at least 6 characters'),
    body('name').notEmpty().trim().withMessage('Name is required'),
    body('username').notEmpty().trim().withMessage('Username is required'),
    handleValidationErrors
];

const validateLogin = [
    body('email').isEmail().normalizeEmail().withMessage('Valid email required'),
    body('password').notEmpty().withMessage('Password is required'),
    handleValidationErrors
];

const validateHabit = [
    body('name').notEmpty().trim().withMessage('Habit name is required'),
    body('description').optional().trim(),
    body('tags').optional().isArray(),
    handleValidationErrors
];

const validateFriendRequest = [
    body('username').notEmpty().trim().withMessage('Username is required'),
    handleValidationErrors
];

const validatePost = [
    body('content').notEmpty().trim().isLength({ max: 10000000 }).withMessage('Content is too long'),
    body('habitId').optional().isUUID().withMessage('Invalid habit ID format'),
    handleValidationErrors
];

const validateUUID = (paramName) => [
    require('express-validator').param(paramName).isUUID().withMessage(`Invalid ${paramName} format`),
    handleValidationErrors
];

module.exports = {
    validateRegister,
    validateLogin,
    validateHabit,
    validateFriendRequest,
    validatePost,
    validateUUID
};
