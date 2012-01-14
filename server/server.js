var cluster = require('cluster');

cluster('./app')
  .use(cluster.logger('logs'))
  .use(cluster.stats())
  .use(cluster.pidfiles('pids'))
  .use(cluster.cli())
  .use(cluster.repl(8888))
  .use(cluster.debug())
  .use(cluster.reload())
  .listen(3000, '127.0.0.1');
