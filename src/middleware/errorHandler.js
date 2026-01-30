function errorHandler(err, req, res, next) {
  const statusCode = Number(err.statusCode || err.status || 500);
  const message = err.message || 'Internal Server Error';

  console.error('[ErrorHandler] Error:', err);

  res.status(statusCode).json({
    success: false,
    message,
    ...(process.env.NODE_ENV !== 'production' ? { stack: err.stack } : {}),
  });
}

module.exports = errorHandler;
