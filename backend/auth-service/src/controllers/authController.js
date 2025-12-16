class AuthController {
    constructor(authService) { this.authService = authService; }

    async register(req, res) {
        try {
            const id = await this.authService.registerUser(req.body);
            res.status(201).json({ message: "Usuário criado", userId: id });
        } catch (e) { res.status(400).json({ error: e.message }); }
    }

    async login(req, res) {
        try {
            const result = await this.authService.login(req.body.email, req.body.password);
            res.json(result);
        } catch (e) { res.status(401).json({ error: e.message }); }
    }

    async getMe(req, res) {
        // Assume-se que o middleware de token já rodou e populou req.userId
        try {
            const user = await this.authService.getUserById(req.userId);
            res.json(user);
        } catch (e) { res.status(500).json({ error: e.message }); }
    }
    
    // REQ 01
    async updateUser(req, res) {
        try {
            await this.authService.updateUser(req.params.id, req.body);
            res.json({ message: "Atualizado" });
        } catch(e) { res.status(500).json({ error: e.message }); }
    }
    
    async deleteUser(req, res) {
        try {
            await this.authService.deleteUser(req.params.id);
            res.json({ message: "Removido" });
        } catch(e) { res.status(500).json({ error: e.message }); }
    }
}
module.exports = AuthController;