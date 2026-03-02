const http = require('http');
const fs = require('fs');
const url = require('url');
const { parse } = require('querystring');
const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: 'artzham04022005@gmail.com',
        pass: 'xgrbynzzaivkzhlj'
    }
});

http.createServer((req, res) => {
    res.writeHead(200, {'content-type': 'text/html; charset=utf-8'});

    if (url.parse(req.url).pathname == '/' && req.method == 'GET') {
        res.end(fs.readFileSync('./06-02.html'));
    }
    else if (url.parse(req.url).pathname == '/' && req.method == 'POST') {
        let body = '';

        req.on('data', chunk => {body += chunk.toString();});
        req.on('end', () => {
            let parm = parse(body);

            const mailOptions = {
                from: parm.sender,
                to: parm.reciver,
                subject: '06-02',
                text: parm.message
            };

            transporter.sendMail(mailOptions, (error, info) => {
                if (error) {
                    console.error('Ошибка при отправке:', error);
                    res.end(`<h2>Ошибка при отправке: ${error.message}</h2>`);
                } 
                else {
                    console.log('Email отправлен:', info.response);
                    res.end(`<h1>OK: ${parm.sender}, ${parm.reciver}, ${parm.message}</h1>`);
                }
            });
        });
    }
    else {
        res.end('<h1>Not support</h1>');
    }

}).listen(5000);

console.log('http://localhost:5000/');