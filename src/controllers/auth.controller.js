const User = require('../models/User');
const { asyncHandler } = require('../utils/helpers');
const {
  issueAuthTokens,
  rotateRefreshToken,
  revokeRefreshToken,
} = require('../services/auth.service');

function sanitizeUser(user) {
  return {
    id: user._id,
    username: user.username,
    email: user.email,
    avatar: user.avatar,
    role: user.role,
    createdAt: user.createdAt,
    lastLogin: user.lastLogin,
    settings: user.settings,
  };
}

const register = asyncHandler(async (req, res) => {
  const { username, email, password } = req.body;

  const existing = await User.findOne({ $or: [{ username }, { email: email.toLowerCase() }] });
  if (existing) {
    return res.status(409).json({ success: false, message: 'User already exists' });
  }

  const user = await User.create({ username, email, password });

  const tokens = await issueAuthTokens(user);

  return res.status(201).json({
    success: true,
    message: 'Registered successfully',
    data: {
      user: sanitizeUser(user),
      tokens,
    },
  });
});

const login = asyncHandler(async (req, res) => {
  const { email, password } = req.body;

  const user = await User.findOne({ email: email.toLowerCase() }).select('+password');
  if (!user) {
    return res.status(401).json({ success: false, message: 'Invalid credentials' });
  }

  const ok = await user.comparePassword(password);
  if (!ok) {
    return res.status(401).json({ success: false, message: 'Invalid credentials' });
  }

  user.lastLogin = new Date();
  await user.save();

  const tokens = await issueAuthTokens(user);

  return res.json({
    success: true,
    message: 'Logged in successfully',
    data: {
      user: sanitizeUser(user),
      tokens,
    },
  });
});

const logout = asyncHandler(async (req, res) => {
  const { refreshToken } = req.body;

  await revokeRefreshToken({ refreshToken });

  return res.json({ success: true, message: 'Logged out successfully' });
});

const refresh = asyncHandler(async (req, res) => {
  const { refreshToken } = req.body;

  const userId = req.user ? req.user.id : null;

  let user;
  if (userId) {
    user = await User.findById(userId);
  }

  if (!user) {
    const decodedId = require('jsonwebtoken').decode(refreshToken)?.sub;
    if (!decodedId) return res.status(401).json({ success: false, message: 'Invalid refresh token' });
    user = await User.findById(decodedId);
  }

  if (!user) {
    return res.status(401).json({ success: false, message: 'Invalid refresh token' });
  }

  const tokens = await rotateRefreshToken(refreshToken, user);

  return res.json({
    success: true,
    message: 'Token refreshed',
    data: {
      tokens,
    },
  });
});

const me = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user.id);
  if (!user) {
    return res.status(404).json({ success: false, message: 'User not found' });
  }

  return res.json({ success: true, message: 'OK', data: { user: sanitizeUser(user) } });
});

const updateProfile = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user.id);
  if (!user) {
    return res.status(404).json({ success: false, message: 'User not found' });
  }

  const { username, email, avatar, settings } = req.body;

  if (username && username !== user.username) user.username = username;
  if (email && email.toLowerCase() !== user.email) user.email = email.toLowerCase();
  if (typeof avatar !== 'undefined') user.avatar = avatar;
  if (settings) user.settings = { ...user.settings, ...settings };

  await user.save();

  return res.json({
    success: true,
    message: 'Profile updated',
    data: { user: sanitizeUser(user) },
  });
});

module.exports = {
  register,
  login,
  logout,
  refresh,
  me,
  updateProfile,
};
