const sqlite3 = require('sqlite3').verbose();
const fs = require('fs');
const path = require('path');

const dbPath = process.env.DB_PATH || './game.db';
const dirName = path.dirname(dbPath);
if (!fs.existsSync(dirName)) fs.mkdirSync(dirName, { recursive: true });

const db = new sqlite3.Database(dbPath, (err) => {
    if (!err) {
        db.run(`CREATE TABLE IF NOT EXISTS questions (id INTEGER PRIMARY KEY, question text, options text, correct_index INTEGER)`);
        db.run(`CREATE TABLE IF NOT EXISTS quizzes (id INTEGER PRIMARY KEY, name text, players text, price text)`);
        // Mock inicial de quizzes
        db.get("SELECT count(*) as count FROM quizzes", (err, row) => {
             if(row && row.count === 0) {
                 db.run('INSERT INTO quizzes (name, players, price) VALUES (?,?,?)', ["Quiz da Turma", "2/10", "2 SC"]);
             }
        });
        
        // REQ 03: Times
        db.run(`CREATE TABLE IF NOT EXISTS teams (id INTEGER PRIMARY KEY, name text, league text, logoUrl text)`);
        // REQ 13 e 14: Resultados
        db.run(`CREATE TABLE IF NOT EXISTS results (id INTEGER PRIMARY KEY, user_id INTEGER, user_name TEXT, score INTEGER, time_taken INTEGER, date TEXT)`);
        // REQ 16: Finanças
        db.run(`CREATE TABLE IF NOT EXISTS transactions (id INTEGER PRIMARY KEY, title TEXT, value REAL, type TEXT, date TEXT)`);
        // REQ 11: Convites
        db.run(`CREATE TABLE IF NOT EXISTS invites (id INTEGER PRIMARY KEY, email TEXT, status TEXT)`);
    }
});
module.exports = db;