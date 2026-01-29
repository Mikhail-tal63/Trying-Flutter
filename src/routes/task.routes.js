const express = require('express');

const taskController = require('../controllers/task.controller');
const { auth } = require('../middleware/auth');
const { validate } = require('../middleware/validation');
const { schemas } = require('../utils/validators');

const router = express.Router();

router.use(auth);

router.get('/stats', taskController.taskStats);
router.post('/sync', validate(schemas.tasksSyncSchema), taskController.sync);

router.get('/', taskController.listTasks);
router.get('/:id', taskController.getTask);
router.post('/', validate(schemas.taskCreateSchema), taskController.createTask);
router.put('/:id', validate(schemas.taskUpdateSchema), taskController.updateTask);
router.delete('/:id', taskController.deleteTask);
router.put('/:id/toggle', taskController.toggleTask);

module.exports = router;
