const http = require('http');
const xml2js = require('xml2js');

const server = http.createServer((req, res) => {
    if (req.method === 'POST') {
        let body = "";

        req.on('data', chunk => body += chunk);

        req.on('end', () => {
            const parser = new xml2js.Parser({ explicitArray: false });

            parser.parseString(body, (err, result) => {
                if (err) {
                    res.writeHead(400, { "Content-Type": "text/plain" });
                    return res.end("XML parse error");
                }

                const request = result.request;

                const xValues = []
                    .concat(request.x)
                    .map(item => Number(item.$.value));

                const mValues = []
                    .concat(request.m)
                    .map(item => item.$.value);

                const sum = xValues.reduce((a, b) => a + b, 0);
                const concat = mValues.join('');

                const builder = new xml2js.Builder();

                const responseObj = {
                    response: {
                        $: { id: "09-05" },
                        sum: { $: { element: "x", result: sum } },
                        concat: { $: { element: "m", result: concat } }
                    }
                };

                const xmlResponse = builder.buildObject(responseObj);

                res.writeHead(200, { "Content-Type": "application/xml" });
                res.end(xmlResponse);
            });
        });
    }
    else {
        res.writeHead(405, { 'Content-Type': 'text/plain' });
        res.end('Method Not Allowed');
    }
});

server.listen(5000, () => {
    console.log('http://localhost:5000/');
});