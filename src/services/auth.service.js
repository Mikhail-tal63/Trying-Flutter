const crypto = require('crypto');
const jwt = require('jsonwebtoken');

const RefreshToken = require('../models/RefreshToken');

function sha256(input) {
  return crypto.createHash('sha256').update(input).digest('hex');
}

function parseExpiresToSeconds(expiresIn) {
  if (!expiresIn) return 0;
  if (typeof expiresIn === 'number') return expiresIn;

  const m = String(expiresIn).trim().match(/^([0-9]+)\s*([smhd])$/i);
  if (!m) return 0;

  const value = Number(m[1]);
  const unit = m[2].toLowerCase();

  if (unit === 's') return value;
  if (unit === 'm') return value * 60;
  if (unit === 'h') return value * 60 * 60;
  if (unit === 'd') return value * 60 * 60 * 24;
  return 0;
}

function getAccessTokenOptions() {
  const expiresIn = process.env.JWT_ACCESS_EXPIRES_IN || '15m';
  return { expiresIn };
}

function getRefreshTokenOptions() {
  const expiresIn = process.env.JWT_REFRESH_EXPIRES_IN || '30d';
  return { expiresIn };
}

function signAccessToken(user) {
  if (!process.env.JWT_ACCESS_SECRET) throw new Error('JWT_ACCESS_SECRET is required');

  return jwt.sign(
    { role: user.role },
    process.env.JWT_ACCESS_SECRET,
    {
      subject: String(user._id),
      ...getAccessTokenOptions(),
    }
  );
}

function signRefreshToken(user) {
  if (!process.env.JWT_REFRESH_SECRET) throw new Error('JWT_REFRESH_SECRET is required');

  const jti = crypto.randomUUID ? crypto.randomUUID() : crypto.randomBytes(16).toString('hex');

  return jwt.sign(
    { jti },
    process.env.JWT_REFRESH_SECRET,
    {
      subject: String(user._id),
      ...getRefreshTokenOptions(),
    }
  );
}

async function storeRefreshToken({ userId, refreshToken }) {
  const refreshExpiresIn = process.env.JWT_REFRESH_EXPIRES_IN || '30d';
  const seconds = parseExpiresToSeconds(refreshExpiresIn) || 60 * 60 * 24 * 30;
  const expiresAt = new Date(Date.now() + seconds * 1000);

  const tokenHash = sha256(refreshToken);

  await RefreshToken.create({
    userId,
    tokenHash,
    expiresAt,
  });

  return { tokenHash, expiresAt };
}

async function revokeRefreshToken({ refreshToken, replacedByToken }) {
  const tokenHash = sha256(refreshToken);

  const update = {
    revokedAt: new Date(),
  };

  if (replacedByToken) {
    update.replacedByTokenHash = sha256(replacedByToken);
  }

  await RefreshToken.updateOne(
    { tokenHash, revokedAt: null },
    { $set: update }
  );
}

async function validateStoredRefreshToken(refreshToken) {
  let decoded;
  try {
    decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);
  } catch (e) {
    const err = new Error('Invalid refresh token');
    err.statusCode = 401;
    throw err;
  }
  const tokenHash = sha256(refreshToken);

  const record = await RefreshToken.findOne({ tokenHash });
  if (!record) {
    const err = new Error('Invalid refresh token');
    err.statusCode = 401;
    throw err;
  }

  if (record.revokedAt) {
    const err = new Error('Refresh token revoked');
    err.statusCode = 401;
    throw err;
  }

  if (record.expiresAt && record.expiresAt.getTime() < Date.now()) {
    const err = new Error('Refresh token expired');
    err.statusCode = 401;
    throw err;
  }

  return {
    userId: decoded.sub,
    record,
  };
}

async function issueAuthTokens(user) {
  const accessToken = signAccessToken(user);
  const refreshToken = signRefreshToken(user);
  await storeRefreshToken({ userId: user._id, refreshToken });

  return { accessToken, refreshToken };
}

async function rotateRefreshToken(refreshToken, user) {
  await validateStoredRefreshToken(refreshToken);

  const accessToken = signAccessToken(user);
  const newRefreshToken = signRefreshToken(user);

  await revokeRefreshToken({ refreshToken, replacedByToken: newRefreshToken });
  await storeRefreshToken({ userId: user._id, refreshToken: newRefreshToken });

  return { accessToken, refreshToken: newRefreshToken };
}

module.exports = {
  issueAuthTokens,
  rotateRefreshToken,
  validateStoredRefreshToken,
  revokeRefreshToken,
};
