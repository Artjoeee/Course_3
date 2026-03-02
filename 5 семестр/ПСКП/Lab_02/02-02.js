const http = require('http');
const fs = require('fs');

http.createServer(function(request, response) {
    const fname = './NewTux.png';
    let png = null;
    
    fs.stat(fname, (err, stat) => {
        if (err) {
            console.log('error: ', err);
        }
        else if (request.url === '/png') {
            png = fs.readFileSync(fname);
            response.writeHead(200, {'Content-Type' : 'image/png', 'Content-Length' : stat.size});
            response.end(png, 'binary');
        }
        else {
            response.writeHead(404, {'Content-Type' : 'text/html; charset=utf-8'});
            response.end('Страница не найдена');
        }
    })
}).listen(5000);

console.log('Server running at http://localhost:5000/');