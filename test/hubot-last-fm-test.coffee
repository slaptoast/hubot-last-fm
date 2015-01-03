chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'
expect = chai.expect

pequire = require 'proxyquire'

describe 'hubot-last-fm', ->
  beforeEach ->
    @robot =
      hear: sinon.spy()

    @fs =
      readFile: sinon.spy()
      '@noCallThru': true

    process.env.HUBOT_LAST_FM_API_KEY = 'foo'
    pequire('../src/hubot-last-fm.coffee', {
      fs: @fs
    })(@robot)

  it 'registers five hear listeners', ->
    expect(@robot.hear).to.have.callCount(5)

  it 'attempts to load a seed user file', ->
    expect(@fs.readFile).to.have.been.calledOnce
    expect(@fs.readFile).to.have.been.calledWith('./data/last-fm-users.json')
