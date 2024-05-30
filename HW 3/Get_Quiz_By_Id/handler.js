const connectToMongoDB = require('./db');
const Talk = require('./Talk');
const Quiz = require('./Quiz'); 
const axios = require('axios');
const mongoose = require('mongoose');

module.exports.generate_questions = (event, context, callback) => {
    context.callbackWaitsForEmptyEventLoop = false;
    console.log('Received event:', JSON.stringify(event, null, 2));
    let body = {}
    if (event.body) {
        body = JSON.parse(event.body)
    }
    // set default
    if (!body.id) {
        callback(null, {
            statusCode: 500,
            headers: { 'Content-Type': 'text/plain' },
            body: 'Could not fetch the talks. Tag is null.'
        });
        return;
    }

    if (!body.doc_per_page) {
        body.doc_per_page = 10;
    }
    if (!body.page) {
        body.page = 1;
    }

    connectToMongoDB().then(() => {
        console.log('=> connected to database');

        Talk.findOne({ id_ref: body.id }, { transcript: 1, tags: 1, id_ref: 1 })
        .then(talk => {
            if (!talk) {
                callback(null, {
                    statusCode: 404,
                    headers: { 'Content-Type': 'text/plain' },
                    body: 'Talk not found'
                });
                return;
            }

            const transcript = talk.transcript;
            const tags = talk.tags;
            const id_ref = talk.id_ref;

            // Prepare payload for the API request
            const payload = {
                topic: tags,
                content: transcript,
                quesType: '1',
                quesCount: '20'  
            };

            // Prepare headers for the API request
            const headers = {
                clientId: '741195bbd0324c1327e31a05c71a252d522c3038',
                clientSecret: 'ZjKidlQqHWQugiqYhxBm4rCI0ybkuhlS_jg8Hwxd'
            };

            // Make the API request
            const querystring = require('querystring');
            const formData = querystring.stringify(payload);

            axios.post('https://api.prepai.io/generateQuestionsApi', formData, { headers })
                .then(response => {
                    const questions = response.data.response;

                    // Create quiz documents for each question
                    const quizPromises = questions.map(q => {
                        return new Quiz({
                            talk_ref_id: id_ref, 
                            question_id: q.question_id,
                            content_id: q.content_id,
                            topic: q.topic,
                            category_type: q.category_type,
                            question: q.question,
                            options: q.options,
                            pro_tips: q.pro_tips
                        }).save();
                    });

                    // Save all quizzes to the database
                    Promise.all(quizPromises)
                        .then(savedQuizzes => {
                            callback(null, {
                                statusCode: 200,
                                body: JSON.stringify({
                                    message: 'Quizzes saved successfully',
                                    quizzes: savedQuizzes
                                })
                            });
                        })
                        .catch(err => {
                            console.error(err);
                            callback(null, {
                                statusCode: 500,
                                headers: { 'Content-Type': 'text/plain' },
                                body: 'Error saving quizzes: ' + err.message
                            });
                        });

                })
                .catch(error => {
                    console.error(error);
                    callback(null, {
                        statusCode: 500,
                        headers: { 'Content-Type': 'text/plain' },
                        body: 'Error in API request: ' + error.message
                    });
                });

        }).catch(err => {
            console.error(err);
            callback(null, {
                statusCode: 500,
                headers: { 'Content-Type': 'text/plain' },
                body: 'Error fetching talk: ' + err.message
            });
        });
    }).catch(err => {
        console.error(err);
        callback(null, {
            statusCode: 500,
            headers: { 'Content-Type': 'text/plain' },
            body: 'Error connecting to database: ' + err.message
        });
    });
};
