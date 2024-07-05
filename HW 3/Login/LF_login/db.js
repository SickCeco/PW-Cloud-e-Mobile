const mongoose = require('mongoose');
mongoose.Promise = global.Promise;
let isConnected;

require('dotenv').config({ path: './variables.env' });

const connectToMongoDB = () => {
    if (isConnected) {
        console.log('=> using existing database connection');
        return Promise.resolve();
    }

    console.log('=> using new database connection');
    return mongoose.connect(process.env.DB, {
        dbName: 'unibg_tedx_2024',
        useNewUrlParser: true,
        useUnifiedTopology: true
    }).then(db => {
        isConnected = db.connections[0].readyState;
    }).catch(error => {
        console.error('Error connecting to database:', error);
        throw new Error('Database connection failed');
    });
};

module.exports = connectToMongoDB;
