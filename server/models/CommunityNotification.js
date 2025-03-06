const mongoose = require('mongoose');

const CommunityNotificationSchema = new mongoose.Schema({
    title:{type:String, required: true},
    message:{type:String, required:true},
    createdBy: {type:mongoose.Schema.Types.ObjectId, ref:'Resident', required:true},
    createdAt:{type:Date, default:Date.now},    
    removedFor:[{type:mongoose.Schema.Types.ObjectId, ref:'User'}],    
});

module.exports = CommunityNotificationSchema;