const mongoose = require('mongoose');

const ServiceSchema = new mongoose.Schema({
    name: {type:String, required:true},
    email: {type:String, required:true, unique:true},
    serviceType: {type:String, required:true},
    phone: {type:String, required:true},
    password: {type:String, required: true},
    role:{type:String, default:'ServiceProvider'},
},{timestamps:true});

module.exports = mongoose.model('ServiceProvider',ServiceSchema);