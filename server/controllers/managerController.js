const bcrypt = require('bcrypt');
const connectDB = require('../config/database');
const mongoose = require('mongoose');

exports.registerManager = async (req, res) => {
    try {
        const { name, nic, email, password, phone, address, apartmentName } = req.body;

        // Validate required fields
        if (!name || !nic || !email || !password || !phone || !address || !apartmentName) {
            return res.status(400).json({ message: 'All fields are required' });
        }

        // Connect to the apartment-specific database
        const db = await connectDB(apartmentName);

        // Define the Manager schema dynamically
        const ManagerSchema = new mongoose.Schema({
            name: { type: String, required: true },
            nic: { type: String, required: true },
            email: { type: String, required: true, unique: true },
            password: { type: String, required: true },
            phone: { type: String, required: true },
            address: { type: String, required: true },
            apartmentName: { type: String, required: true },
            role: { type: String, default: 'Manager' },
        }, { timestamps: true });

        // Create a new model for the apartment's database
        const Manager = db.model('Manager', ManagerSchema);

        // Check if the manager already exists
        const existingManager = await Manager.findOne({ email });
        if (existingManager) {
            return res.status(400).json({ message: 'Manager already exists' });
        }

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

        console.log(`Manager registered successfully in database: ${apartmentName}`);
        return res.status(201).json({ message: 'Manager registered successfully!' });
    } catch (error) {
        console.error(error);
        return res.status(500).json({ message: 'Server error' });
    }
};