# Copyright (C) 2014 iGLOO / Woobie S.P.R.L. (Loïc Mahieu loic@igloo.be)

# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.

# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION
# OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
# CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

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
  envs: ['default', 'development']

  constructor: (@_supConfig = {}) ->
    @_dirs = []
    @env = @envs[1]
    @config = {}

  setEnv: (@env) ->
    @envs[1] = @env

  applyConfig: (data) =>
    extend true, @config, data
    applyGetter @, @config

  addDir: (dir, prepend) ->
    @_dirs[if prepend then 'unshift' else 'push'] dir
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

  _readdir: (dir, cb) =>
    fs.readdir dir, (err, files) =>
      return cb(err) if err
      async.map files, ((file, cb) =>
        async.map(@envs, ((pattern, cb) ->
          if file.indexOf(pattern) == 0
            requireConfig(dir + '/' + file, cb)
          else
            cb()
        ), cb)
      ), cb

module.exports = Config
