
require './coverage'

expect = require 'expect.js'

ConfigLoader = require '../lib/config'
configDir = __dirname + '/fixtures/multiple-dirs'

[config] = []

describe 'Multiple Directories', ->
  it 'should load dirs in order', (done) ->
    config = new ConfigLoader()
    config.addDir configDir + '/config1'
    config.addDir configDir + '/config2'
    config.start (err) ->
      if err
        expect().fail(err)
        return done()
      expect(config).to.have.key('val')
      expect(config.val).to.eql('development-config2')
      done()

  it 'should load dirs in order (reverse)', (done) ->
    config = new ConfigLoader()
    config.addDir configDir + '/config2'
    config.addDir configDir + '/config1'
    config.start (err) ->
      if err
        expect().fail(err)
        return done()
      expect(config).to.have.key('val')
      expect(config.val).to.eql('development-config1')
      done()

  it 'should load dirs in order and respect env', (done) ->
    config = new ConfigLoader()
    config.setEnv 'production'
    config.addDir configDir + '/config2'
    config.addDir configDir + '/config1'
    config.start (err) ->
      if err
        expect().fail(err)
        return done()
      expect(config).to.have.key('val')
      expect(config.val).to.eql('production-config1')
      done()

  it 'should load dirs in order and respect env', (done) ->
    config = new ConfigLoader()
    config.setEnv 'production'
    config.addDir configDir + '/config2'
    config.addDir configDir + '/config3'
    config.addDir configDir + '/config1'
    config.start (err) ->
      if err
        expect().fail(err)
        return done()
      expect(config).to.have.key('val')
      expect(config.val).to.eql('production-config1')
      done()
