'use strict';

angular.module('seisanApp')
.controller('LogCtrl', function ($scope, $http, socket, Auth, User, Pagination) {

    // Use the User $resource to fetch all users
    // $scope.users = User.query();
    $scope.payments = [];
    $http.get('/api/payments/')
    .success(function(payments) {
      $scope.payments = payments;
      angular.forEach($scope.payments, function(p, i) {
        p.haveToPay = false;
        var me = Auth.getCurrentUser()._id;
        if(p.paidUser._id != me) {
          p.participants.forEach(function(pp, i){
            p.haveToPay = p.haveToPay || pp._id == me;
          });
        }
      });
      socket.syncUpdates('payment', $scope.payments);

      //paginatorの設定
      $scope.paginator = Pagination.getNew(10);
      $scope.paginator.numPages = Math.ceil($scope.payments.length / $scope.paginator.perPage);
    });

    $scope.getUser = function(id) {
      if(!id){return {};}
      var rtn = {};
      //rtn = User.query({_id:id});
      // console.log(rtn);

      return rtn;
    };

    $scope.$on('$destroy', function () {
      socket.unsyncUpdates('payment');
    });

  });
