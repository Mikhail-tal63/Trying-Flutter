const crypto = require('crypto');

const List = require('../models/List');
const User = require('../models/User');
const Task = require('../models/Task');

const { asyncHandler } = require('../utils/helpers');
const { requireListRole, getUserRoleForList } = require('../services/listAccess.service');
const { sendMail } = require('../services/notification.service');
const { logActivity } = require('../services/activity.service');

function generateInviteCode() {
  return crypto.randomBytes(6).toString('hex');
}

async function ensureListAccess(list, userId, mode) {
  if (!list) {
    const err = new Error('List not found');
    err.statusCode = 404;
    throw err;
  }

  const role = getUserRoleForList(list, userId);
  const allowed =
    mode === 'view'
      ? role === 'viewer' || role === 'editor' || role === 'admin'
      : mode === 'edit'
        ? role === 'editor' || role === 'admin'
        : role === 'admin';

  if (!allowed) {
    const err = new Error('Forbidden');
    err.statusCode = 403;
    throw err;
  }

  return role;
}

const listLists = asyncHandler(async (req, res) => {
  const userId = req.user.id;

  const lists = await List.find({
    $or: [{ ownerId: userId }, { 'members.userId': userId }],
  }).sort({ createdAt: -1 });

  return res.json({ success: true, message: 'OK', data: lists });
});

const createList = asyncHandler(async (req, res) => {
  const userId = req.user.id;

  const list = await List.create({
    name: req.body.name,
    description: req.body.description || null,
    ownerId: userId,
    members: [],
    tasks: [],
    color: req.body.color || null,
    isPublic: Boolean(req.body.isPublic),
    inviteCode: generateInviteCode(),
    createdAt: new Date(),
  });

  await logActivity({ userId, action: 'list_created', listId: list._id });

  return res.status(201).json({ success: true, message: 'List created', data: list });
});

const getList = asyncHandler(async (req, res) => {
  const userId = req.user.id;

  const list = await List.findById(req.params.id).populate('members.userId', 'username email avatar');
  await ensureListAccess(list, userId, 'view');

  const totalTasks = await Task.countDocuments({ listId: list._id, deletedAt: null });
  const completedTasks = await Task.countDocuments({ listId: list._id, deletedAt: null, status: 'completed' });

  return res.json({
    success: true,
    message: 'OK',
    data: {
      list,
      progress: {
        totalTasks,
        completedTasks,
        completionRate: totalTasks === 0 ? 0 : Math.round((completedTasks / totalTasks) * 10000) / 100,
      },
    },
  });
});

const updateList = asyncHandler(async (req, res) => {
  const userId = req.user.id;

  const list = await List.findById(req.params.id);
  await ensureListAccess(list, userId, 'admin');

  if (typeof req.body.name !== 'undefined') list.name = req.body.name;
  if (typeof req.body.description !== 'undefined') list.description = req.body.description;
  if (typeof req.body.color !== 'undefined') list.color = req.body.color;
  if (typeof req.body.isPublic !== 'undefined') list.isPublic = Boolean(req.body.isPublic);

  await list.save();

  await logActivity({ userId, action: 'list_updated', listId: list._id });

  return res.json({ success: true, message: 'List updated', data: list });
});

const deleteList = asyncHandler(async (req, res) => {
  const userId = req.user.id;

  const list = await List.findById(req.params.id);
  await ensureListAccess(list, userId, 'admin');

  await Task.updateMany({ listId: list._id }, { $set: { listId: null } });
  await List.deleteOne({ _id: list._id });

  await logActivity({ userId, action: 'list_deleted', listId: list._id });

  return res.json({ success: true, message: 'List deleted' });
});

const inviteUser = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const { userIdentifier, role } = req.body;

  const list = await List.findById(req.params.id);
  await ensureListAccess(list, userId, 'admin');

  const invitedUser = await User.findOne({
    $or: [{ email: userIdentifier.toLowerCase() }, { username: userIdentifier }],
  });

  if (!invitedUser) {
    return res.status(404).json({ success: false, message: 'User not found' });
  }

  if (String(invitedUser._id) === String(list.ownerId)) {
    return res.status(400).json({ success: false, message: 'Owner is already in the list' });
  }

  const existingMember = list.members.find((m) => String(m.userId) === String(invitedUser._id));
  if (existingMember) {
    existingMember.role = role;
  } else {
    list.members.push({ userId: invitedUser._id, role, joinedAt: new Date() });
  }

  await list.save();

  await sendMail({
    to: invitedUser.email,
    subject: 'Shared List Invitation',
    text: `You have been added to list: ${list.name}`,
  });

  await logActivity({ userId, action: 'list_invited_user', listId: list._id, details: { invitedUserId: invitedUser._id, role } });

  return res.json({ success: true, message: 'User invited', data: { listId: list._id, invitedUserId: invitedUser._id } });
});

const joinByCode = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const code = req.params.code;

  const list = await List.findOne({ inviteCode: code });
  if (!list) {
    return res.status(404).json({ success: false, message: 'List not found' });
  }

  if (String(list.ownerId) === String(userId)) {
    return res.json({ success: true, message: 'Already a member', data: list });
  }

  const existingMember = list.members.find((m) => String(m.userId) === String(userId));
  if (!existingMember) {
    list.members.push({ userId, role: 'viewer', joinedAt: new Date() });
    await list.save();
    await logActivity({ userId, action: 'list_joined', listId: list._id });
  }

  return res.json({ success: true, message: 'Joined list', data: list });
});

const publicLists = asyncHandler(async (req, res) => {
  const lists = await List.find({ isPublic: true }).sort({ createdAt: -1 }).limit(50);
  return res.json({ success: true, message: 'OK', data: lists });
});

module.exports = {
  listLists,
  createList,
  getList,
  updateList,
  deleteList,
  inviteUser,
  joinByCode,
  publicLists,
};
