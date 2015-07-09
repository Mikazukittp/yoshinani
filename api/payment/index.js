'use strict';

var express = require('express');
var controller = require('./payment.controller');

var router = express.Router();

router.get('/', controller.index);
router.get('/index/:groupId', controller.groupIndex);
router.get('/:id', controller.show);
router.get('/overview/:id', controller.overview);
router.get('/overview/:userId/group/:groupId', controller.groupOverview);
router.get('/overview/old/:id', controller.oldOverview);
router.get('/payer/:id', controller.payer);
router.get('/payee/:id', controller.payee);
router.post('/', controller.create);
router.post('/adjust', controller.adjust);
router.put('/:id', controller.update);
router.patch('/:id', controller.update);
router.delete('/:id', controller.destroy);

module.exports = router;
