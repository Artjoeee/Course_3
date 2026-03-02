const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 5000;
const DATA_FILE = path.join(__dirname, 'StudentList.json');
const BACKUP_DIR = path.join(__dirname, 'backups');

if (!fs.existsSync(BACKUP_DIR)) {
  	fs.mkdirSync(BACKUP_DIR);
}

let subscribers = [];

function readStudents() {
	try {
		return JSON.parse(fs.readFileSync(DATA_FILE));
	} 
	catch {
		throw new Error('ошибка чтения файла ' + DATA_FILE);
	}
}

function writeStudents(data) {
	fs.writeFileSync(DATA_FILE, JSON.stringify(data, null, 2));
	notifySubscribers('StudentList.json изменён');
}

function sendJSON(res, code, obj) {
	res.writeHead(code, { 'Content-Type': 'application/json; charset=utf-8' });
	res.end(JSON.stringify(obj));
}

function notifySubscribers(msg) {
	subscribers.forEach(res => {
		res.write(`data: ${msg}\n\n`);
	});
}

http.createServer((req, res) => {
	const url = decodeURI(req.url);
	const method = req.method;

	if (method === 'GET' && url === '/') {
		try {
			sendJSON(res, 200, readStudents());
		} 
		catch (e) {
			sendJSON(res, 500, { error: 1, message: e.message });
		}
	}
	else if (method === 'GET' && /^\/\d+$/.test(url)) {
		const id = Number(url.slice(1));
		const student = readStudents().find(s => s.id === id);

		student
		? sendJSON(res, 200, student)
		: sendJSON(res, 404, { error: 1, message: 'студент с id не найден' });
	}
	else if (method === 'POST' && url === '/') {
		let body = '';

		req.on('data', c => body += c);
		req.on('end', () => {
			const students = readStudents();
			const obj = JSON.parse(body);

			if (students.some(s => s.id === obj.id)) {
				return sendJSON(res, 409, { error: 1, message: 'студент с таким id уже есть' });
			}

			students.push(obj);

			writeStudents(students);
			sendJSON(res, 200, obj);
		});
	}
	else if (method === 'PUT' && url === '/') {
		let body = '';

		req.on('data', c => body += c);
		req.on('end', () => {
			const students = readStudents();
			const obj = JSON.parse(body);
			const index = students.findIndex(s => s.id === obj.id);

			if (index === -1) {
				return sendJSON(res, 404, { error: 1, message: 'студент с id не найден' });
			}

			students[index] = obj;

			writeStudents(students);
			sendJSON(res, 200, obj);
		});
	}
	else if (method === 'DELETE' && /^\/\d+$/.test(url)) {
		const id = Number(url.slice(1));
		const students = readStudents();
		const index = students.findIndex(s => s.id === id);

		if (index === -1) {
			return sendJSON(res, 404, { error: 1, message: 'студент с id не найден' });
		}

		const deleted = students.splice(index, 1)[0];

		writeStudents(students);
		sendJSON(res, 200, deleted);
	}
	else if (method === 'POST' && url === '/backup') {
		setTimeout(() => {
			const now = new Date();

			const YYYY = now.getFullYear();
			const MM   = String(now.getMonth() + 1).padStart(2, '0');
			const DD   = String(now.getDate()).padStart(2, '0');
			const HH   = String(now.getHours()).padStart(2, '0');
			const SS   = String(now.getSeconds()).padStart(2, '0');

			const ts = `${YYYY}${MM}${DD}${HH}${SS}`;

			fs.copyFileSync(
				DATA_FILE,
				path.join(BACKUP_DIR, `${ts}_StudentList.json`)
			);

			notifySubscribers(`Создана копия: ${ts}_StudentList.json`);
			res.end('backup created');
		}, 2000);
	}

	else if (method === 'GET' && url === '/backup') {
		sendJSON(res, 200, fs.readdirSync(BACKUP_DIR));
	}
	else if (method === 'DELETE' && url.startsWith('/backup/')) {
		const raw = url.split('/')[2];

		const yyyy = raw.slice(0, 4);
		const dd   = raw.slice(4, 6);
		const mm   = raw.slice(6, 8);

		const normalized = yyyy + mm + dd;

		fs.readdirSync(BACKUP_DIR).forEach(f => {
			const fileDate = f.slice(0, 8);

			if (fileDate < normalized) {
				fs.unlinkSync(path.join(BACKUP_DIR, f));
				notifySubscribers(`Удалена копия: ${f}`);
			}
		});

		res.end('old backups deleted');
	}
	else if (method === 'GET' && url === '/subscribe') {
		res.writeHead(200, {
			'Content-Type': 'text/event-stream',
			'Cache-Control': 'no-cache',
			'Connection': 'keep-alive'
		});

		subscribers.push(res);
	}
	else {
		res.writeHead(404);
		res.end();
	}

}).listen(PORT, () =>
  	console.log(`http://localhost:${PORT}`)
);
