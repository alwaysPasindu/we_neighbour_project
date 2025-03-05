const mongoose = require('mongoose');

const VisitorSchema = new mongoose.Schema({
    resident:{
        type:mongoose.Schema.Types.ObjectId,
        ref:'Resident',
        required: true,
    },
    residentName:{type:String, required:true},
    apartmentCode: {type:String, required:true},
    numOfVisitors:{type:Number, required:true},
    visitorNames: [{type:String,required:true}],
    phone:{type:String, required:true},
    status:{type:String, enum:['Pending','Confirmed','Rejected'], default:'Pending'},
    createdAt:{type:Date, default:Date.now},
});

module.exports = mongoose.model('Visitor',VisitorSchema);