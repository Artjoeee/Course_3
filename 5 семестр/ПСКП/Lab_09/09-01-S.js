const http = require('http');

const server = http.createServer((req, res) => {
    if (req.method === 'GET') {
        const responseData = {
            message: "Hello"
        };

        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(responseData));
    } 
    else {
        res.writeHead(405, { 'Content-Type': 'text/plain' });
        res.end('Method Not Allowed');
    }
});

server.listen(5000, () => {
    console.log('http://localhost:5000/');
});
