should = require 'should'
assert = require 'assert'

require "./commonSpec"
require './init_logger'
require "./calc_changes"

describe "diff utils", ->
  describe "basics", ->

    # beforeEach (done) ->
    #   wow = new wf.WoW ->
    #     done()

    it "do a diff", (done) ->
      obj1 = 
        name: "foo"
      obj2 = 
        name: "bar"
      diff = wf.calc_changes obj1, obj2
      diff.overview.should.equal "UPDATE"
      diff.changes.should.eql name: ["foo","bar"]
      done()

    it "do a patch", (done) ->
      obj1 = 
        name: "foo"
      obj2 = 
        name: "bar"
      diff = wf.calc_changes obj1, obj2
      obj3 = wf.restore diff, obj2
      obj3.should.eql obj1
      obj3.should.not.eql obj2
      done()

    it "no old obj, ie new", (done) ->
      obj1 = 
        name: "foo"
      diff = wf.calc_changes null, obj1
      diff.overview.should.equal "NEW"
      should.not.exist diff.changes
      done()

    it "no old obj, ie new", (done) ->
      obj1 =
        name: "foo"
      diff = wf.calc_changes undefined, obj1
      diff.overview.should.equal "NEW"
      should.not.exist diff.changes
      done()

    it "no old obj, ie new", (done) ->
      obj1 =
        name: "foo"
      diff = wf.calc_changes {}, obj1
      diff.overview.should.equal "UPDATE"
      should.exist diff.changes
      done()

    it "diff no change", (done) ->
      obj1 = 
        name: "foo"
      diff = wf.calc_changes obj1, obj1
      should.exist diff
      should.not.exist diff.changes
      done()
