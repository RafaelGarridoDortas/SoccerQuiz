const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const cors = require('cors');

const app = express();

// ---------------------------------------------------------
// Habilita CORS (Flutter Web / Mobile)
// ---------------------------------------------------------
app.use(cors());

// ---------------------------------------------------------
// CONFIGURAÇÃO CORRETA PARA AMBIENTE LOCAL (SEM DOCKER)
// ⚠️ NÃO use auth-service fora do Docker
// ---------------------------------------------------------
const AUTH_URL = process.env.AUTH_SERVICE_URL || 'http://localhost:3001';
const GAME_URL = process.env.GAME_SERVICE_URL || 'http://localhost:3002';

console.log('🚀 Gateway iniciado');
console.log(`🔐 Auth Service -> ${AUTH_URL}`);
console.log(`🎮 Game Service -> ${GAME_URL}`);

// ---------------------------------------------------------
// 1. ROTAS DE AUTENTICAÇÃO
// Flutter chama: POST /auth/login ou /auth/register
// Gateway envia:  POST /login ou /register
// ---------------------------------------------------------
app.use(
  '/auth',
  createProxyMiddleware({
    target: AUTH_URL,
    changeOrigin: true,
    pathRewrite: {
      '^/auth': '',
    },
    onError: (err, req, res) => {
      console.error('❌ Erro no Proxy Auth:', err.message);
      res
        .status(500)
        .json({ message: 'Erro ao conectar ao Auth Service' });
    },
  })
);

// ---------------------------------------------------------
// 2. ROTAS DE USUÁRIO (TOKEN)
// Flutter chama: /user/me, /user/:id
// ---------------------------------------------------------
app.use(
  '/user',
  createProxyMiddleware({
    target: AUTH_URL,
    changeOrigin: true,
    onError: (err, req, res) => {
      console.error('❌ Erro no Proxy User:', err.message);
      res
        .status(500)
        .json({ message: 'Erro ao conectar ao Auth Service (User)' });
    },
  })
);

// ---------------------------------------------------------
// 3. ROTAS DO JOGO
// ---------------------------------------------------------
app.use(
  [
    '/quizzes',
    '/questions',
    '/ranking',
    '/teams',
    '/results',
    '/finance',
    '/invite',
  ],
  createProxyMiddleware({
    target: GAME_URL,
    changeOrigin: true,
    onError: (err, req, res) => {
      console.error('❌ Erro no Proxy Game:', err.message);
      res
        .status(500)
        .json({ message: 'Erro ao conectar ao Game Service' });
    },
  })
);

// ---------------------------------------------------------
// HEALTH CHECK
// ---------------------------------------------------------
app.get('/', (req, res) => {
  res.json({
    status: 'Online',
    message: 'API Gateway SoccerQuiz rodando 🚀',
    services: {
      auth: AUTH_URL,
      game: GAME_URL,
    },
  });
});

// ---------------------------------------------------------
const PORT = 3000;
app.listen(PORT, () =>
  console.log(`✅ Gateway rodando em http://localhost:${PORT}`)
);
