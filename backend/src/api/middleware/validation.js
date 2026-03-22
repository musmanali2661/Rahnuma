'use strict';

const { validationResult } = require('express-validator');

/**
 * Express error handler that formats express-validator errors.
 */
// eslint-disable-next-line no-unused-vars
module.exports = function validationErrorHandler(err, req, res, next) {
  if (err && err.type === 'entity.parse.failed') {
    return res.status(400).json({ error: 'Invalid JSON body' });
  }
  next(err);
};
