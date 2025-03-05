const ResidentSchema = require('../models/Resident');
const { connectDB } = require('../config/database');
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
}