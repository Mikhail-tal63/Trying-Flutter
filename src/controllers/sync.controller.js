const { asyncHandler } = require('../utils/helpers');
const { syncTasks } = require('../services/sync.service');

const sync = asyncHandler(async (req, res) => {
  const userId = req.user.id;

  const { lastSyncAt, tasks } = req.body;
  const result = await syncTasks({ userId, lastSyncAt, tasks });

  return res.json({ success: true, message: 'Synced', data: result });
});

module.exports = {
  sync,
};
