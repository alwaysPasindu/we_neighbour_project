const ResourceSchema = require('../models/Resource');
const ResidentSchema = require('../models/Resident');
const {connectDB} = require('../config/database');

//create resource request
exports.createResourceRequest = async(req,res) => {
    try{
        
        const {resourceName, description, quantity} = req.body;
        const residentId = req.user.id;
        const apartmentComplexName = req.user.apartmentComplexName;

        const db = await connectDB(apartmentComplexName);
        const Resource = db.model('Resource', ResourceSchema);
        const Resident = db.model('Resident', ResidentSchema);

        const resident = await Resident.findById(residentId);

        const resource = new Resource({
            resourceName,
            description,
            quantity,
            resident:residentId,
            residentName:resident.name,
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
        const apartmentComplexName = req.user.apartmentComplexName;

        const db = await connectDB(apartmentComplexName);
        const Resource = db.model('Resource', ResourceSchema);

        const request = await Resource.find({status:'Active'})
        .sort({createdAt: -1})
        .populate('resident','name apartmentCode');
        
        res.json(request);
    }catch(error){
        console.error(error);
        res.status(500).json({message:"Server Error"});
    }
};

//delete resource request
exports.deleteResourceRequest = async(req,res) =>{
    try{
        const {id} = req.params;
        const userId = req.user.id;
        const apartmentComplexName = req.user.apartmentComplexName;

        const db = await connectDB(apartmentComplexName);
        const Resource = db.model('Resource',ResourceSchema);
        

        const request = await Resource.findById(id);

        request.status = 'Deleted';
        await request.save();

        res.json({message:"Resource request deleted successfully"});
    }catch(error){
        console.error(error);
        res.status(500).json({message:"Server Error"});
    }
};