const net = require('net');

const PORT = 2000;
const HOST = '127.0.0.1';

let clientIdCounter = 0;

const server = net.createServer((socket) => {
    const clientId = ++clientIdCounter;
    let sum = 0;

    console.log(`\nКлиент #${clientId} подключился`);
    console.log(`IP: ${socket.remoteAddress}, PORT: ${socket.remotePort}`);

    const timer = setInterval(() => {
        const buffer = Buffer.alloc(4);

        buffer.writeInt32BE(sum);
        socket.write(buffer);

        console.log(`Сервер -> Клиент #${clientId}: отправлена сумма = ${sum}`);
    }, 5000);

    socket.on('data', (data) => {
        const value = data.readInt32BE(0);
        sum += value;

        console.log(
            `Сервер <- Клиент #${clientId}: получено ${value}, текущая сумма = ${sum}`
        );
    });

    socket.on('close', () => {
        clearInterval(timer);
        console.log(`Клиент #${clientId} отключился`);
    });

    socket.on('error', (err) => {
        console.error(`Ошибка клиента #${clientId}: ${err.message}`);
    });
});

server.listen(PORT, HOST, () => {
    console.log(`TCP-сервер запущен на ${HOST}:${PORT}`);
});
