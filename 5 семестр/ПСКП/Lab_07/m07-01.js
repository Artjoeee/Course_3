const fs = require('fs');
const path = require('path');

function Stat(filePath) {
    this.isStatic = (ext, fn) => {
        let reg = new RegExp(`^\/.+\.${ext}$`);
        return reg.test(fn);
    }

    this.sendFile = (res, headers) => {
        fs.access(filePath, fs.constants.R_OK, err => {
            if (err) {
                res.writeHead(404, { 'content-type': 'text/plain' });
                res.end('Resourse not found');
            }
            else {
                res.writeHead(200, headers);
                fs.createReadStream(filePath).pipe(res);
            }
        });
    }
}

const mimeTypes = {
    html: 'text/html',
    css: 'text/css',
    js: 'text/javascript',
    png: 'image/png',
    docx: 'application/msword',
    json: 'application/json',
    xml: 'application/xml',
    mp4: 'video/mp4'
};

let handler = (staticFolder) => {
    return (req, res) => {
        if (req.method !== 'GET') {
            res.writeHead(405, { 'content-type': 'text/plain' });
            res.end('Method not allowed');
            return;
        }

        let filePath = path.join(staticFolder, req.url);
        let ext = path.extname(filePath).slice(1);

        let stat = new Stat(filePath);

        if (stat.isStatic(ext, req.url)) {
            stat.sendFile(res, {'content-type': `${mimeTypes[ext]}; charset=utf-8`});
        }
        else {
            res.writeHead(404, { 'content-type': 'text/plain' });
            res.end('Resourse not found');
        }
    }
}
 
module.exports = (staticFolder) => { return handler(staticFolder); }