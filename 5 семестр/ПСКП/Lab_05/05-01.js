const http = require('http');
const url = require('url');
const fs = require('fs');
const data = require('./database');

let db = new data.DB();

let stats = {
    active: false,
    start: null,
    end: null,
    requests: 0,
    commits: 0
};

let lastStats = null;

db.on('GET', async (req, res) => {
    console.log('GET');

    if (stats.active) {
        stats.requests++;
    }

    let rows = await db.select();

    res.writeHead(200, {'content-type': 'application/json; charset=utf-8'});
    res.end(JSON.stringify(rows));
});

db.on('POST', async (req, res) => {
    console.log('POST');

    if (stats.active) {
        stats.requests++;
    }

    req.on('data', async (data) => {
        let row = JSON.parse(data);

        await db.insert(row);

        res.writeHead(200, {'content-type': 'application/json; charset=utf-8'});
        res.end(JSON.stringify(row));
    });
});

db.on('PUT', async (req, res, id) => {
    console.log('PUT');

    if (stats.active) {
        stats.requests++;
    }

    req.on('data', async (data) => {
        let newData = JSON.parse(data);
        let updeted = await db.update(id, newData);

        res.writeHead(200, {'content-type': 'application/json; charset=utf-8'});
        res.end(JSON.stringify(updeted));
    });
});

db.on('DELETE', async (req, res, id) => {
    console.log('DELETE');

    if (stats.active) {
        stats.requests++;
    }

    let deleted = await db.delete(id);

    res.writeHead(200, {'content-type': 'application/json; charset=utf-8'});
    res.end(JSON.stringify(deleted));
});

db.on('COMMIT', async (req, res) => {
    console.log('COMMIT');

    if (stats.active) {
        stats.commits++;
    }
});

http.createServer(async function (request, response) {
    if (url.parse(request.url).pathname === '/') {
        let html = fs.readFileSync('./05-01.html');
        response.writeHead(200, {'content-type': 'text/html; charset=utf-8'});
        response.end(html);
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
    else if (url.parse(request.url).pathname === '/api/ss') {
        let responseData;

        if (stats.active) {
            responseData = {
                active: stats.active,
                start: stats.start,
                end: null,
                requests: stats.requests,
                commits: stats.commits
            };
        }
        else if (lastStats) {
            responseData = lastStats;
        }
        else {
            responseData = {
                active: false,
                start: null,
                end: null,
                requests: 0,
                commits: 0
            };
        }

        response.writeHead(200, {'content-type': 'application/json; charset=utf-8'});
        response.end(JSON.stringify(responseData));
    }

}).listen(5000);

console.log('http://localhost:5000/');

process.stdin.setEncoding('utf-8');

let sd = null;
let sc = null;
let ss = null;

process.stdin.on('data', async (input) => {
    let [command, time] = input.trim().split(' ');

    if (command == 'sd') {
        if (sd && time !== undefined) {
            clearTimeout(sd);
            sd = null;
        }

        if (time !== undefined && !sd) {
            console.log(`Остановка через ${time} секунд`);
            
            sd = setTimeout(() => {
                console.log('Сервер остановлен');
                process.exit(0);
            }, parseInt(time) * 1000);
        }
        else if (sd) {
            console.log('Отмена остановки');

            clearTimeout(sd);
            sd = null;
        }
    }
    else if (command == 'sc') {
        if (sc && time !== undefined) {
            clearInterval(sc);
            sc = null;
        }

        if (time !== undefined && !sc) {
            console.log(`Автофиксация каждые ${time} секунд`);

            sc = setInterval(() => {
                db.commit();
            }, parseInt(time) * 1000);

            sc.unref();
        }
        else if (sc) {
            console.log('Отмена автофиксации');

            clearInterval(sc);
            sc = null;
        }   
    }
    else if (command.trim() == 'ss') {
        if (ss && time !== undefined) {
            clearTimeout(ss);
            ss = null;
        }

        if (time !== undefined && !ss) {
            stats.active = true;
            stats.start = new Date().toLocaleString();
            stats.end = null;
            stats.requests = 0;
            stats.commits = 0;

            ss = setTimeout(() => {
                stats.active = false;
                stats.end = new Date().toLocaleString();
                lastStats = {...stats};
                console.log("Сбор статистики завершен");
            }, parseInt(time) * 1000);

            ss.unref();
            console.log("Сбор статистики запущен");
        }
        else if (ss){
            stats.active = false;
            stats.end = new Date().toLocaleString();
            lastStats = {...stats};
            console.log('Сбор статистики остановлен');
        } 
    }
    else {
        process.stdout.write('Команда не существует\n');
    }
});