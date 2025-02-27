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


