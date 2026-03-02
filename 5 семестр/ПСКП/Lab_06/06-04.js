const http = require('http');
const url = require('url');
const fs = require('fs');
const { parse } = require('querystring');
const { send } = require('m0603-art');
// const { send } = require('C:/Users/artzh/AppData/Roaming/npm/node_modules/m0603-art');

http.createServer((req, res) => {
    res.writeHead(200, {'content-type': 'text/html; charset=utf-8'});

    if (url.parse(req.url).pathname == '/' && req.method == 'GET') {
        res.end(fs.readFileSync('./06-03.html'));
    }
    else if (url.parse(req.url).pathname == '/' && req.method == 'POST') {
        let body = '';
    
        req.on('data', chunk => {body += chunk.toString();});
        req.on('end', () => {
            let parm = parse(body);
    
            send(parm.message);

            res.end('<h1>Сообщение отправлено на почту.</h1>');
        });
    }
    else {
        res.end('<h1>Not support</h1>');
    }

}).listen(5000);

console.log('http://localhost:5000');
