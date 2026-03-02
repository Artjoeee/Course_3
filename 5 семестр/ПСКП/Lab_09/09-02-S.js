const http = require('http');
const url = require('url');
const querystring = require('querystring');

const server = http.createServer((req, res) => {
    let parsedURL = url.parse(req.url);
    let pathName = parsedURL.pathname;
    let params = querystring.parse(parsedURL.query);

    let sum = Number(params.x) + Number(params.y);

    if (req.method === 'GET' && pathName === '/path') {
        const responseData = {
            sum: sum
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
