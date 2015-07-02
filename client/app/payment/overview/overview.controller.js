'use strict';

angular.module('seisanApp')
.controller('OverviewCtrl', function ($scope, $http, Auth, User, socket) {

  // Use the User $resource to fetch all users
  // $scope.users = User.query();
  $scope.overview = {};
  $scope.myPayments = [];
  $scope.theirPayments = [];
  $scope.newPaidParticipants = [];
  $scope.loginUser = Auth.getCurrentUser();

  $http.get('/api/payments/payer/'+$scope.loginUser._id).success(function(payments) {
    $scope.myPayments = payments;
    socket.syncUpdates('payment', $scope.myPayments);
  });

  $http.get('/api/payments/payee/'+$scope.loginUser._id).success(function(payments) {
    $scope.theirPayments = payments;
    socket.syncUpdates('payment', $scope.theirPayments);
  });

  $http.get('/api/payments/overview/'+$scope.loginUser._id)
  .success(function(overview) {
    $scope.overview = overview;
  });

  $scope.getOverview = function() {

    var paid = _($scope.myPayments)
    .filter(function(payment){
      return !payment.isDelete;
    }).map(function(payment) {
      return payment.amount;
    }).reduce(function(sum, amount){
      return sum += amount;
    },0);

    var haveToPay = _($scope.theirPayments)
    .filter(function(payment){
      return !payment.isDelete;
    }).map(function(payment) {
      return payment.amount / payment.participantsIds.length;
    }).reduce(function(sum, amount){
      return sum += amount;
    },0);

    return {
      'amount': paid - haveToPay,
      'paid': paid,
      'haveToPay': haveToPay
    };
  };

  $scope.$on('edit-payment', function (event, id) {
    $http.delete('/api/payments/' + id);
    angular.forEach($scope.myPayments, function(p, i) {
      if (p._id === id) {
        $scope.myPayments.splice(i, 1);
      }
    });
    angular.forEach($scope.theirPayments, function(p, i) {
      if (p._id === id) {
        $scope.theirPayments.splice(i, 1);
      }
    });
  });

  $scope.$on('delete-payment', function (event, id) {
    $http.delete('/api/payments/' + id);
    angular.forEach($scope.myPayments, function(p, i) {
      if (p._id === id) {
        $scope.myPayments.splice(i, 1);
      }
    });
    angular.forEach($scope.theirPayments, function(p, i) {
      if (p._id === id) {
        $scope.theirPayments.splice(i, 1);
      }
    });
  });

  $scope.$on('$destroy', function () {
    socket.unsyncUpdates('payment');
  });

});
