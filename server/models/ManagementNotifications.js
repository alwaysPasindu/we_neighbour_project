const mongoose = require('mongoose');

const ManagementNotificationSchema = new mongoose.Schema({
    title:{type:String, required:true},
    message:{type:String, required:true},
    createdBy:{type: mongoose.Schema.Types.ObjectId, ref:'Manager',required:true},
    createdAt:{type:Date, default:Date.now},
});

module.exports = mongoose.model('ManagementNotification',ManagementNotificationSchema);