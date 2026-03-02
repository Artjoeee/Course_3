const WebSocket = require('ws');
const readline = require('readline');

const ws = new WebSocket('ws://localhost:4000');

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

ws.on('open', () => {
    console.log('Соединение установлено');
    console.log('Введите сообщение:');
});

ws.on('message', (msg) => {
    console.log('Получено:', msg.toString());
});

ws.on('close', () => {
    console.log('Соединение прервано');
    rl.close();
});

ws.on('error', (err) => {
    console.log('Ошибка:', err);
});

rl.on('line', (input) => {
    if (ws.readyState === WebSocket.OPEN) {
        ws.send(input);
        console.log('Отправлено:', input);
    } 
    else {
        console.log('Соединение не открыто');
    }
});
