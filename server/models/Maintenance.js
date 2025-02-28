const mongoose = require('mongoose');

const MaintenanceSchema = new mongoose.Schema({
    title:{type:String, required:true},
    description: {type:String, required:true},
    resident:{
        type:mongoose.Schema.Types.ObjectId,
        ref:'Resident',
        required:true,
    },
    residentName: {type:String, required:true},
    apartmentcode: {type:String, required:true},
    status: {type:String, enum:['Pending', 'Done'], default:'Pending'},
    createdAt: {type:Date, default:Date.now},
    ratings: [
        {
            resident: {type: mongoose.Schema.Types.ObjectId, ref:'Resident'},
            stars: {type: Number, min:1, max:5},
        },
    ],
});

module.exports = mongoose.model('Maintenance', MaintenanceSchema);