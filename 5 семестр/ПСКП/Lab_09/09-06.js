const http = require('http');
const fs = require('fs');
const FormData = require('form-data');

const form = new FormData();

form.append('myfile', fs.createReadStream('./MyFile.txt'));

const options = {
    method: 'POST',
    hostname: 'localhost',
    port: 5000,
    path: '/',
    headers: form.getHeaders()
};

const req = http.request(options, (res) => {
    console.log(`Status Code: ${res.statusCode}`);
    console.log(`Status Message: ${res.statusMessage}`);
    console.log(`Remote IP: ${res.socket.remoteAddress}`);
    console.log(`Remote Port: ${res.socket.remotePort}`);

    let data = "";
    res.on('data', chunk => data += chunk);
    res.on('end', () => {
        console.log("Server response:");
        console.log(data);
    });
});

req.on('error', console.error);

form.pipe(req);
