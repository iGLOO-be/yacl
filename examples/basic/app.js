require('coffee-script');

var ConfigLoader = require('../../lib/config');
var async = require('async');

testEnv = function (env) {
  var config = new ConfigLoader();

  config.addDir( __dirname + '/config');
  config.setEnv(env);

  config.start(function (err) {
    console.log('------------------- ' + env);
    if(err)
      throw new Error(err)
    console.log(config.test);
  });

};

async.parallel({
  def: function (next) {
    testEnv('default');
    next();
  },
  production: function (next) {
    testEnv('production');
    next();
  },
  development: function (next) {
    testEnv('development');
    next();
  }
}, function (err, res) {
});
