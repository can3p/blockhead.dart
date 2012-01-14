
/**
 * Module dependencies.
 */
var express = require('express'),
    mongoose = require('mongoose'),
    registry = require('./lib/registry.js');

var app = module.exports = express.createServer();
//   , db = mongoose.createConnection('mongodb://localhost/jsnotes');

// registry.set('db', db);

app.helpers(require('./views/helpers/static'));
app.dynamicHelpers(require('./views/helpers/dynamic'));

var IndexController = require('./controllers/index.js');

// Configuration

app.configure(function(){
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(express.compiler({ src: __dirname + '/public', enable: ['sass'] }));
  app.use(app.router);
  app.use(express.static(__dirname + '/public'));
  app.set('port', 3000);
});

app.configure('development', function(){
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true })); 
});

app.configure('production', function(){
  app.use(express.errorHandler()); 
});

// kjcbds
// Routes
app.get('/', IndexController.index);

app.listen(app.settings.port, '127.0.0.1');
// console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);
