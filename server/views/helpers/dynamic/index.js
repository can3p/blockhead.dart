exports.title = function(req, res) {
    var stack =  []
      , delim = ' / ';

    return function(str, where) {
        if(arguments.length > 0) {
            where = where || 'append'; 
            if( where === 'append' ) {
                stack.push(str);
            } else if(where === 'prepend') {
                stack.unshift(str);
            }
        } else {
            return stack.join(delim);
        }
    }
};

exports.script = function(req, res) {
    var scripts = req._scripts = [];

    return function(src, where) {
        where = where || 'append'; 
        if( where === 'append' ) {
            scripts.push(src);
        } else if(where === 'prepend') {
            scripts.unshift(src);
        }
    };
};

exports.scripts = function(req, res) {
    return req._scripts;
};

exports.style = function(req, res) {
    var styles = req._styles = [];

    return function(src, where) {
        where = where || 'append'; 
        if( where === 'append' ) {
            styles.push(src);
        } else if(where === 'prepend') {
            styles.unshift(src);
        }
    };
};

exports.styles = function(req, res) {
    return req._styles;
};
