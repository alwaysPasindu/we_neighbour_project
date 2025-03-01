const Service = require('../models/Service');
const ServiceProvider = require('../models/ServiceProvider');

//create a service
exports.createService = async (req,res) => {
    try{
        const{title,description,images,location,availableHours} = req.body;
        const serviceProviderId = req.user.id;

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
        const services = await Service.find().sort({createdAt:-1}).populate('serviceProvider', 'name');

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