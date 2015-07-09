'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

var PaymentSchema = new Schema({
  amount: {type: Number, min: 0},
  paidUserId: String,
  paidUser: {},
  participantsIds: [String],
  participants: [{}],
  groupId: String,
  group: {},
  date: Date,
  event: String,
  description: String,
  createdAt: Date,
  updatedAt: Date,
  deletedAt: Date,
  isDelete: {type: Boolean, default: false}
});

/**
 * Virtuals
 */
PaymentSchema
  .virtual('personalAmount')
  .get(function() {
    return 100;
    // return this.amount/this.participants.length;
  });

module.exports = mongoose.model('Payment', PaymentSchema);