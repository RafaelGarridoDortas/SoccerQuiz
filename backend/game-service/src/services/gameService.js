class GameService {
    constructor(repo) { this.repo = repo; }

    async addTeam(data) { return await this.repo.createTeam(data); }
    async addQuestion(data) { return await this.repo.createQuestion(data); }
    async listQuizzes() { return await this.repo.getQuizzes(); }
    
    async processResult(data) {
        await this.repo.saveResult(data);
        // Gera transação financeira automática ao finalizar
        this.repo.saveTransaction({ title: 'Recompensa de Jogo', value: 10.0, type: 'in', date: new Date().toLocaleDateString() });
        return true;
    }

    async getRanking() { return await this.repo.getGeneralRanking(); }
    async getFastest() { return await this.repo.getFastestPlayer(); }
    
    async getFinancialData() {
        const transactions = await this.repo.getTransactions();
        const balance = transactions.reduce((acc, curr) => curr.type === 'in' ? acc + curr.value : acc - curr.value, 0);
        return { balance, transactions };
    }

    async inviteUser(email) {
        await this.repo.saveInvite(email);
        console.log(`[REQ 17 - NOTIFICATION] Enviando email para ${email}...`); // Simulação de notificação
        return true;
    }
}
module.exports = GameService;