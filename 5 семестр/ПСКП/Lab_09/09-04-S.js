const http = require('http');

const server = http.createServer((req, res) => {
    if (req.method === 'POST') {
        let data = '';

        req.on('data', (chunk) => {
            data += chunk;
        });

        req.on('end', () => {
            const json = JSON.parse(data);

            const result = {
                "__comment": "Ответ",
                "x_plus_y": json.x + json.y,
                "Concatination_s_o": `${json.s}: ${json.o.surname}, ${json.o.name}`,
                "Length_m": json.m.length
            };

            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify(result));             
        });

        return;
    }
    else {
        res.writeHead(405, { 'Content-Type': 'text/plain' });
        res.end('Method Not Allowed');
    }
});

server.listen(5000, () => {
    console.log('http://localhost:5000/');
});