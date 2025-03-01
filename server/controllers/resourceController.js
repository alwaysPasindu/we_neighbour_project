const Resource = require('../models/Resource');
const { findById } = require('../models/Service');

//create resource request
exports.createResourceRequest = async(req,res) => {
    try{
        const{resourceName, description, quantity} = req.body;
        const residentId = req.user.id;

        const resident = await findById(residentId);

        const resource = new Resource({
            resourceName,
            description,
            quantity,
            resident:residentId,
            residentName:resident.residentName,
            apartmentCode:resident.apartmentCode,
        });

        await resource.save();

        res.status(201).json({message:"Resource request cereated successfully"});
    }catch(error){
        console.error(error);
        res.status(500).json({message:"Server Error"});
    }
};

//get resource request
exports.getResourceRequest = async(req,res) =>{
    try{
        const resource = await Resource.find({status:'Active'})
        .sort({createdAt: -1})
        .populate('resident','name apartmentCode');
        
        res.json(request);
    }catch(error){
        console.error(error);
        res.status(500).json({message:"Server Error"});
    }
};