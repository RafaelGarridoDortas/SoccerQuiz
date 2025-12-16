const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const db = require('./database.js');
const UserRepository = require('./src/repositories/userRepository.js');
const AuthService = require('./src/services/authService.js');
const AuthController = require('./src/controllers/authController.js');

const app = express();
app.use(bodyParser.json());
app.use(cors());

// Injeção de Dependência
const userRepo = new UserRepository(db);
const authService = new AuthService(userRepo);
const authController = new AuthController(authService);

const SECRET = process.env.JWT_SECRET || 'segredo_padrao_dev';

// Middleware de Token
function verifyToken(req, res, next) {
    const token = req.headers['x-access-token'];
    if (!token) return res.status(403).json({ message: 'No token provided.' });
    jwt.verify(token, SECRET, (err, decoded) => {
        if (err) return res.status(500).json({ message: 'Failed to authenticate.' });
        req.userId = decoded.id;
        next();
    });
}

// Rotas
app.post('/register', (req, res) => authController.register(req, res));
app.post('/login', (req, res) => authController.login(req, res));
app.get('/user/me', verifyToken, (req, res) => authController.getMe(req, res));
// Endpoints extras para manutenção (REQ 01)
app.put('/user/:id', verifyToken, (req, res) => authController.updateUser(req, res));
app.delete('/user/:id', verifyToken, (req, res) => authController.deleteUser(req, res));

app.listen(3001, () => console.log('Auth Service running on 3001'));