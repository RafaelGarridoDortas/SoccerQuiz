const sqlite3 = require('sqlite3').verbose();
const md5 = require('md5');
const fs = require('fs');
const path = require('path');

const dbPath = process.env.DB_PATH || './users.db';
const dirName = path.dirname(dbPath);
if (!fs.existsSync(dirName)){
    fs.mkdirSync(dirName, { recursive: true });
}

const db = new sqlite3.Database(dbPath, (err) => {
    if (err) {
        console.error("Erro ao abrir banco Auth:", err.message);
    } else {
        console.log(`Conectado ao banco SQLite (Auth) em: ${dbPath}`);
        
        db.run(`CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name text, 
            email text UNIQUE, 
            password text, 
            coins INTEGER DEFAULT 0
        )`, (err) => {
            if (!err) {
                const insert = 'INSERT OR IGNORE INTO users (name, email, password, coins) VALUES (?,?,?,?)';
                db.run(insert, ["Administrador", "admin@ufba.br", md5("123456"), 100]);
                db.run(insert, ["Eduardo Almeida", "eduardo@ufba.br", md5("123456"), 50]);
            }
        });
    }
});

module.exports = db;