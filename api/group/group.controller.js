'use strict';

var group = require('./group.model');
var user = require('../user/user.model');
var payment = require('../payment/payment.model');
var passport = require('passport');
var config = require('../../config/environment');
var jwt = require('jsonwebtoken');

var validationError = function(res, err) {
  return res.json(422, err);
};

/**
 * Get list of groups
 * restriction: 'admin'
 */
exports.index = function(req, res) {
  group.find({}, function (err, groups) {
    console.log(err);
    console.log(groups);
    if(err) return res.send(500, err);
    res.json(200, groups);
  });
};

/**
 * Creates a new group
 */
exports.create = function (req, res, next) {
  var newgroup = new group(req.body);
  newgroup.provider = 'local';
  newgroup.role = 'group';
  newgroup.save(function(err, group) {
    if (err) return validationError(res, err);
    var token = jwt.sign({_id: group._id }, config.secrets.session, { expiresInMinutes: 60*5 });
    res.json({ token: token });
  });
};

/**
 * Get a single group
 */
exports.show = function (req, res, next) {
  var groupId = req.params.groupId;

  group.findById(groupId, function (err, group) {
    if (err) return next(err);
    if (!group) return res.send(401);
    res.json(group.profile);
  });
};

/**
 * Deletes a group
 * restriction: 'admin'
 */
exports.destroy = function(req, res) {
  group.findByIdAndRemove(req.params.groupId, function(err, group) {
    if(err) return res.send(500, err);
    return res.send(204);
  });
};


exports.belongedToBy = function(req, res) {
  var userId = req.params.userId;

  // 指定されたユーザが所属しているグループを取得
};

// Get amount how much specific user have to pay
exports.overview = function(req, res) {
  group.findById(req.params.groupId, function (err, g) {
    if(err) return res.send(500, err);
    if(!g) return res.send(404, err);
    return res.json(200, g.members);
  });
};
