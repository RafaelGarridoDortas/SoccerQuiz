class GameController {
    constructor(service) { this.service = service; }

    async createTeam(req, res) {
        try { await this.service.addTeam(req.body); res.status(201).json({message: "Time criado"}); } catch(e) { res.status(500).json({error: e.message}); }
    }
    async createQuestion(req, res) {
        try { await this.service.addQuestion(req.body); res.status(201).json({message: "Pergunta criada"}); } catch(e) { res.status(500).json({error: e.message}); }
    }
    async listQuizzes(req, res) {
        try { const data = await this.service.listQuizzes(); res.json(data); } catch(e) { res.status(500).json({error: e.message}); }
    }
    async saveResult(req, res) {
        try { await this.service.processResult(req.body); res.status(201).json({message: "Resultado salvo"}); } catch(e) { res.status(500).json({error: e.message}); }
    }
    async getRanking(req, res) {
        try { const data = await this.service.getRanking(); res.json(data); } catch(e) { res.status(500).json({error: e.message}); }
    }
    async getFastest(req, res) {
        try { const data = await this.service.getFastest(); res.json(data); } catch(e) { res.status(500).json({error: e.message}); }
    }
    async getFinance(req, res) {
        try { const data = await this.service.getFinancialData(); res.json(data); } catch(e) { res.status(500).json({error: e.message}); }
    }
    async invite(req, res) {
        try { await this.service.inviteUser(req.body.email); res.json({message: "Convite enviado"}); } catch(e) { res.status(500).json({error: e.message}); }
    }
}
module.exports = GameController;