const net = require('net');
const readline = require('readline');

const PORT = 2000;
const HOST = '127.0.0.1';

const client = new net.Socket();

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

client.connect(PORT, HOST, () => {
    console.log('Подключено к серверу');

    rl.question('Введите сообщение: ', (message) => {
        client.write(message);
    });
});

client.on('data', (data) => {
    console.log(`${data.toString()}`);
    client.end();
});

client.on('close', () => {
    console.log('Соединение закрыто');
    rl.close();
    process.exit(0);
});

client.on('error', (err) => {
    console.error('Ошибка:', err.message);
    process.exit(1);
});
