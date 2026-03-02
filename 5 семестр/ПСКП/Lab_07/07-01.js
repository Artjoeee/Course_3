const http = require('http');
const handler = require('./m07-01')('./static');

let server = http.createServer(handler);

server.listen(5000);

console.log('http://localhost:5000');