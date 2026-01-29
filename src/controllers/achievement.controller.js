const Achievement = require('../models/Achievement');
const { asyncHandler } = require('../utils/helpers');
const { checkAchievements } = require('../services/achievement.service');
const { logActivity } = require('../services/activity.service');

const listAchievements = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const items = await Achievement.find({ userId }).sort({ earnedAt: -1, progress: -1 });
  return res.json({ success: true, message: 'OK', data: items });
});

const getAchievement = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const item = await Achievement.findOne({ _id: req.params.id, userId });
  if (!item) return res.status(404).json({ success: false, message: 'Achievement not found' });
  return res.json({ success: true, message: 'OK', data: item });
});

const check = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const result = await checkAchievements(userId);
  await logActivity({ userId, action: 'achievements_checked', details: result });

  return res.json({
    success: true,
    message: 'Checked',
    data: result,
  });
});

module.exports = {
  listAchievements,
  getAchievement,
  check,
};
