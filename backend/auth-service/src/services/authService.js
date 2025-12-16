const md5 = require('md5');
const jwt = require('jsonwebtoken');

class AuthService {
    constructor(userRepository) {
        this.userRepo = userRepository;
        this.secret = process.env.JWT_SECRET || 'segredo_padrao_dev';
    }

    async registerUser(data) {
        if (!data.name || !data.email || !data.password) throw new Error("Dados incompletos");
        const passwordHash = md5(data.password);
        return await this.userRepo.create({ ...data, password: passwordHash, coins: 100 });
    }

    async login(email, password) {
        const user = await this.userRepo.findByEmail(email);
        if (!user) throw new Error("Usuário não encontrado");
        if (user.password !== md5(password)) throw new Error("Senha incorreta");

        const token = jwt.sign({ id: user.id, email: user.email }, this.secret, { expiresIn: '1h' });
        return { auth: true, token, name: user.name };
    }

    async getUserById(id) {
        return await this.userRepo.findById(id);
    }
    
    // Métodos para REQ 01
    async updateUser(id, data) { return await this.userRepo.update(id, data); }
    async deleteUser(id) { return await this.userRepo.delete(id); }
}
module.exports = AuthService;