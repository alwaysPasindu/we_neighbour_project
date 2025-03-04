const bcrypt = require('bcrypt');
const connectDB = require('../config/database');
const mongoose = require('mongoose');
const ManagerSchema = require('../models/Manager'); 

// Central database connection (for storing all managers' info)
const centralDB = mongoose.createConnection(process.env.MONGO_URI, {
    dbName: 'central_db', // Central database name
    useNewUrlParser: true,
    useUnifiedTopology: true,
});

// Central Manager model (for storing all managers' info)
const CentralManager = centralDB.model('CentralManager', ManagerSchema);


exports.registerManager = async (req, res) => {
    try {
        const { name, nic, email, password, phone, address, apartmentName } = req.body;

        const existingManager = await CentralManager.findOne({ $or: [{ email }, { nic }] });
        
        if (existingManager) {
            return res.status(400).json({ message: 'Manager already exists' });
        }

        const db = await connectDB(apartmentName);

        const Manager = db.model('Manager', ManagerSchema);

        // Hash the password
        const hashedPassword = await bcrypt.hash(password, 10);

        // Save the new manager
        const newManager = new Manager({
            name,
            nic,
            email,
            password: hashedPassword,
            phone,
            address,
            apartmentName,
        });
        await newManager.save();

        const centralManager = new CentralManager({
            name,
            nic,
            email,
            password: hashedPassword,
            phone,
            address,
            apartmentName,
        });
        await centralManager.save();


        console.log(`Manager registered successfully in database: ${apartmentName}`);
        return res.status(201).json({ message: 'Manager registered successfully!' });
    } catch (error) {
        console.error(error);
        return res.status(500).json({ message: 'Server error' });
    }
};