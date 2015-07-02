'use strict';

angular.module('seisanApp')
.controller('MainCtrl', function ($scope, $http, socket, Auth, User) {
  $scope.payments = [];
  $scope.newPaidParticipants = [];

  $http.get('/api/payments').success(function(payments) {
    $scope.payments = payments;
    socket.syncUpdates('payment', $scope.payments);
  });

  $http.get('/api/users').success(function(users) {
    $scope.usersInGroup = users;
    socket.syncUpdates('user', $scope.usersInGroup);
  });


  $scope.addPayment = function() {
    if($scope.newPaidAmount === '') {
      return;
    }
    // 参加者オブジェクトを追加(websocketで表示できるよう)
    var tmp = [];
    angular.forEach($scope.newPaidParticipants, function(id){
      angular.forEach($scope.usersInGroup, function(user){
        if(user._id == id){
          tmp.push(user);
          return;
        }
      });
    });
    // 追加
    $http.post('/api/payments', {
      amount: $scope.newPaidAmount,
      paidUserId: Auth.getCurrentUser()._id,
      paidUser: Auth.getCurrentUser(),
      description: $scope.newPaidDescription,
      participantsIds: $scope.newPaidParticipants,
      participants: tmp,
      date: $scope.newPaidDate || undefined,
      event: $scope.newPaidEvent
    });
    // 初期化
    tmp = [];
    $scope.clear();
  };

  $scope.deletePayment = function(payment) {
    $http.delete('/api/payments/' + payment._id);
  };

  $scope.clear = function() {
    $scope.newPaidAmount = '';
    $scope.newPaidAmount = '';
    $scope.newPaidDescription = '';
    $scope.newPaidParticipants = [];
    $scope.newPaidDate = undefined;
    $scope.newPaidEvent = '';

    $scope.paymentForm.amount.$dirty=false;
    $scope.paymentForm.description.$dirty=false;
    $scope.paymentForm.date.$dirty=false;
    $scope.paymentForm.event.$dirty=false;
  }

  $scope.toggleCheck = function (userId) {
    var idx = $scope.newPaidParticipants.indexOf(userId);
    if (angular.equals(idx, - 1)) {
      $scope.newPaidParticipants.push(userId);
    } else {
      $scope.newPaidParticipants.splice(idx, 1);
    }
  };

  $scope.$on('delete-payment', function (event, id) {
    $http.delete('/api/payments/' + id);
  });

  $scope.$on('$destroy', function () {
    socket.unsyncUpdates('payment');
    socket.unsyncUpdates('user');
  });
});
