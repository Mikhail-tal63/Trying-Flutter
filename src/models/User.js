const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const { USER_ROLES } = require('../utils/constants');

const userSchema = new mongoose.Schema(
  {
    username: { type: String, required: true, unique: true, trim: true },
    email: { type: String, required: true, unique: true, trim: true, lowercase: true },
    password: { type: String, required: true, select: false },
    avatar: { type: String, default: null },
    role: { type: String, enum: USER_ROLES, default: 'user' },
    createdAt: { type: Date, default: Date.now },
    lastLogin: { type: Date, default: null },
    settings: {
      theme: { type: String, default: 'light' },
      language: { type: String, default: 'ar' },
      notifications: { type: Boolean, default: true },
    },
  },
  { versionKey: false }
);

userSchema.pre('save', async function preSave(next) {
  if (!this.isModified('password')) return next();
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
  return next();
});

userSchema.methods.comparePassword = async function comparePassword(plain) {
  return bcrypt.compare(plain, this.password);
};

module.exports = mongoose.model('User', userSchema);
