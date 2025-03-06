const { centralDB } = require('../config/database');
const ApartmentSchema = require('../models/Apartment');

exports.getAllApartments = async (req, res) => {
    try {
        // Connect to the central database
        const Apartment = centralDB.model('Apartment', ApartmentSchema);

        // Fetch all apartments
        const apartments = await Apartment.find({}, 'apartmentName');

        // Extract apartment names
        const apartmentNames = apartments.map(apartment => apartment.apartmentName);

        return res.status(200).json({ apartmentNames });
    } catch (error) {
        console.error('Error in getAllApartments:', error);
        return res.status(500).json({ message: 'Server error', error: error.message });
    }
};