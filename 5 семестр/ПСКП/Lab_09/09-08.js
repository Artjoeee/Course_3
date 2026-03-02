const http = require('http');
const fs = require('fs');

const options = {
    hostname: 'localhost',
    port: 5000,
    path: '/download',
    method: 'GET'
};

const req = http.request(options, (res) => {
    console.log(`Status Code: ${res.statusCode}`);
    console.log(`Status Message: ${res.statusMessage}`);
    console.log(`Remote IP: ${res.socket.remoteAddress}`);
    console.log(`Remote Port: ${res.socket.remotePort}`);

    const writeStream = fs.createWriteStream("Received_MyFile.png");

    res.pipe(writeStream);

    writeStream.on('finish', () => {
        console.log("Файл получен и сохранён как Received_MyFile.png");
    });
});

req.on('error', (err) => {
    console.error("Error:", err.message);
});

req.end();
