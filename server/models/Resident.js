const mongoose = require('mongoose');

const ResidentSchema = new mongoose.Schema({
    name:{type:String, required:true},
    nic:{type:String, required:true},
    email:{type:String, required:true, unique:true},
    phone:{type:String,required:true},
    address:{type:String,required:true},
    apartmentComplexName:{type:String,required:true}, 
    apartmentCode:{type:String, required:true},
    password:{type:String, required:true},
    role:{type:String, default:'Resident'},
    status:{type:String, enum:['pending','approved','rejected'], default:'pending'},

},{timestamps:true});


module.exports = ResidentSchema;