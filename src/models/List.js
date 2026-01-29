const mongoose = require('mongoose');
const { LIST_ROLES } = require('../utils/constants');

const listMemberSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    role: { type: String, enum: LIST_ROLES, default: 'viewer' },
    joinedAt: { type: Date, default: Date.now },
  },
  { _id: false }
);

const listSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    description: { type: String, default: null },
    ownerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    members: { type: [listMemberSchema], default: [] },
    tasks: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Task' }],
    color: { type: String, default: null },
    isPublic: { type: Boolean, default: false },
    inviteCode: { type: String, default: null, index: true },
    createdAt: { type: Date, default: Date.now },
  },
  { versionKey: false }
);

module.exports = mongoose.model('List', listSchema);
