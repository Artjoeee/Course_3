const net = require('net');

const PORT = 2000;
const HOST = '127.0.0.1';

const server = net.createServer((socket) => {
    console.log(`Клиент подключился: ${socket.remoteAddress}:${socket.remotePort}`);

    let sum = 0;

    const timer = setInterval(() => {
        const buffer = Buffer.alloc(4);
        
        buffer.writeInt32BE(sum);
        socket.write(buffer);

        console.log(`Отправлена промежуточная сумма клиенту: ${sum}`);
    }, 5000);

    socket.on('data', (data) => {
        for (let i = 0; i + 3 < data.length; i += 4) {
            const value = data.readInt32BE(i);
            sum += value;

            console.log(`Получено число ${value}, текущая сумма = ${sum}`);
        }
    });

    socket.on('close', () => {
        clearInterval(timer);
        console.log('Клиент отключился\n');
    });

    socket.on('error', (err) => {
        console.error('Ошибка:', err.message);
    });
});

server.listen(PORT, HOST, () => {
    console.log(`TCP-сервер запущен на ${HOST}:${PORT}`);
});
