const WebSocket = require('ws');

const wss = new WebSocket.Server({ port: 4000 }, () => {
    console.log("ws://localhost:4000");
});

wss.on('connection', (ws) => {
    console.log('Соединение установлено');

    ws.on('message', (msg) => {
        console.log('Получено:', msg.toString());

        wss.clients.forEach(client => {
        if (client.readyState === WebSocket.OPEN) {
            client.send("Broadcast: " + msg.toString());
        }
        });
    });

    ws.on('close', () => {
        console.log('Соединение прервано');
    });
});
