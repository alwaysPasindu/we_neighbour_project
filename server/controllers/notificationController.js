const ManagementNotification = require('../models/ManagementNotifications');
const CommunityNotification = require('../models/CommunityNotification');

//create Management notifications
exports.createManagementNotification = async(req,res) => {
    try{
        const{title,message} = req.body;
        const notification = new ManagementNotification({
            title,
            message,
            createBy: req.user.id,
        });
        await notification.save();
        res.status(201).json({message:"Management Notification created successfully!"});
    }catch(error){
        console.error(error);
        res.status(500).json({message:"Server Error"});
    }
};

//Display all management Notifications
exports.getManagementNotifications = async(req,res) => {
    try{
        const notifications = await ManagementNotification.find().sort({createdAt:-1}).populate('createdBy','name');
        res.json(notifications);
    }catch(error){
        console.error(error);
        res.status(500).json({message:"Server Error"});
    }
};

//remove management notifications
exports.removeManagementNotification = async (req,res) =>{
    try{
        const{id} = req.params;
        await ManagementNotification.findByIdAndDelete(id);
        res.json({message:"Management notification removed successfully!"});
    }catch(error){
        console.error(error);
        res.status(500).json({message: "Server Error"});
    }

};