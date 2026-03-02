const { createClient } = require('redis');

const client = createClient();

client.on('error', err => console.error('Redis error:', err));
client.on('connect', () => console.log('Connected'));
client.on('ready', () => console.log('Ready'));
client.on('end', () => console.log('End'));

(async () => {
    await client.connect();

    const pipeline = client.multi();

    console.log('Testing SET...');
    for (let n = 1; n <= 10000; n++) {
        pipeline.set(n.toString(), `set${n}`);
    }

    let start = Date.now();
    await pipeline.exec();
    let setTime = Date.now() - start;

    console.log('Testing GET...');
    for (let n = 1; n <= 10000; n++) {
        pipeline.get(n.toString());
    }

    start = Date.now();
    await pipeline.exec();
    let getTime = Date.now() - start;

    console.log('Testing DEL...');
    for (let n = 1; n <= 10000; n++) {
        pipeline.del(n.toString());
    }

    start = Date.now();
    await pipeline.exec();
    let delTime = Date.now() - start;

    console.table([
        { operation: 'set(n, setn)', time_ms: setTime },
        { operation: 'get(n)', time_ms: getTime },
        { operation: 'del(n)', time_ms: delTime }
    ]);

    await client.quit();
})();
