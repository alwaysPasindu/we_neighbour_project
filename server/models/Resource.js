const mongoose = require('mongoose');

const ResourceSchema = new mongoose.Schema({
    resourceName:{type:String, required:true},
    description:{type:String, required:true},
    quantity:{type:String, required:true},
    resident:{
        type:mongoose.Schema.Types.ObjectId,
        ref:'Resident',
        requied:true,
    },
    residentName:{type:String, required:true},
    apartmentCode:{type:String, required:true},
    status:{type:String, enum:['Active','Deleted'],default:'Active'},
    createdAt:{type:Date, default:Date.now},
});

module.exports = mongoose.model('Resource', ResourceSchema);