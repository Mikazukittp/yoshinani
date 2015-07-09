/**
 * Populate DB with sample data on server start
 * to disable, edit config/environment/index.js, and set `seedDB: false`
 */

 'use strict';

 var _ = require('lodash');
 var Thing = require('../api/thing/thing.model');
 var Payment = require('../api/payment/payment.model');
 var User = require('../api/user/user.model');
 var Group = require('../api/group/group.model');

Thing.find({}).remove(function(){});

User.find({}).remove(function() {
  User.create({
    provider: 'local',
    name: '石部 達也',
    email: 'tatsuya_i7@r.recruit.co.jp',
    password: 'tatsuya_i7',
    currentHaveToPay: 0,
    currentPaid: 0
  }, {
    provider: 'local',
    name: '大迫 正和',
    email: 'masakazu_osako@r.recruit.co.jp',
    password: 'masakazu_osako',
    currentHaveToPay: 0,
    currentPaid: 0
  }, {
    provider: 'local',
    name: '奥野 悠一',
    email: 'yokuno0925@r.recruit.co.jp',
    password: 'yokuno0925',
    currentHaveToPay: 0,
    currentPaid: 0
  }, {
    provider: 'local',
    name: '木村 憲仁',
    email: 'knorihito@r.recruit.co.jp',
    password: 'knorihito',
    currentHaveToPay: 0,
    currentPaid: 0
  }, {
    provider: 'local',
    name: '越島 健介',
    email: 'koshijima@r.recruit.co.jp',
    password: 'koshijima',
    currentHaveToPay: 0,
    currentPaid: 0
  }, {
    provider: 'local',
    name: '晒谷 亮輔',
    email: 'ryosuke_sarashiya@r.recruit.co.jp',
    password: 'ryosuke_sarashiya',
    currentHaveToPay: 0,
    currentPaid: 0
  }, {
    provider: 'local',
    name: '徳永 優作',
    email: 'yusaku_tokunaga@r.recruit.co.jp',
    password: 'yusaku_tokunaga',
    currentHaveToPay: 0,
    currentPaid: 0
  }, {
    provider: 'local',
    role: 'admin',
    name: '朏島 一樹',
    email: 'haijima@r.recruit.co.jp',
    password: 'haijima',
    currentHaveToPay: 0,
    currentPaid: 0
  }, {
    provider: 'local',
    name: '本庄 智也',
    email: 't_honjo@r.recruit.co.jp',
    password: 't_honjo',
    currentHaveToPay: 0,
    currentPaid: 0
  }, {
    provider: 'local',
    name: '松山 勇輝',
    email: 'y_matsu@r.recruit.co.jp',
    password: 'y_matsu',
    currentHaveToPay: 0,
    currentPaid: 0
  }, function() {
    console.log('finished populating users');

    // 作成したUserの_idを取得
    var ids =[];
    User.find({}, {}, {sort: {'_id': 1}}, function(err, users){
      //グループを作成
      Group.find({}).remove(function() {
        Group.create({
          name: "研修1G",
          members: users
        });
      });

      ids = _.map(users, function(user){
        return user._id;
      });

      // 精算項目を作成
      // Payment.find({}).remove(function(){});
      /*
      user 0:石部, 1:大迫, 2:奥野, 3:木村, 4:越島, 5:晒谷, 6:徳永, 7:朏島, 8:本庄, 9:松山
      */
      Payment.find({}).remove(function() {
        Payment.create({
          amount: 1800,
          paidUserId: ids[7],
          participantsIds: [ids[0],ids[1],ids[3],ids[4],ids[5],ids[6],ids[7],ids[9]],
          date: '2014-12-26',
          event: '大森忘年会',
          description: '酒代'
        }, {
          amount: 20000,
          paidUserId: ids[7],
          participantsIds: [ids[0],ids[1],ids[4],ids[5],ids[6],ids[7]],
          date: '2014-12-06',
          event: '葉山',
          description: '焼肉代'
        }, {
          amount: 4000,
          paidUserId: ids[7],
          participantsIds: [ids[0],ids[1],ids[4],ids[5],ids[6],ids[7]],
          date: '2014-12-06',
          event: '葉山',
          description: 'ETCカード代'
        }, {
          amount: 6000,
          paidUserId: ids[0],
          participantsIds: [ids[0],ids[1],ids[4],ids[5],ids[6],ids[7]],
          date: '2014-12-06',
          event: '葉山旅行',
          description: '酒'
        }, {
          amount: 22000,
          paidUserId: ids[0],
          participantsIds: [ids[0],ids[1],ids[4],ids[5],ids[6],ids[7]],
          date: '2014-12-06',
          event: '葉山旅行',
          description: '車代'
        }, {
          amount: 4000,
          paidUserId: ids[5],
          participantsIds: [ids[0],ids[1],ids[4],ids[5],ids[6],ids[7]],
          date: '2014-12-06',
          event: '葉山',
          description: 'ガソリン代'
        }, {
          amount: 5000,
          paidUserId: ids[6],
          participantsIds: [ids[0],ids[1],ids[4],ids[5],ids[6],ids[7]],
          date: '2014-12-14',
          event: 'Amazon合コン',
          description: 'カラオケに持ち込んだお酒'
        });
      });

    });

  });
});
