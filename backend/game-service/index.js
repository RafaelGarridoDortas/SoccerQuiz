const express = require('express');
const cors = require('cors');
const db = require('./database.js');
const GameRepository = require('./src/repositories/gameRepository.js');
const GameService = require('./src/services/gameService.js');
const GameController = require('./src/controllers/gameController.js');

const app = express();
app.use(express.json());
app.use(cors());

const repo = new GameRepository(db);
const service = new GameService(repo);
const controller = new GameController(service);

// Rotas
app.post('/teams', (req, res) => controller.createTeam(req, res));
app.post('/questions', (req, res) => controller.createQuestion(req, res));
app.get('/quizzes', (req, res) => controller.listQuizzes(req, res));
app.post('/results', (req, res) => controller.saveResult(req, res));
app.get('/ranking/general', (req, res) => controller.getRanking(req, res));
app.get('/ranking/fastest', (req, res) => controller.getFastest(req, res));
app.get('/finance', (req, res) => controller.getFinance(req, res));
app.post('/invite', (req, res) => controller.invite(req, res));

app.listen(3002, () => console.log('Game Service running on 3002'));