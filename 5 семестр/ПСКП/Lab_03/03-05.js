const http = require('http');
const url = require('url');
const fs = require('fs');

function factorial(k) {
    if (k === 0 || k === 1) {
        return 1;
    }

    return k * factorial(k - 1);
}

function Fact(k, cb) {
    this.fk = k;
    this.ffact = factorial;
    this.fcb = cb;
    this.calc = () => {setImmediate(() => {this.fcb(null, this.ffact(this.fk));});}
}

http.createServer(function (request, response) {
    let rc = JSON.stringify({k: 0});

    if (url.parse(request.url).pathname === '/fact') {
        console.log(request.url);

        if (typeof url.parse(request.url, true).query.k != 'undefined') {
            let k = parseInt(url.parse(request.url, true).query.k);

            if (Number.isInteger(k)) {
                response.writeHead(200, {'content-type' : "application/json; charset=utf-8"});
                
                let fact = new Fact(k, (err, result) => {response.end(JSON.stringify({k:k, fact: result}));});
                fact.calc();
            }
        }
    }
    else if (url.parse(request.url).pathname === '/') {
        let html = fs.readFileSync('./03-02.html');

        response.writeHead(200, {'content-type' : 'text/html; charset=utf-8'});
        response.end(html);
    }
    else {
        response.end(rc);
    }
    
}).listen(5000);

console.log('http://localhost:5000/');