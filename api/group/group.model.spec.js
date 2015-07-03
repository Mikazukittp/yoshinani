'use strict';

var should = require('should');
var app = require('../../app');
var group = require('./group.model');

var group = new group({
  provider: 'local',
  name: 'Fake group',
  email: 'test@test.com',
  password: 'password'
});

describe('group Model', function() {
  before(function(done) {
    // Clear groups before testing
    group.remove().exec().then(function() {
      done();
    });
  });

  afterEach(function(done) {
    group.remove().exec().then(function() {
      done();
    });
  });

  it('should begin with no groups', function(done) {
    group.find({}, function(err, groups) {
      groups.should.have.length(0);
      done();
    });
  });

  it('should fail when saving a duplicate group', function(done) {
    group.save(function() {
      var groupDup = new group(group);
      groupDup.save(function(err) {
        should.exist(err);
        done();
      });
    });
  });

  it('should fail when saving without an email', function(done) {
    group.email = '';
    group.save(function(err) {
      should.exist(err);
      done();
    });
  });

  it("should authenticate group if password is valid", function() {
    return group.authenticate('password').should.be.true;
  });

  it("should not authenticate group if password is invalid", function() {
    return group.authenticate('blah').should.not.be.true;
  });
});
