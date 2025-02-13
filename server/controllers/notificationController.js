const ManagementNotification = require('../models/ManagementNotifications');
const CommunityNotification = require('../models/CommunityNotification');
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
exports.getManagementNotification = async(req,res) => {
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

//create a community notification
exports.createCommunityNotifications = async(req,res) => {
    try{
        const{title,message} = req.body;
        const notification = new CommunityNotification({
            title,
            message,
            createBy: req.user.id,

        })
        await notification.save();
        res.status(201).json({messsage:"Community Notification Created successfully!"});
    }catch(error){
        console.error(error);
        res.status(500).json({message:"Server Error"});
    }

}

//display community notifications
exports.getAllCommunityNotifications = async(req,res) => {
    try{
        const notifications = await CommunityNotification.find().sort({createdAt:-1}).populate('createdBy','name');
        res.json(notifications);
    }catch(error){
        console.error(error);
        res.status(500).json({message:"Server Error"});
    }
};