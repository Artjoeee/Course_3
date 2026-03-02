const http = require('http');
const fs = require('fs');
const path = require('path');
const WebSocket = require('ws');

const httpPort = 3000;

const server = http.createServer((req, res) => {
    if (req.method === 'GET' && req.url === '/start') {
        const filePath = path.join(__dirname, '10-01.html');

        fs.readFile(filePath, (err, data) => {
            if (err) {
                res.writeHead(500, { 'Content-Type': 'text/plain; charset=utf-8' });
                res.end('Server error');

                return;
            }

            res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
            res.end(data);
        });
    } 
    else {
        res.writeHead(400, { 'Content-Type': 'text/plain; charset=utf-8' });
        res.end('Bad Request');
    }
});

server.listen(httpPort, () => {
    console.log(`http://localhost:${httpPort}`);
});

const wsPort = 4000;

const wss = new WebSocket.Server({ port: wsPort }, () => {
    console.log(`ws://localhost:${wsPort}`);
});

wss.on('connection', (ws, req) => {
    console.log('Клиент подключился:', req.socket.remoteAddress + ':' + req.socket.remotePort);

    let lastClientN = 0;
    let serverK = 0;

    const sendInterval = setInterval(() => {
        serverK++;

        const msg = `10-01-server: ${lastClientN}->${serverK}`;

        if (ws.readyState === WebSocket.OPEN) {
            ws.send(msg);
            console.log('Отправлено клиенту:', msg);
        }
    }, 5000);

    ws.on('message', (message) => {
        const text = message.toString();
        console.log('Получено от клиента:', text);

        const m = text.match(/10-01-client:\s*(\d+)/);

        if (m) {
            lastClientN = parseInt(m[1], 10);
        }  
    });

    ws.on('close', () => {
        clearInterval(sendInterval);
        console.log('Соединение прервано');
    });

    ws.on('error', (err) => {
        console.error('Ошибка:', err);
    });
});
