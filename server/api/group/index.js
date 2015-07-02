'use strict';

var express = require('express');
var controller = require('./group.controller');
var config = require('../../config/environment');
var auth = require('../../auth/auth.service');

var router = express.Router();

router.get('/', auth.hasRole('admin'), auth.isAuthenticated(), controller.index);
router.get('/belongedToBy/:userId', auth.isAuthenticated(), controller.belongedToBy);
router.post('/addUser/:groupId', auth.isAuthenticated(), controller.sddUser);
router.delete('/:groupId', auth.hasRole('admin'), controller.destroy);
router.get('/:groupId', auth.isAuthenticated(), controller.show);
router.post('/', controller.create);

module.exports = router;
