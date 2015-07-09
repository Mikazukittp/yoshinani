'use strict';

var express = require('express');
var controller = require('./group.controller');
var config = require('../../config/environment');
var auth = require('../../auth/auth.service');

var router = express.Router();

router.get('/', auth.hasRole('admin'), auth.isAuthenticated(), controller.index);
router.get('/belongedToBy/:userId', auth.isAuthenticated(), controller.belongedToBy);
router.post('/addUser/:groupId', auth.isAuthenticated(), controller.addUser);
router.delete('/:groupId', auth.hasRole('admin'), controller.destroy);
router.get('/:groupId', auth.isAuthenticated(), controller.show);
router.get('/overview/:groupId', auth.isAuthenticated(), controller.overview);
router.post('/', controller.create);
router.get('/me', auth.isAuthenticated(), controller.me);

module.exports = router;
