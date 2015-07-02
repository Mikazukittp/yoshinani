'use strict';

angular.module('seisanApp')
.config(function ($stateProvider) {
  $stateProvider
  .state('overview', {
    url: '/overview',
    templateUrl: 'app/payment/overview/overview.html',
    controller: 'OverviewCtrl',
    authenticate: true
  })
  .state('log', {
    url: '/log',
    templateUrl: 'app/payment/log/log.html',
    controller: 'LogCtrl',
    authenticate: true
  });
});
