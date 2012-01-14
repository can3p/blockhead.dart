
var __storage = {};

module.exports = {
    set: function(name, val) {
        __storage[name] = val;
    },
    get: function(name) {
        return __storage[name] || null;
    }
};
