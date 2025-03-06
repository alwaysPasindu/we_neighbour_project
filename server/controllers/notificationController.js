const ManagementNotificationSchema = require('../models/ManagementNotifications');
const CommunityNotificationSchema = require('../models/CommunityNotification');
const {connectDB} = require('../config/database');
const ResidentSchema = require('../models/Resident');
const ManagerSchema = require('../models/Manager');

//create Management notifications
exports.createManagementNotification = async(req,res) => {
    try{
        const{title,message} = req.body;
        const apartmentComplexName = req.user.apartmentComplexName;

        const db = await connectDB(apartmentComplexName);
        const ManagementNotification = db.model('ManagementNotification',ManagementNotificationSchema);

        const notification = new ManagementNotification({
            title,
            message,
            createdBy: req.user.id,
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
        const apartmentComplexName = req.user.apartmentComplexName

        const db = await connectDB(apartmentComplexName);
        const ManagementNotification = db.model('ManagementNotification',ManagementNotificationSchema);

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
        const apartmentComplexName = req.user.apartmentComplexName;

        const db = await connectDB(apartmentComplexName);
        const ManagementNotification = db.model('ManagementNotification',ManagementNotificationSchema);

        await ManagementNotification.findByIdAndDelete(id);
        res.json({message:"Management notification removed successfully!"});
    }catch(error){
        console.error(error);
        res.status(500).json({message: "Server Error"});
    }

};

//create a community notification
exports.createCommunityNotification = async(req,res) => {
    try{
        const{title,message} = req.body;
        const apartmentComplexName = req.user.apartmentComplexName;

        const db = await connectDB(apartmentComplexName);
        const CommunityNotification = db.model('CommunityNotification', CommunityNotificationSchema);


        const notification = new CommunityNotification({
            title,
            message,
            createdBy: req.user.id,

        })
        await notification.save();
        res.status(201).json({messsage:"Community Notification Created successfully!"});
    }catch(error){
        console.error(error);
        res.status(500).json({message:"Server Error"});
    }

};

//display community notifications
exports.getAllCommunityNotifications = async(req,res) => {
    try{
        const userId = req.user.id;
        const apartmentComplexName = req.user.apartmentComplexName;

        const db = await connectDB(apartmentComplexName);
        const CommunityNotification = db.model('CommunityNotification',CommunityNotificationSchema);

        //const notifications = await CommunityNotification.find().sort({createdAt:-1}).populate('createdBy','name');
        
        const notifications = await CommunityNotification.find({
            removedFor: { $nin: [userId] }, 
          })
            .sort({ createdAt: -1 }) 
            .populate('createdBy', 'name'); 
      
          res.json(notifications);
        
        res.json(notifications);
    }catch(error){
        console.error(error);
        res.status(500).json({message:"Server Error"});
    }
};

//remove a community notification - remove from manager
exports.removeCommunityNotificationByManager = async(req,res) => {
    try{
        const{id} = req.params;
        const apartmentComplexName = req.user.apartmentComplexName;

        const db = await connectDB(apartmentComplexName);
        const CommunityNotification = db.model('CommunityNotification', CommunityNotificationSchema);

        await  CommunityNotification.findByIdAndDelete(id);
        res.json({message:"Community Notification removed successfully!"});
    }catch(error){
        console.error(error);
        res.status(500).json({message:"Server Error"});
    }
};

//delete community notification from created resident
exports.deleteCommunityNotification = async(req,res) => {
    try{
        const{id} = req.params;
        const apartmentComplexName = req.user.apartmentComplexName;
        const userId = req.user.id;

        const db = await connectDB(apartmentComplexName);
        const CommunityNotification = db.model('CommunityNotification', CommunityNotificationSchema);

        const notification = await CommunityNotification.findById(id);

        if (notification.createdBy.toString() !== userId) {
            return res.status(403).json({ message: "You are not authorized to delete this notification" });
        }

        await CommunityNotification.findByIdAndDelete(id);
        res.json({ message: "Notification deleted successfully!" });
    }catch (error) {
        console.error(error);
        res.status(500).json({ message: "Server Error" });
    }
    
};

//remove notification when swipe - only current user
exports.removeCommunityNotificationsFromUser = async(req,res) => {
    try{
        const{id} = req.params;
        const userId = req.user.id;
        const apartmentComplexName = req.user.apartmentComplexName;

        const db = await connectDB(apartmentComplexName);
        const CommunityNotification = db.model('CommunityNotification',CommunityNotificationSchema);

        const notification = await CommunityNotification.findById(id);
        
        if (!notification.removedFor.includes(userId)) {
            notification.removedFor.push(userId);
            await notification.save();
        }

        res.json({ message: "Notification removed for current user" });
    }catch(error){
        console.error(error);
        res.status(500).json({message:"Server Error"});
    }
};

//edit community notifications
exports.editCommunityNotification = async(req,res) => {
    try{
        const{id} = req.params;
        const{title,message} = req.body;
        const userId = req.user.id;
        const apartmentComplexName = req.user.apartmentComplexName;

        const db = await connectDB(apartmentComplexName);
        const CommunityNotification = db.model('CommunityNotification',CommunityNotificationSchema);

        const notification = await CommunityNotification.findById(id);


        if(notification.createdBy.toString() !== userId){
            return res.status(403).json({message:"You are not authorized to edit this notification"});
        }

        notification.title = title || notification.title;
        notification.message = message || notification.message;
        await notification.save();

        res.json({message:"Notification updated successfully!", notification});
    } catch (error){
        console.error(error);
        res.status(500).json ({message:"Server Error"});
    }
};