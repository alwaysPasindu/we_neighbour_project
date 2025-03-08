const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const {connectDB, centralDB} = require('../config/database');
const ResidentSchema = require('../models/Resident');
const ManagerSchema = require('../models/Manager');
const ServiceSchema = require('../models/ServiceProvider');
const ApartmentSchema = require('../models/Apartment');

exports.login = async (req, res) => {
  try {
      const { email, password } = req.body;

      // Check the central database for service providers
      const ServiceProvider = centralDB.model('ServiceProvider', ServiceSchema);
      let user = await ServiceProvider.findOne({ email });

        if (!user) {
            // If not found in the central database, check apartment-specific databases for residents and managers
            const Apartment = centralDB.model('Apartment', ApartmentSchema);
            const apartments = await Apartment.find({}, 'apartmentName'); // Fetch all apartment names

            for (const apartment of apartments) {
                const db = await connectDB(apartment.apartmentName);
                console.log(`Connected to database: ${apartment.apartmentName}`);
                const Resident = db.model('Resident', ResidentSchema);
                const Manager = db.model('Manager', ManagerSchema);

                user = await Resident.findOne({ email });
                if (!user) {
                    user = await Manager.findOne({ email });
                }

                if (user) {
                    user.apartmentComplexName = apartment.apartmentName;
                    // If user is found, break the loop
                    break;
                }
            }
        
            if (!user) {
                const CentralManager = centralDB.model('CentralManager', ManagerSchema);
                user = await CentralManager.findOne({ email });

                if (user) {

                    const isMatch = await bcrypt.compare(password, user.password);
                    if (!isMatch) {
                        return res.status(400).json({ message: 'Your Email or Password is incorrect' });
                    }
                    // If the manager is pending, return a specific message
                    if (user.status === 'pending') {
                        return res.status(403).json({ message: 'Your registration request is pending or rejected.' });
                    }
                }
            }
        }

      
      const isMatch = await bcrypt.compare(password, user.password);
      if (!isMatch) {
          return res.status(400).json({ message: 'Your Email or Password is incorrect' });
      }
      

      // For residents, check if they are approved
      if ((user.role === 'Resident' || user.role === 'Manager') && user.status !== 'approved') {
          return res.status(403).json({ message: 'Your registration request is pending or rejected' });
      }

      // Compare passwords
      

      // Generate JWT token
      const payload = {
          id: user._id,
          role: user.role,
          apartmentComplexName: user.apartmentComplexName || null, // Include apartment name if applicable
          status:user.status,
      };
      const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '1h' });

      // Return token and user details
      res.json({
          token,
          user: {
              id: user._id,
              name: user.name,
              email: user.email,
              apartmentComplexName: user.apartmentComplexName || null,
              role: user.role,
              status:user.status,
          },
      });
  } catch (error) {
      console.error('Error in login:', error);
      return res.status(500).json({ message: 'Server error', error: error.message });
  }
};