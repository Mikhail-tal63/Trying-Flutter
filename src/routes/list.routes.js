const express = require('express');

const listController = require('../controllers/list.controller');
const { auth } = require('../middleware/auth');
const { validate } = require('../middleware/validation');
const { schemas } = require('../utils/validators');

const router = express.Router();

router.get('/public', listController.publicLists);

router.use(auth);

router.get('/', listController.listLists);
router.post('/', validate(schemas.listCreateSchema), listController.createList);
router.get('/:id', listController.getList);
router.put('/:id', validate(schemas.listUpdateSchema), listController.updateList);
router.delete('/:id', listController.deleteList);
router.post('/:id/invite', validate(schemas.listInviteSchema), listController.inviteUser);
router.post('/join/:code', validate(schemas.listJoinSchema), listController.joinByCode);

module.exports = router;
