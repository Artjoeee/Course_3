const dgram = require('dgram');
const readline = require('readline');

const PORT = 2000;
const HOST = '127.0.0.1';

const client = dgram.createSocket('udp4');

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

rl.question('Введите количество сообщений: ', (countStr) => {
    const count = parseInt(countStr, 10);

    if (isNaN(count) || count <= 0) {
        console.log('Количество сообщений должно быть положительным числом');
        rl.close();
        client.close();
        return;
    }

    let sent = 0;

    const interval = setInterval(() => {
        if (sent >= count) {
            clearInterval(interval);
            rl.close();
            client.close();
            return;
        }

        const message = `Hello from ClientU${sent + 1}`;

        client.send(message, PORT, HOST, (err) => {
            if (err) {
                console.error('Ошибка отправки:', err.message);
            }
            else {
                console.log(`Отправлено: ${message}`);
            }
        });

        sent++;
    }, 1000);
});

client.on('message', (msg, rinfo) => {
    console.log(`${msg.toString()}`);
});
