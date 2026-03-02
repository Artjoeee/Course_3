const http = require('http');
const url = require('url');
const querystring = require('querystring');

const server = http.createServer((req, res) => {
    let parsedURL = url.parse(req.url);
    let pathName = parsedURL.pathname;
    let params = querystring.parse(parsedURL.query);

    let concat =  params.x + params.y + params.s;

    if (req.method === 'GET' && pathName === '/path') {
        const responseData = {
            concat: concat
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
