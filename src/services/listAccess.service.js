const List = require('../models/List');

function getMemberRole(list, userId) {
  const member = list.members.find((m) => String(m.userId) === String(userId));
  return member ? member.role : null;
}

function getUserRoleForList(list, userId) {
  if (!list) return null;
  if (String(list.ownerId) === String(userId)) return 'admin';
  return getMemberRole(list, userId);
}

function canView(role) {
  return role === 'viewer' || role === 'editor' || role === 'admin';
}

function canEdit(role) {
  return role === 'editor' || role === 'admin';
}

function canAdmin(role) {
  return role === 'admin';
}

async function requireListRole({ listId, userId, mode }) {
  const list = await List.findById(listId);
  if (!list) {
    const err = new Error('List not found');
    err.statusCode = 404;
    throw err;
  }

  const role = getUserRoleForList(list, userId);

  const allowed =
    mode === 'view' ? canView(role) :
    mode === 'edit' ? canEdit(role) :
    mode === 'admin' ? canAdmin(role) :
    false;

  if (!allowed) {
    const err = new Error('Forbidden');
    err.statusCode = 403;
    throw err;
  }

  return { list, role };
}

async function getAccessibleListIds(userId) {
  const lists = await List.find({
    $or: [{ ownerId: userId }, { 'members.userId': userId }],
  }).select('_id');

  return lists.map((l) => l._id);
}

module.exports = {
  getUserRoleForList,
  canView,
  canEdit,
  canAdmin,
  requireListRole,
  getAccessibleListIds,
};
