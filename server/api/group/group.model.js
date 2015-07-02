'use strict';

var mongoose = require('mongoose');
var Schema = mongoose.Schema;
var crypto = require('crypto');

var GroupSchema = new Schema({
  name: String,
  members: []
});

module.exports = mongoose.model('Group', GroupSchema);