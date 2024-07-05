const connectToMongoDB = require('./db');
const User = require('./User');
require('dotenv').config();

const connectToDatabase = async () => {
    await connectToMongoDB();
};

module.exports.handleLogin = async (event, context, callback) => {
    context.callbackWaitsForEmptyEventLoop = false;
    console.log('Received event:', JSON.stringify(event, null, 2));

    await connectToDatabase();

    let body = {};
    if (event.body) {
        body = JSON.parse(event.body);
    }

    try {
        if (!body.username || !body.password) {
            return callback(null, {
                statusCode: 400,
                body: JSON.stringify({ message: 'Username and password are required' }),
            });
        }

        const user = await User.findOne({ username: body.username });

        if (!user) {
            return callback(null, {
                statusCode: 404,
                body: JSON.stringify({ message: 'User not found' }),
            });
        }

        const isPasswordValid = await user.comparePassword(body.password);

        if (!isPasswordValid) {
            return callback(null, {
                statusCode: 401,
                body: JSON.stringify({ message: 'Incorrect password' }),
            });
        }

        // Se il login è riuscito, restituisci i dati dell'utente
        return callback(null, {
            statusCode: 200,
            body: JSON.stringify({
                message: 'Login successful',
                user: {
                    username: user.username,
                    nome: user.nome,
                    cognome: user.cognome,
                    email: user.email
                }
            }),
        });
    } catch (error) {
        console.error('Error:', error);
        return callback(null, {
            statusCode: 500,
            body: JSON.stringify({ message: 'Internal server error' }),
        });
    }
};
