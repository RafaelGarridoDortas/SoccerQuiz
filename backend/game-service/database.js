const sqlite3 = require('sqlite3').verbose();
const fs = require('fs');
const path = require('path');

const dbPath = process.env.DB_PATH || './game.db';
const dirName = path.dirname(dbPath);
if (!fs.existsSync(dirName)){
    fs.mkdirSync(dirName, { recursive: true });
}

const db = new sqlite3.Database(dbPath, (err) => {
    if (err) {
        console.error("Erro banco Game:", err.message);
    } else {
        console.log(`Conectado ao banco SQLite (Game) em: ${dbPath}`);

        db.run(`CREATE TABLE IF NOT EXISTS questions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            question text,
            options text, 
            correct_index INTEGER
        )`);


        db.run(`CREATE TABLE IF NOT EXISTS quizzes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name text,
            players text,
            price text
        )`, (err) => {
            if (!err) {

                 const insert = 'INSERT INTO quizzes (name, players, price) VALUES (?,?,?)';
                 db.get("SELECT count(*) as count FROM quizzes", (err, row) => {
                     if(row && row.count === 0) {
                         db.run(insert, ["Quiz da Turma", "2/10", "2 SC"]);
                         db.run(insert, ["Quiz de Sábado", "3/5", "1 SC"]);
                         db.run(insert, ["Desafio Mestre", "9/10", "5 SC"]);
                     }
                 });
            }
        });
    }
});

module.exports = db;