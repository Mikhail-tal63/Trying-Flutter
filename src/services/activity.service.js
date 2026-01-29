const Activity = require('../models/Activity');

async function logActivity({ userId, action, taskId = null, listId = null, details = null }) {
  await Activity.create({
    userId,
    action,
    taskId,
    listId,
    details,
  });
}

module.exports = {
  logActivity,
};
