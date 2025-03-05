const bcrypt = require('bcrypt');
const {connectDB,centralDB} = require('../config/database');
const ManagerSchema = require('../models/Manager'); 
const ApartmentSchema = require('../models/Apartment');

// Central Manager model (for storing all managers' info)
const CentralManager = centralDB.model('CentralManager', ManagerSchema);


exports.registerManager = async (req, res) => {
    try {
        const { name, nic, email, password, phone, address, apartmentName } = req.body;

        const centralDbConnection = centralDB;
        const Apartment = centralDbConnection.model('Apartment', ApartmentSchema);

        const existingApartment = await Apartment.findOne({ apartmentName });
        if (existingApartment) {
            return res.status(400).json({ message: 'Apartment already exists' });
        }

        const newApartment = new Apartment({ apartmentName });
        await newApartment.save();


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

exports.createApartment = async (req, res) => {
    try {
        const { apartmentName } = req.body;

        // Check if the apartment already exists
        const Apartment = centralDB.model('Apartment', ApartmentSchema);
        const existingApartment = await Apartment.findOne({ apartmentName });
        if (existingApartment) {
            return res.status(400).json({ message: 'Apartment already exists' });
        }

        // Save the new apartment
        const newApartment = new Apartment({ apartmentName });
        await newApartment.save();

        return res.status(201).json({ message: 'Apartment created successfully!' });
    } catch (error) {
        console.error('Error in createApartment:', error);
        return res.status(500).json({ message: 'Server error', error: error.message });
    }
};