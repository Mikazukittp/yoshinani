'use strict';

var express = require('express');
var controller = require('./payment.controller');

var router = express.Router();

router.get('/', controller.index);
router.get('/:id', controller.show);
router.get('/overview/:id', controller.overview);
router.get('/overview/old/:id', controller.oldOverview);
router.get('/payer/:id', controller.payer);
router.get('/payee/:id', controller.payee);
router.post('/', controller.create);
router.put('/:id', controller.update);
router.patch('/:id', controller.update);
router.delete('/:id', controller.destroy);

module.exports = router;