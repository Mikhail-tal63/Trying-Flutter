function validate(schema, property = 'body') {
  return function validationMiddleware(req, res, next) {
    const { value, error } = schema.validate(req[property], {
      abortEarly: false,
      stripUnknown: true,
    });

    if (error) {
      const errorMessage = error.details.map((d) => d.message).join(', ');
      console.error('[Validation] Error:', errorMessage, 'Body:', req.body);
      const err = new Error(errorMessage);
      err.statusCode = 400;
      return next(err);
    }

    req[property] = value;
    return next();
  };
}

module.exports = {
  validate,
};
