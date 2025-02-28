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
        const request = await Maintenance.findById(id);

        request.status = 'Done';
        await request.save();

        res.json({message:"Maintenance request marked as done"});
    }catch(error){
        console.error(error);
        res.status(500).json({message:"Server Error"});
    }
}

//display marked maintenance requests
exports.getCompletedRequests = async(req,res) => {
    try{
        const request = await Maintenance.find({status:'Done'}).sort({createdAt:-1}).select('-residentName -apartmentCode').populate('ratings.resident','name');

        const requestsWithAverageRatings = request.map((request) => {
            const totalStars = request.ratings.reduce((sum, rating) => sum + rating.stars, 0);
            const numberOfRatings = request.ratings.length;
            const averageRating = numberOfRatings > 0 ? totalStars / numberOfRatings : 0;

            return{
                ...request.toObject(),
                averageRating: parseFloat(averageRating.toFixed(2)),
            };
        });
        res.json(requestsWithAverageRatings);
    }catch(error){
        console.error(error);
        res.status(500).json({message:"Server Error"});
    }
}

//maintenance rating
exports.rateMaintenanceRequest = async(req,res) => {
    try{
        const{id} = req.params;
        const{stars} = req.body;
        const residentId = req.user.id;
        const request = await Maintenance.findById(id);
        const existingRatings = request.ratings.find(
            (rating) => rating.resident.toString() === residentId
        );

        if(existingRatings) {
            return res.status(400).json({message:"You have already rated this request"});
        }

        

        request.ratings.push({resident:residentId, stars});
        await request.save();

        res.json({message:"Rating added successfully"});
    }catch(error){
        console.error(error);
        res.status(500).json({message:"Server Error"});
    }
};