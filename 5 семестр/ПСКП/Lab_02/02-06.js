const http = require("http");
const fs = require("fs");

http.createServer(function (request, response) {
    if (request.url === "/jquery") {
        let html = fs.readFileSync("./jquery.html");
        
        response.writeHead(200, {"content-type" : "text/html; charset=utf-8"});
        response.end(html);
    }
    else if (request.url === "/api/name") {
        response.writeHead(200, {"content-type" : "text/plain; charset=utf-8"});
        response.end("Жамойдо Артём Игоревич");
    }
    else {
        response.writeHead(404, {"content-type" : "text/html; charset=utf-8"});
        response.end("Страница не найдена");
    }
    
}).listen(5000);

console.log("Server running at http://localhost:5000/");