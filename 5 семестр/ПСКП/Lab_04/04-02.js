const http = require('http');
const url = require('url');
const fs = require('fs');
const data = require('./database');

let db = new data.DB();

db.on('GET', async (req, res) => {
    console.log('DB.GET');

    let rows = await db.select();
    res.writeHead(200, {'content-type': 'application/json; charset=utf-8'});
    res.end(JSON.stringify(rows));
});

db.on('POST', async (req, res) => {
    console.log('DB.POST');

    req.on('data', async (data) => {
        let row = JSON.parse(data);

        await db.insert(row);
        res.writeHead(200, {'content-type': 'application/json; charset=utf-8'});
        res.end(JSON.stringify(row));
    });
});

db.on('PUT', async (req, res, id) => {
    console.log('DB.PUT');

    req.on('data', async (data) => {
        let newData = JSON.parse(data);
        let updeted = await db.update(id, newData);
        res.writeHead(200, {'content-type': 'application/json; charset=utf-8'});
        res.end(JSON.stringify(updeted));
    });
});

db.on('DELETE', async (req, res, id) => {
    console.log('DB.DELETE');

    let deleted = await db.delete(id);
    res.writeHead(200, {'content-type': 'application/json; charset=utf-8'});
    res.end(JSON.stringify(deleted));
});

http.createServer(async function (request, response) {
    if (url.parse(request.url).pathname === '/') {
        let html = fs.readFileSync('./04-02.html');
        response.writeHead(200, {'content-type': 'text/html; charset=utf-8'});
        response.end(html);
    }
    else if (url.parse(request.url).pathname === '/style.css') {
        let css = fs.readFileSync('./style.css');
        response.writeHead(200, {'content-type': 'text/css; charset=utf-8'});
        response.end(css);
    }
    else if (url.parse(request.url).pathname === '/api/db') {
        if (typeof url.parse(request.url, true).query.id != undefined) {
            let id = parseInt(url.parse(request.url, true).query.id);
    
            if (Number.isInteger(id)) {
                await db.emit(request.method, request, response, id);
            }
            else {
                await db.emit(request.method, request, response);
            }
        }
    }

}).listen(5000);

console.log('http://localhost:5000/');