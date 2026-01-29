const express = require('express');

const achievementController = require('../controllers/achievement.controller');
const { auth } = require('../middleware/auth');
const { validate } = require('../middleware/validation');
const { schemas } = require('../utils/validators');

const router = express.Router();

router.use(auth);

router.get('/', achievementController.listAchievements);
router.get('/:id', achievementController.getAchievement);
router.post('/check', validate(schemas.achievementsCheckSchema), achievementController.check);

module.exports = router;
