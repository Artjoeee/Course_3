const http = require('http');

let state = 'norm';
let laststate = state.trim();

http.createServer(function(request, response) {
    response.writeHead(200, {'content-type' : 'text/html; charset=utf-8'});
    response.end(`<h1>${laststate}<h1>`);
}).listen(5000);

console.log('http://localhost:5000/');

process.stdin.setEncoding('utf-8');
process.stdout.write(laststate + '->');
process.stdin.on('readable', () => {

    while ((state = process.stdin.read()) != null) {
        if (state.trim() == 'exit') {
            process.exit(0);
        }
        else if (state.trim() == 'norm') {
            process.stdout.write('reg = '+ laststate + '--> ' + state.trim() + '\n');
            laststate = state.trim();
            process.stdout.write(laststate + '->');
        }
        else if (state.trim() == 'stop') {
            process.stdout.write('reg = '+ laststate + '--> ' + state.trim() + '\n');
            laststate = state.trim();
            process.stdout.write(laststate + '->');
        }
        else if (state.trim() == 'test') {
            process.stdout.write('reg = '+ laststate + '--> ' + state.trim() + '\n');
            laststate = state.trim();
            process.stdout.write(laststate + '->');
        }
        else if (state.trim() == 'idle') {
            process.stdout.write('reg = '+ laststate + '--> ' + state.trim() + '\n');
            laststate = state.trim();
            process.stdout.write(laststate + '->');
        }
        else {
            process.stdout.write(state.trim()+ '\n');
            process.stdout.write(laststate + '->');
        }
    }
});