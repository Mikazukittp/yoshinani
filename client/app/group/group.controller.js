'use strict';

angular.module('seisanApp')
.controller('GroupCtrl', function ($scope, $http, Pagination) {
    $scope.usersInGroup = [];
    $scope.overviews = [];

    $http.get('/api/users').success(function(users) {
        $scope.usersInGroup = users;

        angular.forEach(users, function(u, i) {
            $http.get('/api/payments/overview/'+u._id)
            .success(function(overview) {
                $scope.overviews[i] = overview;
                $scope.overviews[i].userName = u.name;
            });
            //paginatorの設定
            $scope.paginator = Pagination.getNew(10);
            $scope.paginator.numPages = Math.ceil($scope.overviews.length / $scope.paginator.perPage);

        });

    });







});

