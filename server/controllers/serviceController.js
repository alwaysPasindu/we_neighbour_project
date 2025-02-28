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
        await newService.save();

        res.status(201).json({message:"Service created Successfully"});
    }catch(error){
        console.error(error);
        res.status(500).json({message:"Server Error"});
    }
};