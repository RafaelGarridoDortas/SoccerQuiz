const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const cors = require('cors');

const app = express();

// Habilita CORS para permitir que o Flutter (Web/Emulador) acesse o Gateway sem bloqueios
app.use(cors());

// Configuração das URLs dos Microsserviços
// Se estiver rodando no Docker, usa o nome do serviço (auth-service/game-service).
// Se estiver rodando local sem Docker, usa localhost.
const AUTH_URL = process.env.AUTH_SERVICE_URL || 'http://auth-service:3001';
const GAME_URL = process.env.GAME_SERVICE_URL || 'http://game-service:3002';

console.log(`🚀 Gateway iniciado.`);
console.log(`-> Redirecionando AUTH para: ${AUTH_URL}`);
console.log(`-> Redirecionando GAME para: ${GAME_URL}`);

// ---------------------------------------------------------
// 1. Rota de Autenticação (COM REWRITE)
// O Flutter manda: POST /auth/register ou /auth/login
// O Gateway transforma em: POST /register ou /login
// O Auth-Service recebe e processa.
// ---------------------------------------------------------
app.use('/auth', createProxyMiddleware({ 
    target: AUTH_URL, 
    changeOrigin: true,
    pathRewrite: {
        '^/auth': '', // Remove o prefixo /auth da URL antes de enviar
    },
    onError: (err, req, res) => {
        console.error('Erro no Proxy Auth:', err);
        res.status(500).send('Erro ao conectar ao Auth Service');
    }
}));

// ---------------------------------------------------------
// 2. Rota de Usuário (SEM REWRITE)
// O Flutter manda: GET /user/me ou PUT /user/:id
// O Auth-Service recebe exatamente essas rotas.
// ---------------------------------------------------------
app.use('/user', createProxyMiddleware({ 
    target: AUTH_URL, 
    changeOrigin: true,
    onError: (err, req, res) => {
        console.error('Erro no Proxy User:', err);
        res.status(500).send('Erro ao conectar ao Auth Service (User)');
    }
}));

// ---------------------------------------------------------
// 3. Rotas do Jogo (SEM REWRITE)
// Aqui incluímos TODAS as novas funcionalidades implementadas:
// - /teams (Cadastro de times)
// - /results (Salvar resultado do quiz)
// - /finance (Dashboard financeiro)
// - /invite (Enviar convites)
// - /ranking (Listagens gerais e top players)
// - /quizzes e /questions (Core do jogo)
// ---------------------------------------------------------
app.use([
    '/quizzes', 
    '/questions', 
    '/ranking', 
    '/teams',      // Novo: REQ 03
    '/results',    // Novo: REQ 07 e 13
    '/finance',    // Novo: REQ 16
    '/invite'      // Novo: REQ 11
], createProxyMiddleware({ 
    target: GAME_URL, 
    changeOrigin: true,
    onError: (err, req, res) => {
        console.error('Erro no Proxy Game:', err);
        res.status(500).send('Erro ao conectar ao Game Service');
    }
}));

// Rota de Health Check (para testar se o gateway está vivo no browser)
app.get('/', (req, res) => {
    res.send({
        status: 'Online',
        message: 'API Gateway SoccerQuiz está rodando! 🚀',
        services: {
            auth: AUTH_URL,
            game: GAME_URL
        }
    });
});

const PORT = 3000;
app.listen(PORT, () => console.log(`GATEWAY rodando na porta ${PORT}`));