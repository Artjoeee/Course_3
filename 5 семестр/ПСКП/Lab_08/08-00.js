const http = require('http');
const url = require('url');
const fs = require('fs');
const querystring = require('querystring');
const path = require('path');
const formidable = require('formidable');
const xml2js = require('xml2js');

const STATIC_DIR = path.join(__dirname, 'static');

const server = http.createServer((req, res) => {
    const parsedUrl = url.parse(req.url);
    const pathname = parsedUrl.pathname;
    const params = querystring.parse(parsedUrl.query);

    const send = (content, status = 200, type = 'text/html') => {
        res.writeHead(status, { 'Content-Type': `${type}; charset=utf-8` });
        res.end(content);
    };

    const sendJSON = (obj, status = 200) => {
        res.writeHead(status, { 'Content-Type': 'application/json; charset=utf-8' });
        res.end(JSON.stringify(obj, null, 2));
    };

    const sendFile = (filePath, contentType = 'text/html') => {
        fs.readFile(filePath, (err, data) => {
            if (err) {
                return send('Ошибка загрузки файла', 500);
            }

            res.writeHead(200, { 'Content-Type': `${contentType}; charset=utf-8` });
            res.end(data);
        });
    };

    if (pathname === '/connection' && req.method === 'GET') {
        if (params.set) {
            const val = Number(params.set);

            if (isNaN(val)) {
                return send('Некорректное значение параметра set', 400);
            }
            
            server.keepAliveTimeout = val;
            send(`Установлен keepAliveTimeout = ${val}`);
        } 
        else {
            send(`Текущее значение keepAliveTimeout = ${server.keepAliveTimeout}`);
        }

        return;
    }

    if (pathname === '/headers' && req.method === 'GET') {
        res.setHeader('X-Student-Response', '08-00');

        let result = '=== REQUEST HEADERS ===\n';

        for (let h in req.headers) {
            result += `${h}: ${req.headers[h]}\n`;
        }

        result += '\n=== RESPONSE HEADERS ===\n';

        for (let h in res.getHeaders()) {
            result += `${h}: ${res.getHeader(h)}\n`;
        }

        send(result);

        return;
    }

    if (pathname === '/parameter' && req.method === 'GET') {
        const x = Number(params.x);
        const y = Number(params.y);

        if (!isNaN(x) && !isNaN(y)) {
            send(`x=${x}, y=${y}\nСумма=${x + y}\nРазность=${x - y}\nПроизведение=${x * y}\nЧастное=${x / y}`);
        } 
        else {
            send('Некорректные параметры x и y', 400);
        }

        return;
    }

    if (pathname.startsWith('/parameter/') && req.method === 'GET') {
        const parts = pathname.split('/');

        if (parts.length === 4) {
            const x = Number(parts[2]);
            const y = Number(parts[3]);

            if (!isNaN(x) && !isNaN(y)) {
                send(`x=${x}, y=${y}\nСумма=${x + y}\nРазность=${x - y}\nПроизведение=${x * y}\nЧастное=${x / y}`);
            } 
            else {
                send(`URI: ${req.url}`);
            }
        } else {
            send('Некорректный путь', 400);
        }

        return;
    }

    if (pathname === '/close' && req.method === 'GET') {
        send('Сервер завершит работу через 10 секунд...');

        setTimeout(() => {
            console.log('Сервер остановлен по запросу /close');
            process.exit(0);
        }, 10000);

        return;
    }

    if (pathname === '/socket' && req.method === 'GET') {
        const info = `Client: ${req.socket.remoteAddress}:${req.socket.remotePort}\n
                        Server: ${req.socket.localAddress}:${req.socket.localPort}`;

        send(info);

        return;
    }

    if (pathname === '/req-data' && req.method === 'POST') {
        let bytes = 0;
        let chunks = 0;

        req.on('data', chunk => {
            bytes += chunk.length;
            chunks++;
            console.log(`Получен чанк ${chunks}, размер: ${chunk.length} байт`);
        });

        req.on('end', () => {
            send(`Принято байт: ${bytes}, количество чанков: ${chunks}`);
        });

        return;
    }

    if (pathname === '/resp-status' && req.method === 'GET') {
        const code = Number(params.code) || 200;
        const mess = params.mess || 'OK';

        res.writeHead(code, mess, { 'Content-Type': 'text/html; charset=utf-8' });
        res.end(`Код: ${code}, Сообщение: ${mess}`);

        return;
    }

    if (pathname === '/formparameter' && req.method === 'GET') {
        return sendFile(path.join(STATIC_DIR, 'form.html'));
    }
    else if (pathname === '/formparameter' && req.method === 'POST') {
        const form = new formidable.IncomingForm({ keepExtensions: true });

        form.parse(req, (err, fields, files) => {
            if (err) {
                return send('Ошибка формы', 500);
            }

            const result = { fields, files };

            sendJSON(result);
        });

        return;
    }

    if (pathname === '/json' && req.method === 'POST') {
        const jsonFile = path.join(STATIC_DIR, '08-10.json');

        fs.readFile(jsonFile, 'utf-8', (err, data) => {
            if (err) {
                return send('Файл не найден', 404);
            }

            try {
                const json = JSON.parse(data);

                const result = {
                    "__comment": "Ответ",
                    "x_plus_y": json.x + json.y,
                    "Concatination_s_o": `${json.s}: ${json.o.surname}, ${json.o.name}`,
                    "Length_m": json.m.length
                };

                sendJSON(result);
            } 
            catch {
                send('Некорректный JSON в файле input.json', 400);
            }
        });

        return;
    }

    if (pathname === '/xml' && req.method === 'POST') {
        const xmlFile = path.join(STATIC_DIR, '08-11.xml');

        fs.readFile(xmlFile, 'utf-8', (err, xmlData) => {
            if (err) {
                return send('Файл не найден', 404);
            }

            xml2js.parseString(xmlData, (err, result) => {
                if (err) {
                    return send('Ошибка парсинга XML', 400);
                }

                try {
                    const xVals = result.request.x.map(x => Number(x.$.value));
                    const mVals = result.request.m.map(m => m.$.value);

                    const sum = xVals.reduce((a, b) => a + b, 0);
                    const concat = mVals.join('');

                    const xmlResp = `<response id="08-00">
                                        <sum element="x" result="${sum}"/>
                                        <concat element="m" result="${concat}"/>
                                    </response>`;

                    send(xmlResp, 200, 'application/xml');
                } 
                catch {
                    send('Некорректная структура XML в файле', 400);
                }
            });
        });

        return;
    }

    if (pathname === '/files' && req.method === 'GET') {
        fs.readdir(STATIC_DIR, (err, files) => {
            if (err) {
                return send('Ошибка чтения каталога', 500);
            }

            res.setHeader('X-static-files-count', files.length);

            sendJSON(files);
        });

        return;
    }

    if (pathname.startsWith('/files/') && req.method === 'GET') {
        const filename = pathname.replace('/files/', '');
        const filePath = path.join(STATIC_DIR, filename);

        fs.access(filePath, fs.constants.F_OK, err => {
            if (err) {
                return send('Файл не найден', 404);
            }

            sendFile(filePath, 'application/octet-stream');
        });

        return;
    }

    if (pathname === '/upload' && req.method === 'GET') {
        return sendFile(path.join(STATIC_DIR, 'upload.html'));
    }
    else if (pathname === '/upload' && req.method === 'POST') {
        const form = new formidable.IncomingForm({
            uploadDir: STATIC_DIR,
            keepExtensions: true
        });

        form.parse(req, (err, fields, files) => {
            if (err) {
                return send('Ошибка загрузки файла', 500);
            }

            const file = files.file?.[0] || files.file;

            const oldPath = file.filepath || file.path;
            const newPath = path.join(STATIC_DIR, file.originalFilename || file.name);

            fs.rename(oldPath, newPath, (renameErr) => {
                if (renameErr) {
                    return send('Ошибка при сохранении файла', 500);
                }

                send(`Файл "${file.originalFilename || file.name}" успешно загружен в папку static`);
            });
        });

        return;
    }

    send('Not Found', 404);
});

server.keepAliveTimeout = 5000;
server.listen(5000, () => console.log('http://localhost:5000'));

server.on('connection', (socket) => {
    console.log(`Новое соединение: ${socket.remoteAddress}:${socket.remotePort}`);
    socket.on('close', () => console.log('Соединение закрыто'));
});
