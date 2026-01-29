const Task = require('../models/Task');
const List = require('../models/List');
const { asyncHandler } = require('../utils/helpers');
const { requireListRole, getAccessibleListIds } = require('../services/listAccess.service');
const { logActivity } = require('../services/activity.service');
const { checkAchievements } = require('../services/achievement.service');
const { syncTasks } = require('../services/sync.service');

async function ensureTaskAccess(task, userId, mode) {
  if (!task || task.deletedAt) {
    const err = new Error('Task not found');
    err.statusCode = 404;
    throw err;
  }

  if (!task.listId) {
    if (String(task.userId) !== String(userId)) {
      const err = new Error('Forbidden');
      err.statusCode = 403;
      throw err;
    }
    return { list: null, role: null };
  }

  return requireListRole({ listId: task.listId, userId, mode });
}

function buildTasksFilterQuery({ userId, query, accessibleListIds }) {
  const q = { deletedAt: null };

  const listId = query.listId || null;

  if (listId) {
    q.listId = listId;
  } else {
    q.$or = [{ userId, listId: null }, { listId: { $in: accessibleListIds } }];
  }

  if (query.status) q.status = query.status;
  if (query.priority) q.priority = query.priority;

  if (query.tag) q.tags = query.tag;
  if (query.tags) q.tags = { $in: String(query.tags).split(',').map((t) => t.trim()).filter(Boolean) };

  if (query.fromDate || query.toDate) {
    q.createdAt = {};
    if (query.fromDate) q.createdAt.$gte = new Date(query.fromDate);
    if (query.toDate) q.createdAt.$lte = new Date(query.toDate);
  }

  if (query.dueFrom || query.dueTo) {
    q.dueDate = {};
    if (query.dueFrom) q.dueDate.$gte = new Date(query.dueFrom);
    if (query.dueTo) q.dueDate.$lte = new Date(query.dueTo);
  }

  if (query.search) {
    q.$and = q.$and || [];
    q.$and.push({ title: { $regex: String(query.search), $options: 'i' } });
  }

  return q;
}

const listTasks = asyncHandler(async (req, res) => {
  const userId = req.user.id;

  const accessibleListIds = await getAccessibleListIds(userId);

  const requestedListIdRaw = req.query.listId;
  const requestedListId =
    typeof requestedListIdRaw === 'string' && requestedListIdRaw.trim() !== ''
      ? requestedListIdRaw.trim()
      : null;

  if (requestedListId && requestedListId !== 'null' && requestedListId !== 'undefined') {
    await requireListRole({ listId: requestedListId, userId, mode: 'view' });
  }

  const filter = buildTasksFilterQuery({ userId, query: req.query, accessibleListIds });

  const sortBy = req.query.sortBy || 'createdAt';
  const sortOrder = (req.query.sortOrder || 'desc').toLowerCase() === 'asc' ? 1 : -1;

  const page = Math.max(1, Number(req.query.page || 1));
  const limit = Math.min(100, Math.max(1, Number(req.query.limit || 20)));
  const skip = (page - 1) * limit;

  const [items, total] = await Promise.all([
    Task.find(filter).sort({ [sortBy]: sortOrder }).skip(skip).limit(limit),
    Task.countDocuments(filter),
  ]);

  return res.json({
    success: true,
    message: 'OK',
    data: {
      items,
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit) || 1,
    },
  });
});

const getTask = asyncHandler(async (req, res) => {
  const task = await Task.findById(req.params.id);
  await ensureTaskAccess(task, req.user.id, 'view');

  return res.json({ success: true, message: 'OK', data: task });
});

const createTask = asyncHandler(async (req, res) => {
  const userId = req.user.id;

  const payload = { ...req.body };

  if (payload.listId) {
    await requireListRole({ listId: payload.listId, userId, mode: 'edit' });
  }

  const task = await Task.create({
    ...payload,
    userId,
    completedAt: payload.status === 'completed' ? new Date() : null,
    isSynced: true,
  });

  if (payload.listId) {
    await List.updateOne({ _id: payload.listId }, { $addToSet: { tasks: task._id } });
  }

  await logActivity({ userId, action: 'task_created', taskId: task._id, listId: task.listId });

  return res.status(201).json({ success: true, message: 'Task created', data: task });
});

const updateTask = asyncHandler(async (req, res) => {
  const userId = req.user.id;

  const task = await Task.findById(req.params.id);
  const access = await ensureTaskAccess(task, userId, 'edit');

  const prevListId = task.listId ? String(task.listId) : null;
  const nextListId = typeof req.body.listId === 'undefined' ? prevListId : (req.body.listId ? String(req.body.listId) : null);

  if (typeof req.body.listId !== 'undefined' && nextListId) {
    await requireListRole({ listId: nextListId, userId, mode: 'edit' });
  }

  Object.assign(task, req.body);

  if (typeof req.body.status !== 'undefined') {
    if (req.body.status === 'completed') {
      if (!task.completedAt) task.completedAt = new Date();
    } else {
      task.completedAt = null;
    }
  }

  task.isSynced = true;
  await task.save();

  if (prevListId !== nextListId) {
    if (prevListId) {
      await List.updateOne({ _id: prevListId }, { $pull: { tasks: task._id } });
    }
    if (nextListId) {
      await List.updateOne({ _id: nextListId }, { $addToSet: { tasks: task._id } });
    }
  }

  await logActivity({ userId, action: 'task_updated', taskId: task._id, listId: task.listId, details: { prevListId, nextListId } });

  const achievementResult = await checkAchievements(userId);

  return res.json({
    success: true,
    message: 'Task updated',
    data: {
      task,
      achievements: achievementResult,
    },
  });
});

const deleteTask = asyncHandler(async (req, res) => {
  const userId = req.user.id;

  const task = await Task.findById(req.params.id);
  await ensureTaskAccess(task, userId, 'edit');

  task.deletedAt = new Date();
  task.isSynced = true;
  await task.save();

  if (task.listId) {
    await List.updateOne({ _id: task.listId }, { $pull: { tasks: task._id } });
  }

  await logActivity({ userId, action: 'task_deleted', taskId: task._id, listId: task.listId });

  return res.json({ success: true, message: 'Task deleted' });
});

const toggleTask = asyncHandler(async (req, res) => {
  const userId = req.user.id;

  const task = await Task.findById(req.params.id);
  await ensureTaskAccess(task, userId, 'edit');

  task.status = task.status === 'completed' ? 'pending' : 'completed';
  task.completedAt = task.status === 'completed' ? new Date() : null;
  task.isSynced = true;

  await task.save();

  await logActivity({ userId, action: 'task_toggled', taskId: task._id, listId: task.listId, details: { status: task.status } });

  const achievementResult = await checkAchievements(userId);

  return res.json({
    success: true,
    message: 'Task status updated',
    data: {
      task,
      achievements: achievementResult,
    },
  });
});

const taskStats = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const accessibleListIds = await getAccessibleListIds(userId);

  const baseQuery = {
    deletedAt: null,
    $or: [{ userId, listId: null }, { listId: { $in: accessibleListIds } }],
  };

  const [total, completed] = await Promise.all([
    Task.countDocuments(baseQuery),
    Task.countDocuments({ ...baseQuery, status: 'completed' }),
  ]);

  const completionRate = total === 0 ? 0 : Math.round((completed / total) * 10000) / 100;

  const priorityDistributionAgg = await Task.aggregate([
    { $match: baseQuery },
    { $group: { _id: '$priority', count: { $sum: 1 } } },
  ]);

  const statusDistributionAgg = await Task.aggregate([
    { $match: baseQuery },
    { $group: { _id: '$status', count: { $sum: 1 } } },
  ]);

  const avgCompletionAgg = await Task.aggregate([
    { $match: { ...baseQuery, status: 'completed', completedAt: { $ne: null } } },
    {
      $project: {
        durationMs: { $subtract: ['$completedAt', '$createdAt'] },
      },
    },
    { $group: { _id: null, avgMs: { $avg: '$durationMs' } } },
  ]);

  const avgCompletionTimeMs = avgCompletionAgg[0] ? Math.round(avgCompletionAgg[0].avgMs) : 0;

  return res.json({
    success: true,
    message: 'OK',
    data: {
      totalTasks: total,
      completedTasks: completed,
      completionRate,
      priorityDistribution: priorityDistributionAgg.reduce((acc, x) => {
        acc[x._id] = x.count;
        return acc;
      }, {}),
      statusDistribution: statusDistributionAgg.reduce((acc, x) => {
        acc[x._id] = x.count;
        return acc;
      }, {}),
      avgCompletionTimeMs,
    },
  });
});

const sync = asyncHandler(async (req, res) => {
  const userId = req.user.id;

  const { lastSyncAt, tasks } = req.body;
  const result = await syncTasks({ userId, lastSyncAt, tasks });

  return res.json({
    success: true,
    message: 'Synced',
    data: result,
  });
});

module.exports = {
  listTasks,
  getTask,
  createTask,
  updateTask,
  deleteTask,
  toggleTask,
  taskStats,
  sync,
};
