const http = require('http');
const fs = require('fs');

const PORT = 40000;
const ROUTE = '/NGINX-test';

const jsonString = fs.readFileSync('json.json');

let storedRequest = JSON.parse(jsonString);

function calculate(op, x, y) {
    switch (op) {
        case 'add': return x + y;
        case 'sub': return x - y;
        case 'mul': return x * y;
        case 'div': return y !== 0 ? x / y : null;
        default: return null;
    }
}

const server = http.createServer((req, res) => {
    if (req.url !== ROUTE) {
        res.writeHead(404);
        return res.end();
    }

    // ---------- GET ----------
    if (req.method === 'GET') {
        if (!storedRequest) {
            res.writeHead(404);
            return res.end();
        }

        const result = calculate(
            storedRequest.op,
            storedRequest.x,
            storedRequest.y
        );

        res.writeHead(200, { 'Content-Type': 'application/json' });

        return res.end(JSON.stringify({
            ...storedRequest,
            result
        }));
    }

    // ---------- POST ----------
    if (req.method === 'POST') {
        if (storedRequest) {
            res.writeHead(409);
            return res.end();
        }

        let body = '';
        req.on('data', chunk => body += chunk);
        req.on('end', () => {
            const data = JSON.parse(body);
            const result = calculate(data.op, data.x, data.y);

            storedRequest = {
                op: data.op,
                x: data.x,
                y: data.y
            };

            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({
                ...storedRequest,
                result
            }));
        });

        return;
    }

    // ---------- PUT ----------
    if (req.method === 'PUT') {
        if (!storedRequest) {
            res.writeHead(404);
            return res.end();
        }

        let body = '';
        req.on('data', chunk => body += chunk);
        req.on('end', () => {
            const data = JSON.parse(body);
            const result = calculate(data.op, data.x, data.y);

            storedRequest = {
                op: data.op,
                x: data.x,
                y: data.y
            };

            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({
                ...storedRequest,
                result
            }));
        });

        return;
    }
    
    // ---------- DELETE ----------
    if (req.method === 'DELETE') {
        if (!storedRequest) {
            res.writeHead(404);
            return res.end();
        }

        storedRequest = null;
        res.writeHead(200);
        return res.end();
    }

    res.writeHead(405);
    res.end();
});

server.listen(PORT, () => {
    console.log(`TDWA01-01 running on port ${PORT}`);
});
