const Complaint = require('../models/Complaint');
const Resident = require('../models/Resident');

//create a complaint
exports.createComplaint = async(req,res) => {
    try{
        const{title, description} = req.body;
        const residentId = req.user.id;

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
        const complaint = await Complaint.find().sort({createdAt:-1}).populate('resident','name'); 
        res.json(complaint);
    }catch(error){
        console.error(error);
        res.status(500).json({message:"Server Error"});
    }
};