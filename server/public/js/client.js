 var socket = io.connect('http://localhost');
  socket.on('news', function (data) {
    console.log(data);
    socket.emit('my other event', { my: 'data' });
  });

window.addEventListener('message', function(ev) {
    var message = JSON.parse(ev.data);

    if (message.sender != 'js') {
        console.log(ev.data);
        window.postMessage(JSON.stringify({ name: 'some', args: ['message from js'], sender: 'js'}), '*');
    }
});

var DartBridge = function() {
    var _callbacks = {},
        processMessage = function(ev) {
            var packet;

            try {
                packet = JSON.parse(ev.data);
                if (packet.sender && packet.sender !== 'js') {
                    if (name in _callbacks) {
                        var ar = _callbacks[name];

                        for(var i = 0; i < ar.length; ++i) {
                            ar[i].apply(null, packet.args);
                        }
                    }
                }
            } catch(e) {}
        };

    window.addEventListener('message', processMessage);

    return {
        rpcCall: function(name, args) {
            var packet = {
                name: name,
                args: args,
                sender: 'js'
            };

            window.postMessage(JSON.stringify(packet), '*');
        },

        addListener: function(name, callback) {
            if (!(name in _callbacks)) { _callbacks[name] = []; }

            _callbacks[name].push(callback);
        }
    }
}();

DartBridge.addListener('init', function(arg1, arg2) {
    console.log('init message', arguments);
});

DartBridge.rpcCall('packet', [1, 'ddg']);
