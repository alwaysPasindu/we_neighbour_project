const mongoose = require('mongoose');

const ComplaintSchema = new mongoose.Schema({
    title:{type:String, required:true},
    description: {type:String, required:true},
    resident: {
        type: mongoose.Schema.Types.ObjectId,
        ref:'Resident',
        required:true,
    },
    apartmentCode: {type:String, required:true},
    createdAt:{type:Date, default: Date.now},
    
});

module.exports = mongoose.model('Complaint', ComplaintSchema);