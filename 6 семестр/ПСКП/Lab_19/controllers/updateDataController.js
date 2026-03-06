const fs = require("fs");

const users = fs.readFileSync("model/data.json");
let data = JSON.parse(users);

const updateDataController = {
    updateUser: (req, res) => {
        let body = '';
        req.on("data", (chunk) => body += chunk);
        req.on("end", () => {
            const user = JSON.parse(body);
            let updateData = data.find(u => u.id === user.id);
            
            if (!updateData) {
                return res.sendStatus(404);
            }

            let index = data.indexOf(updateData);
            data.splice(index, 1, user);

            fs.writeFileSync("model/data.json", JSON.stringify(data, null, 2));
            res.status(200).send(JSON.parse(body));
        });
    },

    deleteUser: (req, res) => {
        let updateData = data.find(u => u.id === Number(req.params.id));

        if (!updateData) {
            return res.sendStatus(404);
        }

        let index = data.indexOf(updateData);
        data.splice(index, 1);

        fs.writeFileSync("model/data.json", JSON.stringify(data, null, 2));
        res.send(updateData);
    }
}

module.exports = updateDataController;