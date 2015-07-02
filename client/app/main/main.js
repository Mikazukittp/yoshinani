'use strict';

angular.module('seisanApp')
.config(function ($stateProvider) {
    $stateProvider
    .state('main', {
        url: '/',
        templateUrl: 'app/main/main.html',
        controller: 'MainCtrl',
        authenticate: true
    });
});