const net = require('net');

const PORTS = [40000, 50000];
const HOST = '127.0.0.1';

function startServer(port) {
    const server = net.createServer((socket) => {
        console.log(
            `[Сервер:${port}] Клиент подключился ` +
            `${socket.remoteAddress}:${socket.remotePort}`
        );

        socket.on('data', (data) => {
            const value = data.readInt32BE(0);

            console.log(
                `[Сервер:${port}] Получено число: ${value}`
            );

            const response = Buffer.from(`ECHO:${value}`);
            socket.write(response);
        });

        socket.on('close', () => {
            console.log(`[Сервер:${port}] Клиент отключился`);
        });

        socket.on('error', (err) => {
            console.error(`[Сервер:${port}] Ошибка: ${err.message}`);
        });
    });

    server.listen(port, HOST, () => {
        console.log(`TCP-сервер запущен на ${HOST}:${port}`);
    });
}

PORTS.forEach(startServer);
