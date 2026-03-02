const http = require('http');

let xml = `<request id = "28">
                <x value = "1"/>
                <x value = "2"/>
                <m value = "a"/>
                <m value = "b"/>
                <m value = "c"/>
            </request>`;

const options = {
    hostname: 'localhost',
    port: 5000,
    path: '/',
    method: 'POST',
    headers: {
        'content-type': 'application/xml', 'accept': 'application/xml'
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

req.end(xml);
