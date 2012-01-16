 // var socket = io.connect('http://localhost');
 //  socket.on('news', function (data) {
 //    console.log(data);
 //    socket.emit('my other event', { my: 'data' });
 //  });

window.addEventListener('message', function(ev) {
    var message = JSON.parse(ev.data);

    if (message.sender != 'js') {
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
                    if (packet.name in _callbacks) {
                        var ar = _callbacks[packet.name];

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

        addEventListener: function(name, callback) {
            if (!(name in _callbacks)) { _callbacks[name] = []; }

            _callbacks[name].push(callback);
        }
    }
}();

var SocketIOWrapper = function() {

    var socket,
        events = {},
        rpc = function(name) { return 'socketio:' + name; },
        bindMethod = function(name) {
            return function() {
                wrapper[name].apply(wrapper, arguments);
            };
        };

    var wrapper = {
        connect: function(addr) {
            socket = io.connect(addr);
        },

        on: function(event) {
            if (event in events) { return; }
            if (!socket) { throw 'socket has not been created'; }

            events[event] = true;
            socket.on(event, function(data) {
                wrapper.handleEvent(event, data);
            });
        },

        emit: function(event, data) {
            if (!socket) { throw 'socket has not been created'; }
            socket.emit(event, data);
        },

        handleEvent: function(event, data) {
            if (!socket) { throw 'socket has not been created'; }

            DartBridge.rpcCall(rpc('on'), [ data ]);
        }
    };

    for (var prop in wrapper) if (wrapper.hasOwnProperty(prop)) {
        DartBridge.addEventListener(rpc(prop), bindMethod(prop));
    }
};

new SocketIOWrapper();
