'use strict';

angular.module('seisanApp')
  .controller('NavbarCtrl', function ($scope, $location, Auth) {
    $scope.menu = [{
      'title': 'Home',
      'link': '/',
      'auth': 0
    }, {
      'title': 'Overview',
      'link': '/overview',
      'auth': 10
    }, {
      'title': 'Log',
      'link': '/log',
      'auth': 10
    }, {
      'title': 'Group',
      'link': '/group',
      'auth': 10
    }, {
      'title': 'Admin',
      'link': '/admin',
      'auth': 100
    }];

    $scope.isCollapsed = true;
    $scope.isLoggedIn = Auth.isLoggedIn;
    $scope.isAdmin = Auth.isAdmin;
    $scope.getCurrentUser = Auth.getCurrentUser;

    $scope.getAuth = function(auth) {
      if(auth < 10) {
        return true;
      }else if(auth < 100) {
        return Auth.isLoggedIn();
      }else {
        return Auth.isAdmin();
      }
    }

    $scope.logout = function() {
      Auth.logout();
      $location.path('/login');
    };

    $scope.isActive = function(route) {
      return route === $location.path();
    };
  });