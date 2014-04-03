
fs = require 'fs'
path = require 'path'
async = require 'async'
extend = require 'extend'
_ = require 'lodash'
templator = require 'config-templator'
require 'coffee-script/register'

applyGetter = (target, source) ->
  _.keys(source).forEach (key) ->
    delete target[key]
    Object.defineProperty  target, key,
      get: -> templator.get source, key
      configurable: true
      enumerable : true

requireConfig = (file, cb) ->
  try
    req = require file
    cb(null, req)
  catch error
    cb(error)

class Config
  constructor: (@_supConfig = {}) ->
    @_dirs = []
    @env = 'development'
    @config = {}

  setEnv: (@env) ->

  applyConfig: (data) =>
    extend true, @config, data
    applyGetter @, @config

  addDir: (dir) ->
    @_dirs.push dir
    @

  start: (cb) =>
    @_loadConfig cb
    @

  toJSON: () ->
    templator.flatten @config

  _loadConfig: (cb) ->
    async.map @_dirs, @_readdir, ((err, configs) =>
      return cb?(err) if err

      _configs = []
      for _conf in configs
        for conf, i in _conf
          _configs[i] = _configs[i] || []
          _configs[i].push conf
      _configs.push [ @_supConfig ]

      _.flatten(_configs).forEach @applyConfig

      cb?()
    )

  _readdir: (dir, final) =>
    fs.readdir dir, (err, files) =>
      return final?(err) if err
      async.map files, ((file, cb) =>
        async.map(['default', @env], ((pattern, next) ->
          if file.indexOf(pattern) == 0
            requireConfig(dir + '/' + file, next)
          else
            next()
        ), cb)
      ), final

module.exports = Config
