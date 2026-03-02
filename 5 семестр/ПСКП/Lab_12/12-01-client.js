const http = require('http');

const options = {
    hostname: 'localhost',
    port: 5000,
    path: '/subscribe',
    method: 'GET',
    headers: {
        'Accept': 'text/event-stream'
    }
};

const req = http.request(options, (res) => {

    console.log('Подписка успешно установлена');
    console.log(`Статус: ${res.statusCode}\n`);

    res.setEncoding('utf8');

    let buffer = '';

    res.on('data', chunk => {
        buffer += chunk;

        while (buffer.includes('\n\n')) {
            const msg = buffer.slice(0, buffer.indexOf('\n\n'));
            buffer = buffer.slice(buffer.indexOf('\n\n') + 2);

            if (msg.startsWith('data:')) {
                const data = msg.replace('data:', '').trim();
                const time = new Date().toLocaleTimeString();
                console.log(`[${time}] Уведомление: ${data}`);
            }
        }
    });

    res.on('end', () => {
        console.log('\nСоединение с сервером завершено');
    });
});

req.on('error', err => {
    console.error('Ошибка подключения:', err.message);
});

req.end();
