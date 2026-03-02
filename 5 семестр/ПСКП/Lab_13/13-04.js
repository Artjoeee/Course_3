const net = require('net');

const PORT = 2000;
const HOST = '127.0.0.1';

const client = new net.Socket();

let seconds = 0;
let sendTimer;

client.connect(PORT, HOST, () => {
    console.log('Подключено к серверу');

    sendTimer = setInterval(() => {
        const value = Math.floor(Math.random() * 10) + 1;
        const buffer = Buffer.alloc(4);
        
        buffer.writeInt32BE(value);
        client.write(buffer);

        console.log(`Отправлено число: ${value}`);
        seconds++;

        if (seconds === 20) {
            clearInterval(sendTimer);
            console.log('20 секунд прошло. Клиент завершает работу.');
            client.end();
        }
    }, 1000);
});

client.on('data', (data) => {
    const sum = data.readInt32BE();
    console.log(`Промежуточная сумма от сервера: ${sum}`);
});

client.on('close', () => {
    console.log('Соединение закрыто');
    clearInterval(sendTimer);
    process.exit(0);
});

client.on('error', (err) => {
    console.error('Ошибка:', err.message);
    clearInterval(sendTimer);
    process.exit(1);
});
