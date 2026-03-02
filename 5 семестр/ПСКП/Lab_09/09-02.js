const http = require('http');
const query = require('querystring');

let params = query.stringify({x: 3, y: 4});
let path = `/path?${params}`;

const options = {
    hostname: 'localhost',
    port: 5000,
    path: path,
    method: 'GET'
};

const req = http.request(options, (res) => {
    console.log(`Status Code: ${res.statusCode}`);
    console.log(`Status Message: ${res.statusMessage}`);
    console.log(`Remote IP: ${res.socket.remoteAddress}`);
    console.log(`Remote Port: ${res.socket.remotePort}`);

    let data = '';

    res.on('data', (chunk) => {
        data += chunk;
    });

    res.on('end', () => {
        console.log('Response Body:', data);
    });
});

req.on('error', (err) => {
    console.error('Error:', err.message);
});

req.end();
