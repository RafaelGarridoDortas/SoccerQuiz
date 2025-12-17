const express = require('express');
const cors = require('cors');
const db = require('./database');

const app = express();
app.use(express.json());
app.use(cors());

// =======================
// QUIZZES
// =======================

app.post('/quizzes', (req, res) => {
  const { title, type, team, timeLimit, coins } = req.body;

  db.run(
    `
    INSERT INTO quizzes (title, type, team, time_limit, coins)
    VALUES (?, ?, ?, ?, ?)
    `,
    [title, type, team || null, timeLimit, coins],
    function (err) {
      if (err) {
        console.error(err);
        return res.status(500).json({ error: err.message });
      }
      res.json({ id: this.lastID });
    }
  );
});

app.get('/quizzes', (req, res) => {
  db.all(`SELECT * FROM quizzes`, (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(rows);
  });
});

// =======================
// QUESTIONS
// =======================

app.post('/quizzes/:id/questions', (req, res) => {
  const quizId = req.params.id;
  const { question, options, correctIndex } = req.body;

  db.run(
    `
    INSERT INTO questions (quiz_id, question, options, correct_index)
    VALUES (?, ?, ?, ?)
    `,
    [quizId, question, JSON.stringify(options), correctIndex],
    function (err) {
      if (err) {
        console.error(err);
        return res.status(500).json({ error: err.message });
      }
      res.json({ id: this.lastID });
    }
  );
});

app.get('/quizzes/:id/questions', (req, res) => {
  db.all(
    `SELECT * FROM questions WHERE quiz_id = ?`,
    [req.params.id],
    (err, rows) => {
      if (err) return res.status(500).json({ error: err.message });

      res.json(
        rows.map(q => ({
          ...q,
          options: JSON.parse(q.options),
        }))
      );
    }
  );
});

app.listen(3002, () => {
  console.log('✅ Game Service rodando na porta 3002');
});
