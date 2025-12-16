class GameRepository {
    constructor(db) { this.db = db; }

    createTeam(team) { // REQ 03
        return new Promise((resolve, reject) => {
            this.db.run('INSERT INTO teams (name, league, logoUrl) VALUES (?,?,?)', 
                [team.name, team.league, team.logoUrl], function(err) { if (err) reject(err); else resolve(this.lastID); });
        });
    }

    createQuestion(q) { // REQ 04
        return new Promise((resolve, reject) => {
            this.db.run('INSERT INTO questions (question, options, correct_index) VALUES (?,?,?)',
                [q.question, JSON.stringify(q.options), q.correctIndex], function(err) { if(err) reject(err); else resolve(this.lastID); });
        });
    }

    getQuizzes() { // REQ 06
        return new Promise((resolve, reject) => {
            this.db.all("SELECT * FROM quizzes", [], (err, rows) => { if(err) reject(err); else resolve(rows); });
        });
    }

    saveResult(r) { // REQ 07
        return new Promise((resolve, reject) => {
            this.db.run('INSERT INTO results (user_id, user_name, score, time_taken, date) VALUES (?,?,?,?,?)',
                [r.userId, r.userName, r.score, r.timeTaken, new Date().toISOString()], function(err) { if(err) reject(err); else resolve(this.lastID); });
        });
    }

    saveTransaction(t) { // REQ 16 (Auxiliar)
        this.db.run('INSERT INTO transactions (title, value, type, date) VALUES (?, ?, ?, ?)', [t.title, t.value, t.type, t.date]);
    }

    getGeneralRanking() { // REQ 14
        return new Promise((resolve, reject) => {
            this.db.all('SELECT user_name, SUM(score) as total_score FROM results GROUP BY user_id ORDER BY total_score DESC', [], (err, rows) => { if(err) reject(err); else resolve(rows); });
        });
    }

    getFastestPlayer() { // REQ 13
        return new Promise((resolve, reject) => {
            this.db.get('SELECT * FROM results ORDER BY score DESC, time_taken ASC LIMIT 1', [], (err, row) => { if(err) reject(err); else resolve(row); });
        });
    }

    getTransactions() { // REQ 16
        return new Promise((resolve, reject) => {
            this.db.all('SELECT * FROM transactions ORDER BY id DESC', [], (err, rows) => { if(err) reject(err); else resolve(rows); });
        });
    }

    saveInvite(email) { // REQ 11
        return new Promise((resolve, reject) => {
            this.db.run('INSERT INTO invites (email, status) VALUES (?, "sent")', [email], function(err) { if(err) reject(err); else resolve(this.lastID); });
        });
    }
}
module.exports = GameRepository;