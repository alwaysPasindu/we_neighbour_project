const mongoose = require('mongoose');

const ResidentSchema = new mongoose.Schema({
    name:{type:String, required:true},
    nic:{type:String, required:true},
    email:{type:String, required:true, unique:true},
    phone:{type:String,required:true},
    address:{type:String,required:true},
    apartmentName:{type:String,required:true}, 
    password:{type:String, required:true},
    phone:{type:String,required:true},

});

module.exports = mongoose.model('Resident', ResidentSchema);