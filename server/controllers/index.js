
var registry = require('../lib/registry');

module.exports = {
    index: function(req, res, next) {
        res.render('index', {});
    }
}
