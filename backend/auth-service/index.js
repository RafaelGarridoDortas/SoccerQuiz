const express = require('express');
const bodyParser = require('body-parser');
const jwt = require('jsonwebtoken');
const md5 = require('md5');
const cors = require('cors');
const db = require('./database'); // Importa a conexão com o banco

const app = express();

app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());
app.use(cors());

const PORT = 3001;
const SECRET = process.env.JWT_SECRET || 'segredo_padrao_dev';

console.log('Auth Service iniciando...');

// ------------------------------------------------------------------
// ROTA DE REGISTRO (O Gateway manda /register para cá)
// ------------------------------------------------------------------
app.post('/register', (req, res) => {
    const { name, email, password } = req.body;

    // Validação básica
    if (!name || !email || !password) {
        return res.status(400).json({ error: "Nome, email e senha são obrigatórios" });
    }

    const passwordHash = md5(password); // Em produção, use bcrypt!
    const coins = 100; // Bônus inicial

    const sql = 'INSERT INTO users (name, email, password, coins) VALUES (?,?,?,?)';
    const params = [name, email, passwordHash, coins];

    db.run(sql, params, function (err) {
        if (err) {
            // Erro comum: Email duplicado (se tiver UNIQUE no banco)
            return res.status(400).json({ error: err.message });
        }
        
        // Sucesso! Retorna o ID criado
        res.status(201).json({
            message: "Usuário criado com sucesso",
            userId: this.lastID
        });
    });
});

// ------------------------------------------------------------------
// ROTA DE LOGIN
// ------------------------------------------------------------------
app.post('/login', (req, res) => {
    const { email, password } = req.body;
    const passwordHash = md5(password);

    const sql = 'SELECT * FROM users WHERE email = ? AND password = ?';
    
    db.get(sql, [email, passwordHash], (err, row) => {
        if (err) {
            return res.status(500).json({ error: "Erro no servidor" });
        }
        if (!row) {
            return res.status(401).json({ auth: false, token: null, error: "Email ou senha inválidos" });
        }

        // Gera o Token JWT
        const token = jwt.sign({ id: row.id, email: row.email }, SECRET, { expiresIn: '1h' });
        
        res.json({ auth: true, token: token, name: row.name });
    });
});

// ------------------------------------------------------------------
// ROTA DE DADOS DO USUÁRIO (Gateway manda /user/me para cá)
// ------------------------------------------------------------------
// Middleware para validar token
function verifyToken(req, res, next) {
    const token = req.headers['x-access-token'];
    if (!token) return res.status(403).json({ auth: false, message: 'Nenhum token fornecido.' });

    jwt.verify(token, SECRET, (err, decoded) => {
        if (err) return res.status(500).json({ auth: false, message: 'Falha ao autenticar token.' });
        req.userId = decoded.id;
        next();
    });
}

app.get('/user/me', verifyToken, (req, res) => {
    const sql = "SELECT id, name, email, coins FROM users WHERE id = ?";
    db.get(sql, [req.userId], (err, row) => {
        if (err) return res.status(500).send("Erro ao buscar usuário.");
        if (!row) return res.status(404).send("Usuário não encontrado.");
        res.status(200).json(row);
    });
});

// Inicializa o servidor
app.listen(PORT, () => {
    console.log(`AUTH SERVICE rodando na porta ${PORT}`);
});