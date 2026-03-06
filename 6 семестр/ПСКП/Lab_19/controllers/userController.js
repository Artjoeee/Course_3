const fs = require("fs");

const users = fs.readFileSync("model/data.json");
let data = JSON.parse(users);

const userController = {
    getUsers: (_, res) => {
        if (!data) {
            return res.sendStatus(404);
        }

        res.send(data);
    },

    addUser: (req, res) => {
        let body = '';
        req.on("data", (chunk) => body += chunk);
        req.on("end", () => {
            const user = JSON.parse(body);

            if (data.find(u => u.id === user.id)) {
                return res.sendStatus(409);
            }

            data.push(user);
            fs.writeFileSync("model/data.json", JSON.stringify(data, null, 2));
            res.status(200).send(JSON.parse(body));
        });
    }
}

module.exports = userController;