const Task = require('../models/Task');
const { getAccessibleListIds } = require('./listAccess.service');

function toDateOrNull(value) {
  if (!value) return null;
  const d = new Date(value);
  return Number.isNaN(d.getTime()) ? null : d;
}

async function getAccessibleTasksQuery(userId) {
  const listIds = await getAccessibleListIds(userId);
  return {
    deletedAt: null,
    $or: [{ userId, listId: null }, { listId: { $in: listIds } }],
  };
}

async function syncTasks({ userId, lastSyncAt, tasks }) {
  const lastSyncDate = toDateOrNull(lastSyncAt);
  const conflicts = [];

  for (const clientTask of tasks) {
    const clientUpdatedAt = toDateOrNull(clientTask.updatedAt) || new Date();

    if (clientTask._id) {
      const server = await Task.findById(clientTask._id);

      if (!server) {
        if (clientTask.deleted) continue;

        await Task.create({
          _id: clientTask._id,
          userId,
          title: clientTask.title,
          description: clientTask.description || null,
          priority: clientTask.priority,
          status: clientTask.status,
          dueDate: toDateOrNull(clientTask.dueDate),
          reminderDate: toDateOrNull(clientTask.reminderDate),
          tags: clientTask.tags || [],
          notes: clientTask.notes || null,
          notificationSettings: clientTask.notificationSettings || null,
          listId: clientTask.listId || null,
          isSynced: true,
          completedAt: clientTask.status === 'completed' ? new Date() : null,
          updatedAt: clientUpdatedAt,
        });

        continue;
      }

      const serverUpdatedAt = server.updatedAt ? new Date(server.updatedAt) : new Date(0);

      if (clientUpdatedAt.getTime() < serverUpdatedAt.getTime()) {
        conflicts.push({
          taskId: server._id,
          resolution: 'server_wins',
          serverUpdatedAt,
          clientUpdatedAt,
        });
        continue;
      }

      if (clientTask.deleted) {
        server.deletedAt = new Date();
        await server.save();
        continue;
      }

      server.title = clientTask.title;
      server.description = clientTask.description || null;
      server.priority = clientTask.priority;
      server.status = clientTask.status;
      server.dueDate = toDateOrNull(clientTask.dueDate);
      server.reminderDate = toDateOrNull(clientTask.reminderDate);
      server.tags = clientTask.tags || [];
      server.notes = clientTask.notes || null;
      server.notificationSettings = clientTask.notificationSettings || null;
      server.listId = clientTask.listId || null;
      server.isSynced = true;
      if (clientTask.status === 'completed' && !server.completedAt) server.completedAt = new Date();
      if (clientTask.status !== 'completed') server.completedAt = null;

      server.updatedAt = clientUpdatedAt;
      await server.save();

      continue;
    }

    if (clientTask.deleted) continue;

    await Task.create({
      userId,
      title: clientTask.title,
      description: clientTask.description || null,
      priority: clientTask.priority,
      status: clientTask.status,
      dueDate: toDateOrNull(clientTask.dueDate),
      reminderDate: toDateOrNull(clientTask.reminderDate),
      tags: clientTask.tags || [],
      notes: clientTask.notes || null,
      notificationSettings: clientTask.notificationSettings || null,
      listId: clientTask.listId || null,
      isSynced: true,
      completedAt: clientTask.status === 'completed' ? new Date() : null,
      updatedAt: clientUpdatedAt,
    });
  }

  const baseQuery = await getAccessibleTasksQuery(userId);

  const serverChangesQuery = {
    ...baseQuery,
    ...(lastSyncDate ? { updatedAt: { $gt: lastSyncDate } } : {}),
  };

  const serverChanges = await Task.find(serverChangesQuery).sort({ updatedAt: -1 });

  return {
    lastSyncAt: new Date(),
    conflicts,
    serverChanges,
  };
}

module.exports = {
  syncTasks,
};
