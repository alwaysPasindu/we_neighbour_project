const SafetyAlerts = require('../models/SafetyAlerts');

//Create Safety alerts
exports.createSafetyAlerts = async(req,res) => {
    try{
        const{title, description} = req.body;
        const safetyAlerts = new SafetyAlerts({
            title,
            description,
            createdBy: req.userid,
        });
        await safetyAlerts.save();
        res.status(201).json({message:"Safety  Alert Created successfully!"});
    }catch(error){
        console.error(error);
        res.status(500).json({message:"Server Error"});
    }
};

