/**
 * Broadcast updates to client when the model changes
 */

'use strict';

var payment = require('./payment.model');

exports.register = function(socket) {
  payment.schema.post('save', function (doc) {
    onSave(socket, doc);
  });
  payment.schema.post('remove', function (doc) {
    onRemove(socket, doc);
  });
}

function onSave(socket, doc, cb) {
  socket.emit('payment:save', doc);
}

function onRemove(socket, doc, cb) {
  socket.emit('payment:remove', doc);
}