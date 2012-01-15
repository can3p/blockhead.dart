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
