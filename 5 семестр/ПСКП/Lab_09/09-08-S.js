const http = require('http');
const fs = require('fs');

const server = http.createServer((req, res) => {
    if (req.method === 'GET' && req.url === '/download') {
        const filePath = './MyFile.png';

        if (!fs.existsSync(filePath)) {
            res.writeHead(404, { "Content-Type": "text/plain" });
            return res.end("File not found");
        }

        const stat = fs.statSync(filePath);

        res.writeHead(200, {
            "Content-Type": "application/octet-stream",
            "Content-Disposition": "attachment; filename=MyFile.png",
            "Content-Length": stat.size
        });

        const readStream = fs.createReadStream(filePath);
        readStream.pipe(res);

    } 
    else {
        res.writeHead(404, { "Content-Type": "text/plain" });
        res.end("Not found");
    }
});

server.listen(5000, () => {
    console.log('http://localhost:5000/');
});
