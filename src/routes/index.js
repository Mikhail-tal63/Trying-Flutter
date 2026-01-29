const express = require('express');

const router = express.Router();

const authRoutes = require('./auth.routes');
const taskRoutes = require('./task.routes');
const listRoutes = require('./list.routes');
const achievementRoutes = require('./achievement.routes');

router.get('/health', (req, res) => {
  res.json({ success: true, message: 'OK' });
});

router.use('/auth', authRoutes);
router.use('/tasks', taskRoutes);
router.use('/lists', listRoutes);
router.use('/achievements', achievementRoutes);

module.exports = router;
