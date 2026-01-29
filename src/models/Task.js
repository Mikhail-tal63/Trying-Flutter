const mongoose = require('mongoose');
const { TASK_PRIORITIES, TASK_STATUSES } = require('../utils/constants');

const taskCommentSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    text: { type: String, required: true },
    createdAt: { type: Date, default: Date.now },
  },
  { _id: true }
);

const taskSchema = new mongoose.Schema(
  {
    title: { type: String, required: true, trim: true },
    description: { type: String, default: null },
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', index: true },
    priority: { type: String, enum: TASK_PRIORITIES, default: 'normal' },
    status: { type: String, enum: TASK_STATUSES, default: 'pending' },
    dueDate: { type: Date, default: null },
    reminderDate: { type: Date, default: null },
    tags: { type: [String], default: [] },
    notes: { type: String, default: null },
    notificationSettings: { type: mongoose.Schema.Types.Mixed, default: null },
    attachments: {
      type: [
        {
          url: { type: String, required: true },
          fileName: { type: String, default: null },
          mimeType: { type: String, default: null },
          size: { type: Number, default: null },
        },
      ],
      default: [],
    },
    completedAt: { type: Date, default: null },
    isSynced: { type: Boolean, default: true },
    listId: { type: mongoose.Schema.Types.ObjectId, ref: 'List', default: null, index: true },
    comments: { type: [taskCommentSchema], default: [] },
    deletedAt: { type: Date, default: null },
  },
  {
    timestamps: { createdAt: 'createdAt', updatedAt: 'updatedAt' },
    versionKey: false,
  }
);

module.exports = mongoose.model('Task', taskSchema);
