class UserRepository {
    constructor(db) { this.db = db; }

    create(user) {
        return new Promise((resolve, reject) => {
            this.db.run('INSERT INTO users (name, email, password, coins) VALUES (?,?,?,?)', 
                [user.name, user.email, user.password, user.coins], 
                function(err) { if (err) reject(err); else resolve(this.lastID); }
            );
        });
    }

    findByEmail(email) {
        return new Promise((resolve, reject) => {
            this.db.get('SELECT * FROM users WHERE email = ?', [email], (err, row) => {
                if (err) reject(err); else resolve(row);
            });
        });
    }

    findById(id) {
        return new Promise((resolve, reject) => {
            this.db.get('SELECT id, name, email, coins FROM users WHERE id = ?', [id], (err, row) => {
                if (err) reject(err); else resolve(row);
            });
        });
    }

    update(id, data) { // REQ 01 - Alterar
        return new Promise((resolve, reject) => {
            this.db.run('UPDATE users SET name = ?, email = ? WHERE id = ?', 
                [data.name, data.email, id], (err) => {
                    if (err) reject(err); else resolve(true);
            });
        });
    }

    delete(id) { // REQ 01 - Excluir
        return new Promise((resolve, reject) => {
            this.db.run('DELETE FROM users WHERE id = ?', [id], (err) => {
                if (err) reject(err); else resolve(true);
            });
        });
    }
}
module.exports = UserRepository;