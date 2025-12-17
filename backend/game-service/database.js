const sqlite3 = require('sqlite3').verbose();
const fs = require('fs');
const path = require('path');

const dbPath = process.env.DB_PATH || './game.db';
const dirName = path.dirname(dbPath);
if (!fs.existsSync(dirName)) fs.mkdirSync(dirName, { recursive: true });

const db = new sqlite3.Database(dbPath, (err) => {
  if (err) console.error(err);

  db.run(`
    CREATE TABLE IF NOT EXISTS quizzes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      type TEXT NOT NULL,
      team TEXT,
      time_limit INTEGER NOT NULL,
      coins INTEGER NOT NULL
    )
  `);

  db.run(`
    CREATE TABLE IF NOT EXISTS questions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      quiz_id INTEGER NOT NULL,
      question TEXT NOT NULL,
      options TEXT NOT NULL,
      correct_index INTEGER NOT NULL,
      FOREIGN KEY (quiz_id) REFERENCES quizzes(id)
    )
  `);

  db.run(`
    CREATE TABLE IF NOT EXISTS teams (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      league TEXT,
      logoUrl TEXT
    )
  `);

  db.run(`
    CREATE TABLE IF NOT EXISTS results (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER,
      user_name TEXT,
      quiz_id INTEGER,
      score INTEGER,
      time_taken INTEGER,
      date TEXT
    )
  `);

  db.run(`
    CREATE TABLE IF NOT EXISTS transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      value REAL,
      type TEXT,
      date TEXT
    )
  `);

  db.run(`
    CREATE TABLE IF NOT EXISTS invites (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT,
      status TEXT
    )
  `);
});

module.exports = db;
