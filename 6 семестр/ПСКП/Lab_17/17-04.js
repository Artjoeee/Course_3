const { createClient } = require('redis');

const client = createClient();

client.on('error', err => console.error('Redis error:', err));
client.on('connect', () => console.log('Connected'));
client.on('ready', () => console.log('Ready'));
client.on('end', () => console.log('End'));

(async () => {
    await client.connect();

    const pipeline = client.multi();

    console.log('Testing HSET...');
    for (let n = 1; n <= 10000; n++) {
        pipeline.hSet(`${n}`, {
            id: n,
            val: `val-${n}`
        });
    }

    let start = Date.now();
    await pipeline.exec();
    let hsetTime = Date.now() - start;

    console.log('Testing HGET...');
    for (let n = 1; n <= 10000; n++) {
        pipeline.hGet(`${n}`, 'val');
    }

    start = Date.now();
    await pipeline.exec();
    let hgetTime = Date.now() - start;

    console.table([
        { operation: 'hset(n, {...})', time_ms: hsetTime },
        { operation: 'hget(n, val)', time_ms: hgetTime }
    ]);

    await client.quit();
})();
