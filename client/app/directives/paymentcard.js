'use strict';

/**
 * @ngdoc directive
 * @name seisanApp.directive:paymentCard
 * @description
 * # paymentCard
 */
 angular.module('seisanApp')
 .directive('paymentCard', function ($modal) {
    return {
        templateUrl: 'app/directives/payment_card.html',
        restrict: 'EA',
        scope: {
            p: '=item'
        },
        require: '^paymentCardList',
        link: function(scope, element, attrs, paymentLitCtr, transclude) {
            scope.isEditaMode = false;
            paymentLitCtr.addPaymentCard(scope);

            // 編集モード
            scope.startEdit = function() {
                if(paymentLitCtr.anyDirty()) {
                    scope.$emit('cannot-edit', '編集中のアイテムがあります', new Date);
                    return;
                }
                paymentLitCtr.allCancell();
                // 仮保存
                scope.backupPayment = angular.copy(scope.payment);
                scope.isEditaMode = true;
            };

            // 保存
            scope.save = function() {
                scope.isEditaMode = false;
                scope.backupPayment = null;
            };

            // キャンセル
            scope.cancel = function() {
                if(!scope.isEditaMode) {
                    return;
                }
                scope.payment = scope.backupPayment;
                scope.backupPayment = null;
                scope.isEditaMode = false;
            };

            // 編集
            scope.edit = function(paymentCard) {
                scope.$emit('edit-payment', paymentCard._id);
            };

            // 削除
            scope.delete = function(paymentCard) {
                var modalInstance = $modal.open({
                    templateUrl: 'deleteModal.html',
                    controller: 'DeleteModalCtrl'
                });
                modalInstance.result.then(function (selectedItem) {
                    scope.$emit('delete-payment', paymentCard._id);
                }, function () {
                });
            };

            // 値が変更されているか
            scope.isDirty = function() {
                if(!scope.isEditaMode) {
                    return false;
                }
                return !angular.equals(scope.payment, scope.backupPayment);
            };
        }
    }
})
.controller('DeleteModalCtrl', function ($scope, $modalInstance) {
            $scope.ok = function () {
                $modalInstance.close('');
            };

            $scope.cancel = function () {
                $modalInstance.dismiss('cancel');
            };
})
.controller('paymentListController', function ($http) {
    this.paymentCards = [];

    this.addPaymentCard = function(paymentCard) {
        this.paymentCards.push(paymentCard);
        var self = this;
        paymentCard.$on('$destroy', function() {
            self.removePaymentCard(paymentCard);
        });
    };

    this.removePaymentCard = function(paymentCard) {
        var index = this.paymentCards.indexOf(paymentCard);
        this.paymentCards.splice(index, 1);
    }

    this.anyDirty = function() {
        var isDirty = false;
        for(var i=0; i<this.paymentCards.length; i++) {
            var paymentCard = this.paymentCards[i];
            if(paymentCard.isDirty()) {
                isDirty = true;
            }
        }
        return isDirty;
    };

    this.allCancell = function() {
        for(var i=0; i<this.paymentCards.length; i++) {
            var paymentCard = this.paymentCards[i];
            if(paymentCard.isEditaMode) {
                paymentCard.cancel();
            }
        }
    };
})
.directive('paymentCardList', function () {
    return {
        template: '<ul class="row nav" ng-transclude></ul>',
        restrict: 'EA',
        replace: true,
        transclude: true,
        controller: 'paymentListController',
        scope: {
            items: '='
        }
    }
});
