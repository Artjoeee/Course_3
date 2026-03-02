const http = require('http');
const url = require('url');
const mongoose = require('mongoose');

mongoose.connect('mongodb://localhost:27017/BSTU');

mongoose.connection.on('connected', () => console.log('MongoDB connected'));
mongoose.connection.on('error', err => console.error('MongoDB connection error:', err));

const facultySchema = new mongoose.Schema({
    faculty: { type: String, required: true, unique: true },
    faculty_name: { type: String, required: true }
}, { versionKey: false });

const pulpitSchema = new mongoose.Schema({
    pulpit: { type: String, required: true, unique: true },
    pulpit_name: { type: String, required: true },
    faculty: { type: String, required: true }
}, { versionKey: false });

const Faculty = mongoose.model('faculty', facultySchema, 'faculty');
const Pulpit = mongoose.model('pulpit', pulpitSchema, 'pulpit');

function sendJSON(res, status, data) {
    res.writeHead(status, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(data));
}

function getRequestBody(req) {
    return new Promise(resolve => {
        let body = '';
        req.on('data', chunk => body += chunk);
        req.on('end', () => resolve(body ? JSON.parse(body) : {}));
    });
}

const server = http.createServer(async (req, res) => {
    const parsedUrl = url.parse(req.url, true);
    const path = parsedUrl.pathname;

    if (req.method === 'GET' && path === '/api/faculties')
        return sendJSON(res, 200, await Faculty.find());

    if (req.method === 'POST' && path === '/api/faculties') {
        try {
            const body = await getRequestBody(req);
            if (await Faculty.findOne({ faculty: body.faculty }))
                return sendJSON(res, 409, { error: 'Faculty already exists' });

            const result = await Faculty.create(body);
            return sendJSON(res, 201, result);
        } catch (e) { return sendJSON(res, 400, { error: e.message }); }
    }

    if (req.method === 'PUT' && path === '/api/faculties') {
        try {
            const body = await getRequestBody(req);
            const result = await Faculty.findOneAndUpdate({ faculty: body.faculty }, body, { new: true });

            if (!result)
                return sendJSON(res, 404, { error: 'Faculty not found' });

            return sendJSON(res, 200, result);
        } catch (e) { return sendJSON(res, 400, { error: e.message }); }
    }

    if (req.method === 'DELETE' && path.startsWith('/api/faculties/')) {
        try {
            const code = decodeURI(path.split('/').pop());

            const pulpits = await Pulpit.countDocuments({ faculty: code });
            if (pulpits > 0)
                return sendJSON(res, 409, { error: 'Cannot delete faculty with existing pulpits' });

            const result = await Faculty.findOneAndDelete({ faculty: code });
            if (!result)
                return sendJSON(res, 404, { error: 'Faculty not found' });

            return sendJSON(res, 200, result);
        } catch (e) { return sendJSON(res, 400, { error: e.message }); }
    }

    if (req.method === 'GET' && path === '/api/pulpits')
        return sendJSON(res, 200, await Pulpit.find());

    if (req.method === 'POST' && path === '/api/pulpits') {
        try {
            const body = await getRequestBody(req);

            // faculty must exist!
            if (!await Faculty.findOne({ faculty: body.faculty }))
                return sendJSON(res, 400, { error: 'Faculty does not exist' });

            if (await Pulpit.findOne({ pulpit: body.pulpit }))
                return sendJSON(res, 409, { error: 'Pulpit already exists' });

            const result = await Pulpit.create(body);
            return sendJSON(res, 201, result);

        } catch (e) { return sendJSON(res, 400, { error: e.message }); }
    }

    if (req.method === 'PUT' && path === '/api/pulpits') {
        try {
            const body = await getRequestBody(req);

            if (!await Faculty.findOne({ faculty: body.faculty }))
                return sendJSON(res, 400, { error: 'Faculty does not exist' });

            const result = await Pulpit.findOneAndUpdate({ pulpit: body.pulpit }, body, { new: true });

            if (!result)
                return sendJSON(res, 404, { error: 'Pulpit not found' });

            return sendJSON(res, 200, result);
        } catch (e) { return sendJSON(res, 400, { error: e.message }); }
    }

    if (req.method === 'DELETE' && path.startsWith('/api/pulpits/')) {
        try {
            const code = decodeURI(path.split('/').pop());
            const result = await Pulpit.findOneAndDelete({ pulpit: code });

            if (!result)
                return sendJSON(res, 404, { error: 'Pulpit not found' });

            return sendJSON(res, 200, result);
        } catch (e) { return sendJSON(res, 400, { error: e.message }); }
    }

    sendJSON(res, 404, { error: 'Not Found' });
});

server.listen(3000, () => {
    console.log('Server running on http://localhost:3000')
});
