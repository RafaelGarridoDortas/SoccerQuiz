const express = require('express');
const cors = require('cors');
const db = require('./database.js');

const app = express();
app.use(express.json());
app.use(cors());

// REQ 08 - Ranking (Mock Visual)
app.get('/ranking/top', (req, res) => {
    const ranking = [
        { rank: 1, name: "João Silva", time: "2:03", hits: 10 },
        { rank: 2, name: "Maria Oliveira", time: "2:35", hits: 9 },
        { rank: 3, name: "Admin", time: "2:40", hits: 8 },
        { rank: 4, name: "Carlos", time: "3:00", hits: 7 }
    ];
    res.json(ranking);
});

// REQ 06 - Listar Salas
app.get('/quizzes', (req, res) => {
    db.all("SELECT * FROM quizzes", [], (err, rows) => {
        if (err) return res.status(400).json({"error": err.message});
        res.json(rows);
    });
});

// REQ 04 - Cadastrar Pergunta (Conectado com create_quiz_screen.dart)
app.post('/questions', (req, res) => {
    // O Front manda: { question: "...", options: ["a", "b"], correctIndex: 0 }
    const { question, options, correctIndex } = req.body;
    
    // Convertemos o array de opções para String para salvar no SQLite
    const optionsString = JSON.stringify(options); 

    const sql = 'INSERT INTO questions (question, options, correct_index) VALUES (?,?,?)';
    
    db.run(sql, [question, optionsString, correctIndex], function (err) {
        if (err) return res.status(400).json({"error": err.message});
        
        console.log(`Nova pergunta cadastrada: ${question}`);
        res.json({
            "message": "Pergunta salva com sucesso",
            "id": this.lastID
        });
    });
});

// Rota extra para listar perguntas (Para Debug)
app.get('/questions', (req, res) => {
    db.all("SELECT * FROM questions", [], (err, rows) => {
        if (err) return res.status(400).json({"error": err.message});
        // Converte a string de volta para JSON
        const questions = rows.map(r => ({
            ...r,
            options: JSON.parse(r.options)
        }));
        res.json(questions);
    });
});

app.listen(3002, () => {
    console.log('GAME SERVICE rodando na porta 3002');
});