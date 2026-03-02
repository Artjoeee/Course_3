const http = require('http');

let json = {
    "__comment": "Запрос",
    "x": 1,
    "y": 2,
    "s": "Сообщение",
    "m": ["a", "b", "c", "d"],
    "o": {"surname": "Жамойдо", "name": "Артём"}
};

let jsonData = JSON.stringify(json);

const options = {
    hostname: 'localhost',
    port: 5000,
    path: '/',
    method: 'POST',
    headers: {
        'content-type': 'application/json', 'accept': 'application/json'
    }
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

req.end(jsonData);
