const ServiceSchema = require('../models/Service');
const ServiceProviderSchema = require('../models/ServiceProvider');
const {centralDB} = require('../config/database');

//create a service
exports.createService = async (req,res) => {
    try{
        const{title,description,images,location,availableHours} = req.body;
        const serviceProviderId = req.user.id;

        const Service = centralDB.model('Service', ServiceSchema);
        const ServiceProvider = centralDB.model('ServiceProvider',ServiceProviderSchema);

        const serviceProvider = await ServiceProvider.findById(serviceProviderId);

        const service = new Service({
            title,
            description,
            images,
            location:{
                type:'Point',
                coordinates: location.coordinates,
            },
            availableHours,
            serviceProvider:serviceProviderId,
            serviceProviderName:serviceProvider.name,
        });
        await service.save();

        res.status(201).json({message:"Service created Successfully"});
    }catch(error){
        console.error(error);
        res.status(500).json({message:"Server Error"});
    }
};

//get all services
exports.getService = async(req,res) => {
    try{
        const{latitude,longitude} = req.query;

        // Validate latitude and longitude
        if (!latitude || !longitude || isNaN(parseFloat(latitude)) || isNaN(parseFloat(longitude))) {
            return res.status(400).json({ message: 'Invalid or missing latitude/longitude' });
        }

        const Service = centralDB.model('Service', ServiceSchema);

        const userLocation ={
            type:'Point',
            coordinates:[parseFloat(longitude),parseFloat(latitude)],
        };
        
        const services = await Service.find({
            location:{
                $near:{
                    $geometry:userLocation,
                    $maxDistance:10000,
                },
            },
        })
        .populate('serviceProvider','name');
        

        res.json(services);
    }catch(error){
        console.error(error);
        res.status(500).json({message:"Server Error"});
        
    }
};

//edit service
exports.editService = async(req,res) => {
    try{
        const{id} = req.params;
        const{title, description,images,location,availableHours} = req.body;
        const serviceProviderId = req.user.id;

        const Service = centralDB.model('Service', ServiceSchema);

        const service = await Service.findById(id);

        if(service.serviceProvider.toString() !== serviceProviderId) {
            return res.status(403).json({message:"You are not authorized"});
        }

        service.title = title || service.title;
        service.description = description || service.description;
        service.images = images || service.images;
        service.location = location || service.location;
        service.availableHours = availableHours || service.availableHours;

        await service.save();
        res.json({message:"Service updated successfully"});
    }catch (error){
        console.error(error);
        res.status(500).json({message:"Server Error"});
    }
};

//Delete a service
exports.deleteService = async(req,res) => {
    try{
        const{id} = req.params;
        const serviceProviderId = req.user.id;

        const Service = centralDB.model('Service',ServiceSchema);

        const service = await Service.findById(id);

        if(service.serviceProvider.toString() !== serviceProviderId){
            return res.status(403).json({message:"You are not authorized"});
        }

        await service.deleteOne();
        res.json({message:"Service deleted successfully"});
    }catch(error){
        console.error(error);
        res.status(500).json({message:"Server Error"});
    }
};