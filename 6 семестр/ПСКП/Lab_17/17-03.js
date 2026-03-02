const { createClient } = require('redis');

const client = createClient();

client.on('error', err => console.error('Redis error:', err));
client.on('connect', () => console.log('Connected'));
client.on('ready', () => console.log('Ready'));
client.on('end', () => console.log('End'));

(async () => {
    await client.connect();

    await client.set('incr', 0);

    const pipeline = client.multi();

    console.log('Testing INCR...');
    for (let i = 0; i < 10000; i++) {
        pipeline.incr('incr');
    }

    let start = Date.now();
    await pipeline.exec();
    let incrTime = Date.now() - start;

    console.log('Testing DECR...');
    for (let i = 0; i < 10000; i++) {
        pipeline.decr('incr');
    }

    start = Date.now();
    await pipeline.exec();
    let decrTime = Date.now() - start;

    console.table([
        { operation: 'incr(incr)', time_ms: incrTime },
        { operation: 'decr(incr)', time_ms: decrTime }
    ]);

    await client.quit();
})();
