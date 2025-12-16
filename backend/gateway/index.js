const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const cors = require('cors');

const app = express();

// Habilita CORS para permitir que o Flutter (Web/Emulador) acesse o Gateway
app.use(cors());

// Configuração das URLs dos Microsserviços
// Se estiver rodando no Docker, usa o nome do serviço (auth-service).
// Se estiver rodando local sem Docker, usa localhost.
const AUTH_URL = process.env.AUTH_SERVICE_URL || 'http://auth-service:3001';
const GAME_URL = process.env.GAME_SERVICE_URL || 'http://game-service:3002';

console.log(`Gateway iniciado.`);
console.log(`-> Redirecionando AUTH para: ${AUTH_URL}`);
console.log(`-> Redirecionando GAME para: ${GAME_URL}`);

// ---------------------------------------------------------
// 1. Rota de Autenticação (COM REWRITE)
// O Flutter manda: POST /auth/register
// O Gateway transforma em: POST /register
// O Auth-Service recebe: POST /register (E aceita!)
// ---------------------------------------------------------
app.use('/auth', createProxyMiddleware({ 
    target: AUTH_URL, 
    changeOrigin: true,
    pathRewrite: {
        '^/auth': '', // Remove o prefixo /auth
    }
}));

// ---------------------------------------------------------
// 2. Rota de Usuário (SEM REWRITE)
// O Flutter manda: GET /user/me
// O Auth-Service recebe: GET /user/me (Se ele tiver essa rota definida assim)
// ---------------------------------------------------------
app.use('/user', createProxyMiddleware({ 
    target: AUTH_URL, 
    changeOrigin: true 
}));

// ---------------------------------------------------------
// 3. Rotas do Jogo (SEM REWRITE)
// Assume-se que o Game Service espera receber /ranking, /quizzes, etc.
// ---------------------------------------------------------
app.use(['/ranking', '/quizzes', '/questions'], createProxyMiddleware({ 
    target: GAME_URL, 
    changeOrigin: true 
}));

// Rota de Health Check (opcional, para testar se o gateway está vivo)
app.get('/', (req, res) => {
    res.send('API Gateway SoccerQuiz está rodando! 🚀');
});

const PORT = 3000;
app.listen(PORT, () => console.log(`GATEWAY rodando na porta ${PORT}`));