const mongoose = require('mongoose');

const quizSchema = new mongoose.Schema({
    talk_ref_id: { type: String, required: true },

    question_id: { type: Number, required: true },
    content_id: { type: Number, required: true },
    topic: { type: String, required: true },
    category_type: { type: Number, required: true },
    question: { type: Array, required: true },
    options: { type: Array, required: true },
    pro_tips: { type: String, required: true }
}, { collection: 'tedx_quiz' }); 

module.exports = mongoose.model('Quiz', quizSchema);
