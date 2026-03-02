const { createClient } = require('redis');

const client = createClient();

client.on('error', err => console.error('Redis error:', err));
client.on('connect', () => console.log('Connected'));
client.on('ready', () => console.log('Ready'));
client.on('end', () => console.log('End'));

(async () => {
    
    await client.connect();

    const pong = await client.ping();
    console.log('PING ->', pong);

    await client.quit();
})();