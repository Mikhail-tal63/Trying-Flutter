const mongoose = require('mongoose');
const { ACHIEVEMENT_TYPES, ACHIEVEMENTS_DEFINITIONS } = require('../utils/constants');

const achievementSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    type: { type: String, enum: ACHIEVEMENT_TYPES, required: true },
    title: { type: String, default: null },
    description: { type: String, default: null },
    icon: { type: String, default: null },
    earnedAt: { type: Date, default: null },
    progress: { type: Number, default: 0 },
    target: { type: Number, default: 0 },
  },
  { versionKey: false }
);

achievementSchema.pre('validate', function preValidate(next) {
  const def = ACHIEVEMENTS_DEFINITIONS[this.type];
  if (def) {
    if (!this.title) this.title = def.title;
    if (!this.description) this.description = def.description;
    if (!this.target) this.target = def.target;
  }
  return next();
});

achievementSchema.index({ userId: 1, type: 1 }, { unique: true });

module.exports = mongoose.model('Achievement', achievementSchema);
