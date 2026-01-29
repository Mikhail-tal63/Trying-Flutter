const Joi = require('joi');
const { TASK_PRIORITIES, TASK_STATUSES, LIST_ROLES } = require('./constants');

const objectId = Joi.string().pattern(/^[0-9a-fA-F]{24}$/);

const authRegisterSchema = Joi.object({
  username: Joi.string().min(3).max(30).required(),
  email: Joi.string().email().required(),
  password: Joi.string().min(6).max(128).required(),
});

const authLoginSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().required(),
});

const authRefreshSchema = Joi.object({
  refreshToken: Joi.string().required(),
});

const authLogoutSchema = Joi.object({
  refreshToken: Joi.string().required(),
});

const authUpdateSchema = Joi.object({
  username: Joi.string().min(3).max(30),
  email: Joi.string().email(),
  avatar: Joi.string().allow('', null),
  settings: Joi.object({
    theme: Joi.string().valid('light', 'dark').default('light'),
    language: Joi.string().default('ar'),
    notifications: Joi.boolean(),
  }).unknown(false),
}).min(1);

const taskCreateSchema = Joi.object({
  title: Joi.string().min(1).max(200).required(),
  description: Joi.string().allow('', null),
  priority: Joi.string().valid(...TASK_PRIORITIES),
  status: Joi.string().valid(...TASK_STATUSES),
  dueDate: Joi.date().allow(null),
  reminderDate: Joi.date().allow(null),
  tags: Joi.array().items(Joi.string().max(50)).default([]),
  notes: Joi.string().allow('', null),
  notificationSettings: Joi.object().unknown(true),
  attachments: Joi.array().items(
    Joi.object({
      url: Joi.string().uri().required(),
      fileName: Joi.string().allow('', null),
      mimeType: Joi.string().allow('', null),
      size: Joi.number().integer().min(0).allow(null),
    }).unknown(false)
  ),
  listId: objectId.allow(null),
});

const taskUpdateSchema = Joi.object({
  title: Joi.string().min(1).max(200),
  description: Joi.string().allow('', null),
  priority: Joi.string().valid(...TASK_PRIORITIES),
  status: Joi.string().valid(...TASK_STATUSES),
  dueDate: Joi.date().allow(null),
  reminderDate: Joi.date().allow(null),
  tags: Joi.array().items(Joi.string().max(50)),
  notes: Joi.string().allow('', null),
  notificationSettings: Joi.object().unknown(true),
  attachments: Joi.array().items(
    Joi.object({
      url: Joi.string().uri().required(),
      fileName: Joi.string().allow('', null),
      mimeType: Joi.string().allow('', null),
      size: Joi.number().integer().min(0).allow(null),
    }).unknown(false)
  ),
  listId: objectId.allow(null),
}).min(1);

const listCreateSchema = Joi.object({
  name: Joi.string().min(1).max(100).required(),
  description: Joi.string().allow('', null),
  color: Joi.string().allow('', null),
  isPublic: Joi.boolean().default(false),
});

const listUpdateSchema = Joi.object({
  name: Joi.string().min(1).max(100),
  description: Joi.string().allow('', null),
  color: Joi.string().allow('', null),
  isPublic: Joi.boolean(),
}).min(1);

const listInviteSchema = Joi.object({
  userIdentifier: Joi.string().required(),
  role: Joi.string().valid(...LIST_ROLES).default('viewer'),
});

const listJoinSchema = Joi.object({
  role: Joi.string().valid(...LIST_ROLES).default('viewer'),
});

const achievementsCheckSchema = Joi.object({}).unknown(false);

const tasksSyncSchema = Joi.object({
  lastSyncAt: Joi.date().allow(null),
  clientTime: Joi.date().allow(null),
  tasks: Joi.array()
    .items(
      Joi.object({
        _id: objectId.allow(null),
        title: Joi.string().min(1).max(200).required(),
        description: Joi.string().allow('', null),
        priority: Joi.string().valid(...TASK_PRIORITIES).default('normal'),
        status: Joi.string().valid(...TASK_STATUSES).default('pending'),
        dueDate: Joi.date().allow(null),
        reminderDate: Joi.date().allow(null),
        tags: Joi.array().items(Joi.string().max(50)).default([]),
        notes: Joi.string().allow('', null),
        notificationSettings: Joi.object().unknown(true),
        listId: objectId.allow(null),
        updatedAt: Joi.date().allow(null),
        deleted: Joi.boolean().default(false),
      }).unknown(false)
    )
    .default([]),
}).unknown(false);

module.exports = {
  schemas: {
    authRegisterSchema,
    authLoginSchema,
    authRefreshSchema,
    authLogoutSchema,
    authUpdateSchema,
    taskCreateSchema,
    taskUpdateSchema,
    listCreateSchema,
    listUpdateSchema,
    listInviteSchema,
    listJoinSchema,
    achievementsCheckSchema,
    tasksSyncSchema,
  },
};
