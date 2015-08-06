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

  it 'registers eight hear listeners', ->
    expect(@robot.hear).to.have.callCount(8)

  it 'registers a team-wide listener', ->
    expect(@robot.hear).to.have.been.calledWith(/what'?s playing/i)

  it 'registers a team-wide weekly artist listener', ->
    expect(@robot.hear).to.have.been.calledWith(/what'?s weekly artists/i)

  it 'registers a user-specific artist listener', ->
    expect(@robot.hear).to.have.been.calledWith(/what'?s (.*) (?:weekly artists)/i)

  it 'registers a user-specific listener', ->
    expect(@robot.hear).to.have.been.calledWith(/what'?s (.*) (?:listening|playing)/i)

  it 'registers an asker-specific listener', ->
    expect(@robot.hear).to.have.been.calledWith(/what am I (?:playing|listening)/i)

  it 'registers an add-user listener', ->
    expect(@robot.hear).to.have.been.calledWith(/add last.?fm (.*) (.*)/i)

  it 'registers an update-user listener', ->
    expect(@robot.hear).to.have.been.calledWith(/update last.?fm (.*) (.*)/i)

  it 'registers a roster listener', ->
    expect(@robot.hear).to.have.been.calledWith(/last.?fm roster/i)

  it 'attempts to load a seed user file', ->
    expect(@fs.readFile).to.have.been.calledOnce
    expect(@fs.readFile).to.have.been.calledWith('./data/last-fm-users.json')
