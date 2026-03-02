const { createClient } = require('redis');

const subscriber = createClient();
const publisher = createClient();

(async () => {
    await subscriber.connect();
    await publisher.connect();

    await subscriber.subscribe('channel', (message) => {
        console.log('SUBSCRIBER received:', message);
    });

    console.log('Subscribed to channel');

    let i = 1;

    setInterval(async () => {
        const msg = `Message ${i++}`;
        console.log('PUBLISHER sent:', msg);

        await publisher.publish('channel', msg);
    }, 1000);
})();
