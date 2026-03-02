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
            const newPath = "./New_MyFile.png";

            fs.rename(tempPath, newPath, (err) => {
                if (err) {
                    res.writeHead(500, { "Content-Type": "text/plain" });
                    return res.end("Error saving file");
                }

                res.writeHead(200, { "Content-Type": "text/plain" });
                res.end("PNG файл получен и сохранён как New_MyFile.png");
            });
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
