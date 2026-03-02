const net = require('net');

if (process.argv.length < 3) {
    console.log('Использование: node client13-08.js <PORT>');
    process.exit(1);
}

const PORT = parseInt(process.argv[2], 10);

if (isNaN(PORT)) {
    console.log('PORT должен быть числом');
    process.exit(1);
}

const HOST = '127.0.0.1';

const client = new net.Socket();
let X = 1;

let sendTimer;

client.connect(PORT, HOST, () => {
    console.log(`Подключено к серверу`);

    sendTimer = setInterval(() => {
        const buffer = Buffer.alloc(4);

        buffer.writeInt32BE(X);
        client.write(buffer);

        console.log(`Клиент:${PORT} -> отправлено число ${X}`);
        X++;
    }, 1000);
});

client.on('data', (data) => {
    console.log(`Клиент:${PORT} <- ${data.toString()}`);
});

client.on('close', () => {
    console.log(`Соединение закрыто`);
    clearInterval(sendTimer);
    process.exit(0);
});

client.on('error', (err) => {
    console.error(`Ошибка: ${err.message}`);
    clearInterval(sendTimer);
    process.exit(1);
});
