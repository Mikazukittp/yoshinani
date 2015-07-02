'use strict';

angular.module('seisanApp')
.config(function ($stateProvider) {
    $stateProvider
    .state('admin', {
        url: '/admin',
        templateUrl: 'app/admin/admin.html',
        controller: 'AdminCtrl',
        authenticate: true
    });
});