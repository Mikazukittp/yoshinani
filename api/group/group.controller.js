'use strict';

var _ = require('lodash');
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

exports.me = function(req, res, next) {
  var userId = req.user._id;
  User.findOne({
    _id: userId
  }, '-salt -hashedPassword', function(err, user) { // don't ever give out the password or salt
    if (err) return next(err);
    if (!user) return res.json(401);
    res.json(user);
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

//指定したUserをそのグループに追加
exports.addUser = function(req, res) {
  group.findById(req.params.groupId, function (err, group) {

    if (err) { return res.send(500, err); }
    if(!group) { return res.send(404); }

    _.each(req.body.members, function(newMember) {
      _.each(group.members, function(member) {
        if(member._id == newMember._id) { return res.send(500, "すでに登録してるよ"); }
      });
      group.members.push(newMember);
    });

    group.save(function (err) {
      if (err) { return handleError(res, err); }
      return res.json(200, group);
    });
  });
};

// 指定されたユーザが所属しているグループを取得
exports.belongedToBy = function(req, res) {
  var userId = req.params.userId;

  group.find({ members: {$elemMatch: {_id: userId}}}, function (err, groups) {
    if(err) return res.send(500, err);
    return res.json(200, groups);
  });
};

// Get amount how much specific user have to pay
exports.overview = function(req, res) {
  group.findById(req.params.groupId, function (err, g) {
    if(err) return res.send(500, err);
    if(!g) return res.send(404, err);
    return res.json(200, g.members);
  });
};
