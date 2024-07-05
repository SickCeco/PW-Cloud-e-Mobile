const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
    username: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    nome: { type: String, required: true },
    cognome: { type: String, required: true },
    email: { type: String, required: true, unique: true }
}, { collection: 'tedx_user' });

userSchema.methods.comparePassword = function(password) {
    // Confronta le password direttamente (sconsigliato in produzione)
    return this.password === password;
};

module.exports = mongoose.model('User', userSchema);
