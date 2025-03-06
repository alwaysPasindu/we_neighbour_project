const { connectDB } = require('../config/database');
const ComplaintSchema = require('../models/Complaint');
const ResidentSchema = require('../models/Resident');

//create a complaint
exports.createComplaint = async(req,res) => {
    try{
        const{title, description} = req.body;
        const residentId = req.user.id;
        const apartmentComplexName = req.user.apartmentComplexName;

        const db = await connectDB(apartmentComplexName);
        const Complaint = db.model('Complaint', ComplaintSchema);
        const Resident = db.model('Resident', ResidentSchema);

        const resident = await Resident.findById(residentId);

        const complaint = new Complaint({
            title,
            description,
            resident: residentId,
            apartmentCode: resident.apartmentCode,
        });
        await complaint.save();

        res.status(201).json({message: "Complaint submitted successfully!"});
    }catch(error){
        console.error(error);
        res.status(500).json({message:"Server Error"});
    }
};

//Get all complaints
exports.getComplaints = async(req,res) => {
    try{
        const apartmentComplexName = req.user.apartmentComplexName;

        const db = await connectDB(apartmentComplexName);
        const Complaint = db.model('Complaint', ComplaintSchema);

        const complaint = await Complaint.find().sort({createdAt:-1}).populate('resident','name'); 
        res.json(complaint);
    }catch(error){
        console.error(error);
        res.status(500).json({message:"Server Error"});
    }
};