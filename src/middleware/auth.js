const jwt = require('jsonwebtoken');

function auth(req, res, next) {
  const header = req.headers.authorization || '';
  const [type, token] = header.split(' ');

  if (type !== 'Bearer' || !token) {
    const err = new Error('Unauthorized');
    err.statusCode = 401;
    return next(err);
  }

  try {
    const payload = jwt.verify(token, process.env.JWT_ACCESS_SECRET);
    req.user = {
      id: payload.sub,
      role: payload.role,
    };
    return next();
  } catch (e) {
    const err = new Error('Unauthorized');
    err.statusCode = 401;
    return next(err);
  }
}

function requireRole(roles) {
  return function requireRoleMiddleware(req, res, next) {
    const role = req.user && req.user.role;
    if (!role || !roles.includes(role)) {
      const err = new Error('Forbidden');
      err.statusCode = 403;
      return next(err);
    }
    return next();
  };
}

module.exports = {
  auth,
  requireRole,
};
