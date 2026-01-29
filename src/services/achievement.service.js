const Achievement = require('../models/Achievement');
const Task = require('../models/Task');
const { ACHIEVEMENT_TYPES, ACHIEVEMENTS_DEFINITIONS } = require('../utils/constants');

async function getOrCreateAchievement(userId, type) {
  let ach = await Achievement.findOne({ userId, type });
  if (!ach) {
    const def = ACHIEVEMENTS_DEFINITIONS[type];
    ach = await Achievement.create({
      userId,
      type,
      title: def ? def.title : null,
      description: def ? def.description : null,
      target: def ? def.target : 0,
      progress: 0,
      earnedAt: null,
    });
  }
  return ach;
}

async function computeProgress(userId) {
  const createdCount = await Task.countDocuments({ userId, deletedAt: null });
  const completedCount = await Task.countDocuments({
    userId,
    status: 'completed',
    deletedAt: null,
  });
  const earlyBirdCount = await Task.countDocuments({
    userId,
    status: 'completed',
    dueDate: { $ne: null },
    completedAt: { $ne: null },
    $expr: { $lte: ['$completedAt', '$dueDate'] },
    deletedAt: null,
  });
  const teamPlayerCount = await Task.countDocuments({
    userId,
    status: 'completed',
    listId: { $ne: null },
    deletedAt: null,
  });

  return {
    first_task: completedCount,
    organizer: createdCount,
    achiever: completedCount,
    early_bird: earlyBirdCount,
    team_player: teamPlayerCount,
  };
}

async function checkAchievements(userId) {
  const progressByType = await computeProgress(userId);

  const newlyEarned = [];

  for (const type of ACHIEVEMENT_TYPES) {
    const ach = await getOrCreateAchievement(userId, type);
    const progress = Number(progressByType[type] || 0);

    ach.progress = progress;
    if (!ach.earnedAt && ach.target && progress >= ach.target) {
      ach.earnedAt = new Date();
      newlyEarned.push(type);
    }

    await ach.save();
  }

  return { newlyEarned };
}

module.exports = {
  checkAchievements,
};
