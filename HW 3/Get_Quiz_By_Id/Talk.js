const mongoose = require('mongoose');

const talk_schema = new mongoose.Schema({
    id_ref: String,
    title: String,
    url: String,
    description: String,
    speakers: String,
    transcript: String,
    tags: [String] // Definisco tags come un array di stringhe
}, { collection: 'tedx_data' });

module.exports = mongoose.model('talk', talk_schema);
