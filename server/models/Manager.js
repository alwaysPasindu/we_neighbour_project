const mongoose = require('mongoose');

const ManagerSchema = new mongoose.Schema({
    name:{type:String, required:true},
    nic:{type:String, required:true},
    email:{type:String, required:true, unique:true},
    phone:{type:String,required:true},
    address:{type:String,required:true},
    apartmentName:{type:String,required:true}, 
    password:{type:String, required:true},
    role:{type:String, default:'Manager'},
    
},{timestamps:true});

module.exports = mongoose.model('Manager', ManagerSchema);