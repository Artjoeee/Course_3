const http = require("http");
const fs = require("fs");
const path = require("path");
const url = require("url");
const { Sequelize, DataTypes } = require("sequelize");

const sequelize = new Sequelize("ZAI", "student", "fitfit", {
    host: "localhost",
    dialect: "mssql",
    logging: false,
    dialectOptions: {
        options: {
        encrypt: false,
        trustServerCertificate: true,
        },
    },
});

const Faculty = sequelize.define(
    "FACULTY",
    {
        FACULTY: { type: DataTypes.STRING(10), primaryKey: true },
        FACULTY_NAME: { type: DataTypes.STRING(80), allowNull: false },
    },
    { tableName: "FACULTY", timestamps: false }
);

const Pulpit = sequelize.define(
    "PULPIT",
    {
        PULPIT: { type: DataTypes.STRING(30), primaryKey: true },
        PULPIT_NAME: { type: DataTypes.STRING(170), allowNull: false },
        FACULTY: { type: DataTypes.STRING(10), allowNull: false },
    },
    { tableName: "PULPIT", timestamps: false }
);

const Subject = sequelize.define(
    "SUBJECT",
    {
        SUBJECT: { type: DataTypes.STRING(30), primaryKey: true },
        SUBJECT_NAME: { type: DataTypes.STRING(100), allowNull: false },
        PULPIT: { type: DataTypes.STRING(30), allowNull: false },
    },
    { tableName: "SUBJECT", timestamps: false }
);

const AuditoriumType = sequelize.define(
    "AUDITORIUM_TYPE",
    {
        AUDITORIUM_TYPE: { type: DataTypes.STRING(60), primaryKey: true },
        AUDITORIUM_TYPENAME: { type: DataTypes.STRING(60), allowNull: false },
    },
    { tableName: "AUDITORIUM_TYPE", timestamps: false }
);

const Auditorium = sequelize.define(
    "AUDITORIUM",
    {
        AUDITORIUM: { type: DataTypes.STRING(10), primaryKey: true },
        AUDITORIUM_NAME: { type: DataTypes.STRING(200), allowNull: false },
        AUDITORIUM_TYPE: { type: DataTypes.STRING(60), allowNull: false },
        AUDITORIUM_CAPACITY: { type: DataTypes.INTEGER },
    },
    { tableName: "AUDITORIUM", timestamps: false }
);

const Teacher = sequelize.define(
    "TEACHER",
    {
        TEACHER: { type: DataTypes.STRING(30), primaryKey: true },
        TEACHER_NAME: { type: DataTypes.STRING(70), allowNull: false },
        PULPIT: { type: DataTypes.STRING(30), allowNull: false },
    },
    { tableName: "TEACHER", timestamps: false }
);

// sequelize.sync().then(result=>{
//   console.log(result);
// })
// .catch(err=> console.log(err));

Pulpit.belongsTo(Faculty,  {
    foreignKey: 'FACULTY',
    as: 'faculty'
});

Subject.belongsTo(Pulpit, {
    foreignKey: 'PULPIT',
    as: 'pulpit'
});

Teacher.belongsTo(Pulpit, {
    foreignKey: 'PULPIT',
    as: 'pulpit'
});

Auditorium.belongsTo(AuditoriumType, {
    foreignKey: 'AUDITORIUM_TYPE',
    as: 'auditorium_type'
});

async function initDB() {
    await sequelize.authenticate();
    console.log("Connected via Sequelize");
}

function parseBody(req) {
    return new Promise((resolve, reject) => {
        let body = "";

        req.on("data", (c) => (body += c));
        req.on("end", () => resolve(JSON.parse(body || "{}")));
        req.on("error", reject);
    });
}

initDB();

const server = http.createServer(async (req, res) => {
    const parsed = url.parse(req.url, true);
    const pathParts = parsed.pathname.split("/").filter(Boolean);

    res.setHeader("Content-Type", "application/json; charset=utf-8");

    try {
        if (req.method === "GET" && parsed.pathname === "/") {
            const html = fs.readFileSync(path.join(__dirname, "index.html"), "utf8");
            res.writeHead(200, { "Content-Type": "text/html; charset=UTF-8" });
            return res.end(html);
        }

        if (pathParts[0] !== "api") {
            res.writeHead(404);
            return res.end(JSON.stringify({ error: "Not found" }));
        }

        // FACULTIES
        if (pathParts[1] === "faculties") {
            if (req.method === "GET") {
                const rows = await Faculty.findAll();
                return res.end(JSON.stringify(rows));
            }

            if (req.method === "POST") {
                const data = await parseBody(req);
                const row = await Faculty.create(data);

                res.writeHead(201);
                return res.end(JSON.stringify(row));
            }

            if (req.method === "PUT") {
                const data = await parseBody(req);
                const row = await Faculty.findByPk(data.FACULTY);

                if (!row) {
                    res.writeHead(404);
                    return res.end(JSON.stringify({ error: "Not found" }));
                }

                await row.update(data);
                return res.end(JSON.stringify(row));
            }

            if (req.method === "DELETE") {
                const code = decodeURIComponent(pathParts[2]).trim();
                const count = await Faculty.destroy({ where: { FACULTY: code } });

                if (!count) {
                    res.writeHead(404);
                    return res.end(JSON.stringify({ error: "Not found" }));
                }

                return res.end(JSON.stringify({ deleted: code }));
            }
        }

        // PULPITS
        if (pathParts[1] === "pulpits") {
            if (req.method === "GET") {
                const rows = await Pulpit.findAll();
                return res.end(JSON.stringify(rows));
            }

            if (req.method === "POST") {
                const data = await parseBody(req);
                const row = await Pulpit.create(data);

                res.writeHead(201);
                return res.end(JSON.stringify(row));
            }

            if (req.method === "PUT") {
                const data = await parseBody(req);
                const row = await Pulpit.findByPk(data.PULPIT);

                if (!row) {
                    res.writeHead(404);
                    return res.end(JSON.stringify({ error: "Not found" }));
                }

                await row.update(data);
                return res.end(JSON.stringify(row));
            }

            if (req.method === "DELETE") {
                const code = decodeURIComponent(pathParts[2]).trim();
                const deleted = await Pulpit.destroy({ where: { PULPIT: code } });

                if (!deleted) {
                    res.writeHead(404);
                    return res.end(JSON.stringify({ error: "Not found" }));
                }

                return res.end(JSON.stringify({ deleted: code }));
            }
        }

        // SUBJECTS
        if (pathParts[1] === "subjects") {
            if (req.method === "GET") {
                return res.end(JSON.stringify(
                    await Subject.findAll(
                        {
                            include: [{
                                model: Pulpit,
                                as: 'pulpit'
                            }]
                        }
                    )));
            }

            if (req.method === "POST") {
                const row = await Subject.create(await parseBody(req));
                res.writeHead(201);
                return res.end(JSON.stringify(row));
            }

            if (req.method === "PUT") {
                const data = await parseBody(req);
                const row = await Subject.findByPk(data.SUBJECT);

                await row.update(data);
                return res.end(JSON.stringify(row));
            }

            if (req.method === "DELETE") {
                const code = decodeURIComponent(pathParts[2]).trim();
                const deleted = await Subject.destroy({ where: { SUBJECT: code } });

                if (!deleted) {
                    res.writeHead(404);
                    return res.end(JSON.stringify({ error: "Not found" }));
                }

                return res.end(JSON.stringify({ deleted: code }));
            }
        }

        // TEACHERS
        if (pathParts[1] === "teachers") {
            if (req.method === "GET")
                return res.end(JSON.stringify(await Teacher.findAll()));

            if (req.method === "POST") {
                const row = await Teacher.create(await parseBody(req));
                res.writeHead(201);
                return res.end(JSON.stringify(row));
            }

            if (req.method === "PUT") {
                const data = await parseBody(req);
                const row = await Teacher.findByPk(data.TEACHER);

                await row.update(data);
                return res.end(JSON.stringify(row));
            }

            if (req.method === "DELETE") {
                const code = decodeURIComponent(pathParts[2]).trim();
                const deleted = await Teacher.destroy({ where: { TEACHER: code } });

                if (!deleted) {
                    res.writeHead(404);
                    return res.end(JSON.stringify({ error: "Not found" }));
                }

                return res.end(JSON.stringify({ deleted: code }));
            }
        }

        // AUDITORIUM TYPES
        if (pathParts[1] === "auditoriumtypes") {

            if (req.method === "GET" && pathParts.length === 2) {
                const rows = await AuditoriumType.findAll();
                return res.end(JSON.stringify(rows));
            }

            if (req.method === "POST" && pathParts.length === 2) {
                const data = await parseBody(req);

                if (!data.AUDITORIUM_TYPE || !data.AUDITORIUM_TYPENAME) {
                    res.writeHead(400);
                    return res.end(JSON.stringify({ error: "Missing fields" }));
                }

                const exists = await AuditoriumType.findByPk(data.AUDITORIUM_TYPE);

                if (exists) {
                    res.writeHead(400);
                    return res.end(JSON.stringify({ error: "Already exists" }));
                }

                const row = await AuditoriumType.create(data);

                res.writeHead(201);
                return res.end(JSON.stringify(row));
            }

            if (req.method === "PUT" && pathParts.length === 2) {
                const data = await parseBody(req);
                const row = await AuditoriumType.findByPk(data.AUDITORIUM_TYPE);

                if (!row) {
                    res.writeHead(404);
                    return res.end(JSON.stringify({ error: "Not found" }));
                }

                await row.update(data);
                return res.end(JSON.stringify(row));
            }

            if (req.method === "DELETE" && pathParts.length === 3) {
                const code = decodeURIComponent(pathParts[2]).trim();

                const used = await Auditorium.count({
                    where: { AUDITORIUM_TYPE: code }
                });

                if (used > 0) {
                    res.writeHead(400);
                    return res.end(JSON.stringify({
                        error: "Type used by auditoriums"
                    }));
                }

                const deleted = await AuditoriumType.destroy({
                    where: { AUDITORIUM_TYPE: code }
                });

                if (!deleted) {
                    res.writeHead(404);
                    return res.end(JSON.stringify({ error: "Not found" }));
                }

                return res.end(JSON.stringify({ deleted: code }));
            }
        }

        // AUDITORIUMS
        if (pathParts[1] === "auditoriums") {

            if (req.method === "GET" && pathParts.length === 2) {
                    const rows = await Auditorium.findAll({
                        include: [{
                            model: AuditoriumType,
                            as: 'auditorium_type'
                        }]
                    });

                return res.end(JSON.stringify(rows));
            }

            if (req.method === "POST" && pathParts.length === 2) {
                const data = await parseBody(req);

                if (!data.AUDITORIUM || !data.AUDITORIUM_NAME || !data.AUDITORIUM_TYPE) {
                    res.writeHead(400);
                    return res.end(JSON.stringify({ error: "Missing fields" }));
                }

                const type = await AuditoriumType.findByPk(data.AUDITORIUM_TYPE);

                if (!type) {
                    res.writeHead(400);
                    return res.end(JSON.stringify({ error: "Invalid type" }));
                }

                const exists = await Auditorium.findByPk(data.AUDITORIUM);

                if (exists) {
                    res.writeHead(400);
                    return res.end(JSON.stringify({ error: "Already exists" }));
                }

                const row = await Auditorium.create({
                    ...data,
                    AUDITORIUM_CAPACITY: parseInt(data.AUDITORIUM_CAPACITY) || 0
                });

                res.writeHead(201);
                return res.end(JSON.stringify(row));
            }

            if (req.method === "PUT" && pathParts.length === 2) {
                const data = await parseBody(req);

                const row = await Auditorium.findByPk(data.AUDITORIUM);

                if (!row) {
                    res.writeHead(404);
                    return res.end(JSON.stringify({ error: "Not found" }));
                }

                if (data.AUDITORIUM_TYPE) {
                    const type = await AuditoriumType.findByPk(data.AUDITORIUM_TYPE);

                    if (!type) {
                        res.writeHead(400);
                        return res.end(JSON.stringify({ error: "Invalid type" }));
                    }
                }

                await row.update({
                    ...data,
                    AUDITORIUM_CAPACITY:
                        data.AUDITORIUM_CAPACITY !== undefined
                        ? parseInt(data.AUDITORIUM_CAPACITY)
                        : row.AUDITORIUM_CAPACITY
                });

                return res.end(JSON.stringify(row));
            }

            if (req.method === "DELETE" && pathParts.length === 3) {
                const code = decodeURIComponent(pathParts[2]).trim();

                const deleted = await Auditorium.destroy({
                    where: { AUDITORIUM: code }
                });

                if (!deleted) {
                    res.writeHead(404);
                    return res.end(JSON.stringify({ error: "Not found" }));
                }

                return res.end(JSON.stringify({ deleted: code }));
            }
        }

        res.writeHead(404);
        res.end(JSON.stringify({ error: "Unknown route" }));
    } catch (err) {
        console.error(err);
        res.writeHead(500);
        res.end(JSON.stringify({ error: err.message }));
    }
});

server.listen(3000, () =>
    console.log("Server running http://localhost:3000")
);