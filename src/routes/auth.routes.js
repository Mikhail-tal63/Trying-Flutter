const express = require('express');

const authController = require('../controllers/auth.controller');
const { validate } = require('../middleware/validation');
const { schemas } = require('../utils/validators');
const { auth } = require('../middleware/auth');

const router = express.Router();

router.post('/register', validate(schemas.authRegisterSchema), authController.register);
router.post('/login', validate(schemas.authLoginSchema), authController.login);
router.post('/logout', validate(schemas.authLogoutSchema), authController.logout);
router.post('/refresh', validate(schemas.authRefreshSchema), authController.refresh);

router.get('/me', auth, authController.me);
router.put('/update', auth, validate(schemas.authUpdateSchema), authController.updateProfile);

module.exports = router;
