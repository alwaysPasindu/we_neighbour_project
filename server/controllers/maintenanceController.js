const Maintenance = require('../models/Maintenance');
const Resident = require('../models/Resident');


//Create the maintenance request
exports.createMaintenanceRequest = async(req,res) =>{
    try{
        const {title, description} = req.body;
        const residentId = req.user.id;

        const resident = await Resident.findById(residentId);

        const request = new Maintenance({
            title,
            description,
            resident:residentId,
            residentName:resident.name,
            apartmentcode:resident.apartmentCode,
        });
        await request.save();

        res.status(201).json({message:"Maintenance request sent"});
    }catch(error){
        console.error(error);
        res.status(500).json({message:"Server Error"});
    }
};

//get pending maintenance requests
exports.getPendingrequests = async(req,res) =>{
    try{
        const request = await Maintenance.find({status:'Pending'}).sort({createdAt:-1}).populate('resident','name apartmentCode');

        res.json(request);
    }catch(error){
        console.error(error);
        res.status(500).json({message:"Server Error"});
    }
};

//mark maintenance requests
exports.markRequests = async(req,res) =>{
    try{
        const{id} =req.params;
        const request = Maintenance.findById(id);

        request.status = 'Done';
        await request.save();

        res.json({message:"Maintenance request marked as done"});
    }catch(error){
        console.error(error);
        res.status(500).json({message:"Server Error"});
    }
}
