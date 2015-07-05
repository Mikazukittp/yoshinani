'use strict';

var express = require('express');
var controller = require('./user.controller');
var config = require('../../config/environment');
var auth = require('../../auth/auth.service');

var router = express.Router();

router.get('/', /*auth.hasRole('admin'),*/ controller.index);
router.delete('/:id', auth.hasRole('admin'), controller.destroy);
router.get('/me', auth.isAuthenticated(), controller.me);
router.put('/:id/password', auth.isAuthenticated(), controller.changePassword);
router.get('/:id', /*auth.isAuthenticated(),*/ controller.show);
router.post('/', controller.create);
//sarashiya追記 ーユーザーごとの支払額を取得ー
//router.get('/:id/havetopay',/* auth.isAuthenticated */, controller.hoge);
router.get('/test/:id' , controller.testUserName);

module.exports = router;
