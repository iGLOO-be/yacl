blanket = require('blanket')(
  pattern: 'lib/config.js',
  'travis-cov':
    threshold: 70
)

expect = require 'expect.js'

ConfigLoader = require '../lib/config'
configDir = __dirname + '/fixtures/config'

[config] = []

describe 'Creation', ->
  it 'should create a new configLoader', (done) ->
    config = new ConfigLoader()
    expect(config).to.be.an('object')
    done()

  describe 'Interface', ->
    config = new ConfigLoader()
    it 'should have an addDir function', (done) ->
      expect(config.addDir).to.be.a('function')
      done()
    it 'should have a start function', (done) ->
      expect(config.start).to.be.a('function')
      done()
    it 'should have a setEnv function', (done) ->
      expect(config.setEnv).to.be.a('function')
      done()
    it 'should have a toJSON function', (done) ->
      expect(config.toJSON).to.be.a('function')
      done()

describe 'Add Dir', ->
  before () ->
    config = new ConfigLoader()

  it 'should not have a dir', (done) ->
    expect(config._dirs).to.have.length(0)
    done()

  it 'should add a dir', (done) ->
    config.addDir configDir
    expect(config._dirs).to.have.length(1)
    done()

  it 'should add a dir with prepend true', (done) ->
    config.addDir configDir + '/foo', true
    expect(config._dirs).to.have.length(2)
    expect(config._dirs[0]).to.eql(configDir + '/foo')
    done()

  it 'should have an error when calling addDir', (done) ->
    config.addDir configDir + '/foo'
    config.start (err) ->
      expect(err).to.be.an(Error)
      done()

  it 'should have an error when calling a config that does not exists', (done) ->
    config.addDir __dirname
    config.setEnv 'error'
    config.start (err) ->
      expect(err).to.be.an(Error)
      done()

describe 'Set Env', ->
  beforeEach () ->
    config = new ConfigLoader()
    config.addDir configDir

  it 'should have a default config', (done) ->
    config.start (err) ->
      if err
        expect().fail(err)
        done()
      expect(config.config).to.eql(require(configDir + '/default'))
      done()

  it 'should set a default environment', (done) ->
    config.setEnv 'default'
    config.start (err) ->
      if err
        expect().fail(err)
        done()
      expect(config).to.have.key('val')
      expect(config.val).to.eql('default')
      done()

  it 'should set a development environment', (done) ->
    config.setEnv 'development'
    config.start (err) ->
      if err
        expect().fail(err)
        done()
      expect(config).to.have.key('val')
      expect(config.val).to.eql('development')
      done()

  it 'should set a production environment', (done) ->
    config.setEnv 'production'
    config.start (err) ->
      if err
        expect().fail(err)
        done()
      expect(config).to.have.key('val')
      expect(config.val).to.eql('production')
      done()

  describe 'Get config', ->
    it 'should return a JSON', (done) ->
      config.setEnv 'production'
      config.start (err) ->
        if err
          expect().fail(err)
          done()
        expect(config.toJSON()).to.be.an('object')
        done()

    it 'should return a JSON equals to production.js', (done) ->
      config.setEnv 'production'
      config.start (err) ->
        if err
          expect().fail(err)
          done()
        expect(config.toJSON()).to.eql(require(configDir + '/production'))
        done()

