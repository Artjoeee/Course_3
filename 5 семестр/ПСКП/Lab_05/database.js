const util = require("util");
const ee = require("events");

let db_data = [
    {id: 1, name: 'Messi', bday: '1987-07-25'},
    {id: 2, name: 'Ronaldo', bday: '1985-02-05'},
    {id: 3, name: 'Mbappe', bday: '1998-12-20'},
];

function DB() {
    this.select = async () => {return db_data;};
    this.insert = async (row) => {db_data.push(row);};

    this.update = async (id, newData) => {
        let index = db_data.findIndex(elem => elem.id === id);

        if (index !== -1) {
            db_data[index] = {...db_data[index], ...newData};
            return db_data[index];
        }

        return null;
    };

    this.delete = async (id) => {
        let index = db_data.findIndex(elem => elem.id === id);
        
        if (index !== -1) {
            let deleted = db_data.splice(index, 1)[0];
            return deleted;
        }

        return null;
    };

    this.commit = async () => {
        this.emit('COMMIT');
    };
}

util.inherits(DB, ee.EventEmitter);

exports.DB = DB;