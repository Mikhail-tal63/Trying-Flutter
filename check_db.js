const mongoose = require('mongoose');
require('dotenv').config();
const User = require('./src/models/User');

async function checkUsers() {
    await mongoose.connect(process.env.MONGODB_URI);
    const users = await User.find({});
    console.log('Users found:', users);

    // also try to create a dummy user to verify writes
    try {
        const dummy = new User({
            username: 'test_script_user',
            email: 'test_script@example.com',
            password: 'password123'
        });
        // Not saving, just validating
        await dummy.validate();
        console.log('Dummy user validation passed');
    } catch (err) {
        console.error('Validation failed:', err);
    }

    process.exit(0);
}

checkUsers().catch(console.error);
