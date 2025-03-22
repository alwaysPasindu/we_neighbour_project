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

// Approve or reject a manager request (Admin-only)
exports.approveManager = async (req, res) => {
    try {
        const { managerId, status } = req.body;

        // Validate input
        if (!managerId || !['approved', 'rejected'].includes(status)) {
            return res.status(400).json({ message: 'Invalid input' });
        }

        // Find the manager in the central database
        const manager = await CentralManager.findById(managerId);
        if (!manager) {
            return res.status(404).json({ message: 'Manager not found' });
        }

        // Update the manager's status in the central database
        manager.status = status;
        await manager.save();

        // If approved, save the manager to the apartment-specific database
        if (status === 'approved') {
            const db = await connectDB(manager.apartmentName);
            const Manager = db.model('Manager', ManagerSchema);

            // Check if the manager already exists in the apartment-specific database
            const existingManager = await Manager.findOne({ email: manager.email });
            if (existingManager) {
                return res.status(400).json({ message: 'Manager already exists in the apartment database' });
            }

            // Save the manager to the apartment-specific database
            const newManager = new Manager({
                name: manager.name,
                nic: manager.nic,
                email: manager.email,
                password: manager.password,
                phone: manager.phone,
                address: manager.address,
                apartmentName: manager.apartmentName,
                status: 'approved', // Set status to approved
            });
            await newManager.save();

            await syncUserToFirebase(newManager, manager.apartmentName);
        }

        console.log(`Manager ${managerId} status updated to: ${status}`);
        return res.status(200).json({ message: `Manager request ${status}` });
    } catch (error) {
        console.error('Error in approveManager:', error);
        return res.status(500).json({ message: 'Server error', error: error.message });
    }
};