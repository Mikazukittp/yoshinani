/**
 * Using Rails-like standard naming convention for endpoints.
 * GET     /payments              ->  index
 * POST    /payments              ->  create
 * GET     /payments/:id          ->  show
 * PUT     /payments/:id          ->  update
 * DELETE  /payments/:id          ->  destroy
 */

 'use strict';

 var _ = require('lodash');
 var payment = require('./payment.model');
 var Q = require('q');
 var user = require('../user/user.model');

// Get list of payments
exports.index = function(req, res) {
  payment.find({isDelete: false}, {}, {sort: {date: -1}}, function (err, payments) {
    if(err) { return handleError(res, err); }

    // 支払ったuserの情報を追加
    Q.all(payments.map(function(p){
      var d = Q.defer();
      user.findOne({_id: p.paidUserId}, '-salt -hashedPassword',　function(err, u){
        p.paidUser = u;
        d.resolve(p);
      });
      return d.promise;
    }))
    .then(function(data){
      Q.all(payments.map(function(p){
        var d = Q.defer();
        user.find({_id: {$in: p.participantsIds}}, '_id name', function(err, u){
          p.participants = u;
          d.resolve(p);
        });
        return d.promise;
      }))
      .then(function(data){
        return res.json(200, data);
      });
    });
  });

};

// Get a single payment
exports.show = function(req, res) {
  payment.findOne({isDelete: false, _id: req.params.id}, function (err, payment) {
    if(err) { return handleError(res, err); }
    if(!payment) { return res.send(404); }
    return res.json(payment);
  });
};

// Creates a new payment in the DB.
exports.create = function(req, res) {
  payment.create(req.body, function(err, payment) {
    if(err) { return handleError(res, err); }
    return res.json(201, payment);
  });
};

// 精算情報を追加
exports.adjust = function(req, res) {
  req.body.description = '精算';

  payment.create(req.body, function(err, payment) {
    // もし精算の対象者が1名以外だったらエラーにする
    if(req.body.participantsIds.length != 1 || req.body.participants.length != 1) {
      err = { message: '精算の参加者の数が不正です' };
    }

    if(err) { return handleError(res, err); }
    return res.json(201, payment);
  });
};

// Updates an existing payment in the DB.
exports.update = function(req, res) {
  if(req.body._id) { delete req.body._id; }
  payment.findOne({isDelete: false, _id: req.params.id}, function (err, payment) {
    if (err) { return handleError(res, err); }
    if(!payment) { return res.send(404); }
    var updated = _.merge(payment, req.body);
    updated.save(function (err) {
      if (err) { return handleError(res, err); }
      return res.json(200, payment);
    });
  });
};

// Deletes a payment from the DB.
exports.destroy = function(req, res) {
  payment.findOne({isDelete: false, _id: req.params.id}, function (err, payment) {
    if(err) { return handleError(res, err); }
    if(!payment) { return res.send(404); }
    payment.isDelete = true;
    payment.save(function (err) {
      if (err) { return handleError(res, err); }
      return res.send(204);
    });
  });
};

// Get amount how much specific user have to pay
exports.overview = function(req, res) {
  payment.find({isDelete: false}, function (err, payments) {
    if(err) { return handleError(res, err); }

    var paid = _(payments)
    .filter(function(payment){
      return payment.paidUserId == req.params.id;
    }).map(function(payment) {
      return payment.amount;
    }).reduce(function(sum, amount){
      return sum += amount;
    },0);

    var haveToPay = _(payments)
    .filter(function(payment){
      return _(payment.participantsIds).contains(req.params.id);
    }).map(function(payment) {
      return payment.amount / payment.participantsIds.length;
    }).reduce(function(sum, amount){
      return sum += amount;
    },0);

    return res.json(200, {
      'userId': req.params.id,
      'amount': paid - haveToPay,
      'paid': paid,
      'haveToPay': haveToPay
    });
  });
};

//
exports.payer = function(req, res) {
  payment.find({isDelete: false, paidUserId: req.params.id}, {}, {sort: {date: -1}}, function (err, payments) {
    if(err) { return handleError(res, err); }

    // 支払ったuserの情報を追加
    Q.all(payments.map(function(p){
      var d = Q.defer();
      user.findOne({_id: p.paidUserId}, '-salt -hashedPassword',　function(err, u){
        p.paidUser = u;
        d.resolve(p);
      });
      return d.promise;
    }))
    .then(function(data){
      Q.all(payments.map(function(p){
        var d = Q.defer();
        user.find({_id: {$in: p.participantsIds}}, '_id name', function(err, u){
          p.participants = u;
          d.resolve(p);
        });
        return d.promise;
      }))
      .then(function(data){
        return res.json(200, data);
      });
    });
  });
}

//
exports.payee = function(req, res) {
  payment.find({isDelete: false, participantsIds: req.params.id}, {}, {sort: {date: -1}}, function (err, payments) {
    if(err) { return handleError(res, err); }

    // 支払ったuserの情報を追加
    Q.all(payments.map(function(p){
      var d = Q.defer();
      user.findOne({_id: p.paidUserId}, '-salt -hashedPassword',　function(err, u){
        p.paidUser = u;
        d.resolve(p);
      });
      return d.promise;
    }))
    .then(function(data){
      Q.all(payments.map(function(p){
        var d = Q.defer();
        user.find({_id: {$in: p.participantsIds}}, '_id name', function(err, u){
          p.participants = u;
          d.resolve(p);
        });
        return d.promise;
      }))
      .then(function(data){
        return res.json(200, data);
      });
    });
  });
};

function handleError(res, err) {
  return res.send(500, err);
}
