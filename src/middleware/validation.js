function validate(schema, property = 'body') {
  return function validationMiddleware(req, res, next) {
    const { value, error } = schema.validate(req[property], {
      abortEarly: false,
      stripUnknown: true,
    });

    if (error) {
      const err = new Error(error.details.map((d) => d.message).join(', '));
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
