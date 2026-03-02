const dgram = require('dgram');

const PORT = 2000;

const server = dgram.createSocket('udp4');

server.on('listening', () => {
    const address = server.address();
    console.log(`UDP-сервер запущен на ${address.address}:${address.port}`);
});

server.on('message', (msg, rinfo) => {
    const text = msg.toString().trim();
    console.log(`Получено от ${rinfo.address}:${rinfo.port} -> ${text}`);

    const response = `ECHO: ${text}`;

    server.send(response, rinfo.port, rinfo.address, (err) => {
        if (err) {
            console.error('Ошибка отправки:', err.message);
        }
        else {
            console.log(`Отправлено клиенту ${rinfo.address}:${rinfo.port}`);
        }
    });
});

server.bind(PORT);
