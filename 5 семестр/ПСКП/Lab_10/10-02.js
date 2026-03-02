const WebSocket = require('ws');

const wsUrl = 'ws://localhost:4000';
const ws = new WebSocket(wsUrl);

let clientN = 0;
let sendInterval = null;

ws.on('open', () => {
    console.log('Соединение установлено');

    sendInterval = setInterval(() => {
        clientN++;

        const msg = `10-01-client: ${clientN}`;

        if (ws.readyState === WebSocket.OPEN) {
            ws.send(msg);
            console.log('Отправлено:', msg);
        }
    }, 3000);

    setTimeout(() => {
        if (sendInterval) {
            clearInterval(sendInterval);
            sendInterval = null;
            
            console.log('Закрытие сервера после 25 секунд');
        }

        if (ws.readyState === WebSocket.OPEN) {
            ws.close();
        }
    }, 25000);
});

ws.on('message', (data) => {
    console.log('Получено:', data.toString());
});

ws.on('close', () => {
    console.log('Соединение прервано');

    if (sendInterval) {
        clearInterval(sendInterval);
    }
});

ws.on('error', (err) => {
    console.error('Ошибка:', err);
});
