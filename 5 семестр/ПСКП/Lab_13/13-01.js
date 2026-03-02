const net = require('net');

const PORT = 2000;
const HOST = '127.0.0.1';

const server = net.createServer((socket) => {
    console.log('Клиент подключился:');
    console.log(`IP: ${socket.remoteAddress}`);
    console.log(`Port: ${socket.remotePort}\n`);

    socket.on('data', (data) => {
        const message = data.toString().trim();
        console.log(`Получено: ${message}`);

        const response = `ECHO: ${message}`;
        socket.write(response);
    });

    socket.on('close', () => {
        console.log('Клиент отключился.\n');
    });

    socket.on('error', (err) => {
        console.error('Ошибка сокета:', err.message);
    });
});

server.listen(PORT, HOST, () => {
    console.log(`TCP-сервер запущен на ${HOST}:${PORT}`);
});
