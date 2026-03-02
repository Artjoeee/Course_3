const net = require('net');

if (process.argv.length < 3) {
    console.log('Использование: node client13-06.js <X>');
    process.exit(1);
}

const X = parseInt(process.argv[2], 10);
if (isNaN(X)) {
    console.log('X должно быть числом');
    process.exit(1);
}

const PORT = 2000;
const HOST = '127.0.0.1';

const client = new net.Socket();

let intervalId;

client.connect(PORT, HOST, () => {
    console.log(`Подключено к серверу`);

    intervalId = setInterval(() => {
        const buffer = Buffer.alloc(4);
        buffer.writeInt32BE(X);
        client.write(buffer);
        console.log(`Клиент X=${X} -> отправлено число ${X}`);
    }, 1000);
});

client.on('data', (data) => {
    const sum = data.readInt32BE(0);
    console.log(`Клиент X=${X} <- промежуточная сумма = ${sum}`);
});

client.on('close', () => {
    console.log(`Соединение закрыто`);
    clearInterval(intervalId);
    process.exit(0);
});

client.on('error', (err) => {
    console.error(`Ошибка: ${err.message}`);
    clearInterval(intervalId);
    process.exit(1);
});
