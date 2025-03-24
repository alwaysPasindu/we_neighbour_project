const ResidentSchema = require('../models/Resident');
const ManagerSchema = require('../models/Manager');
const { connectDB } = require('../config/database');
const { syncUserToFirebase } = require('../utils/firebaseSync');
const { db: firestoreDB } = require('../config/firebase');

const bcrypt = require('bcrypt');

exports.registerResident = async (req, res) => {
  try {
            const { name,nic,email,password,phone,address,apartmentComplexName,apartmentCode } = req.body;
            
            // Connect to the apartment-specific database
            const db = await connectDB(apartmentComplexName);

            // Create a model for the apartment's database
            const Resident = db.model('Resident', ResidentSchema);

            const existingResident = await Resident.findOne({ email });
            
            if (existingResident) {
                return res.status(400).json({ message: 'Resident already exists' });
            }

            const hashedPassword = await bcrypt.hash(password, 10);
            const newResident = new Resident({name,nic,email,password:hashedPassword,phone,address,apartmentComplexName,apartmentCode});
            await newResident.save();

            console.log(`Resident registered successfully in database: ${apartmentComplexName}`);
            res.status(201).json({ message: "Resident registered successfully..! - Waiting for Manager approval" });
        } catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server Error" });
        }
};

exports.getPendingRequests = async(req,res) => {
    try{
        const{apartmentComplexName} = req.user;

        const db = await connectDB(apartmentComplexName);

        const Resident = db.model('Resident', ResidentSchema);

        const pendingRessidents= await Resident.find({status:'pending'});

        return res.status(200).json({pendingRessidents});
    }catch(error){
        console.error(error);
        return res.status(500).json({message:"Server error"});
    }
};

exports.approveResident = async (req, res) => {
    try {
        const { residentId, status } = req.body;

        // Validate input
        if (!residentId || !['approved', 'rejected'].includes(status)) {
            return res.status(400).json({ message: 'Invalid input' });
        }

        // Connect to the apartment-specific database
        const db = await connectDB(req.user.apartmentComplexName); // Assuming manager's apartment name is in req.user

        // Create a model for the apartment's database
        const Resident = db.model('Resident', ResidentSchema);

        // Find the resident by ID
        const resident = await Resident.findById(residentId);
        if (!resident) {
            return res.status(404).json({ message: 'Resident not found' });
        }

        // Update the resident's status
        resident.status = status;
        await resident.save();

        if (status === 'approved') {
          await syncUserToFirebase(resident, req.user.apartmentComplexName);
        }

        console.log(`Resident ${residentId} status updated to: ${status}`);
        return res.status(200).json({ message: `Resident request ${status}` });
    } catch (error) {
        console.error('Error in approveResident:', error);
        return res.status(500).json({ message: 'Server error', error: error.message });
    }
};

// Get all residents in the same apartment (for chat system)
exports.getResidentsForChat = async (req, res) => {
    try {
      const userId = req.user.id; // From authMiddleware
      
 //
      const apartmentComplexName = req.user.apartmentComplexName;
      const db = await connectDB(apartmentComplexName);

      const Resident = db.model('Resident', ResidentSchema);
//
      const currentResident = await Resident.findById(userId);
      if (!currentResident) {
        return res.status(404).json({ message: 'Resident not found' });
      }
 //     //const apartmentComplexName = currentResident.apartmentComplexName;
  
      // Fetch residents from same apartment (MongoDB)
      const residents = await Resident.find({
        apartmentComplexName,
        _id: { $ne: userId }, // Exclude self
      }).select('_id name apartmentComplexName');
  
      // Sync with Firestore (ensure users collection matches)
      const firestoreUsers = firestoreDB.collection('users');
      for (const resident of residents) {
        await firestoreUsers.doc(resident._id.toString()).set(
          {
            uid: resident._id.toString(),
            name: resident.name,
            apartmentId: resident.apartmentComplexName,
          },
          { merge: true }
        );
      }
  
      res.status(200).json(residents);
    } catch (error) {
      console.error('Error fetching residents for chat:', error);
      res.status(500).json({ message: 'Server error' });
    }
  };