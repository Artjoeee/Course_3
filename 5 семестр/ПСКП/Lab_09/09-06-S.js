const http = require('http');
const fs = require('fs');
const multiparty = require('multiparty');

const server = http.createServer((req, res) => {
    if (req.method === 'POST') {
        const form = new multiparty.Form();

        form.parse(req, (err, fields, files) => {
            if (err) {
                res.writeHead(500, { "Content-Type": "text/plain" });
                return res.end("Error parsing form data");
            }

            const file = files.myfile[0];

            const tempPath = file.path;
            const newPath = "./New_MyFile.txt";

            fs.renameSync(tempPath, newPath);

            res.writeHead(200, { "Content-Type": "text/plain" });
            res.end("Файл получен и сохранён как New_MyFile.txt");
        });

    } 
    else {
        res.writeHead(404, { "Content-Type": "text/plain" });
        res.end("Not found");
    }
});

server.listen(5000, () => {
    console.log('http://localhost:5000/');
});
