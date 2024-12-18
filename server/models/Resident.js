const mongoose = require('mongoose');

const ResidentSchema = new mongoose.Schema({
    name:{type:String, required:true},
    email:{type:String, required:true, unique:true},
    password: {type:String, required:true},
    phone:{type:String},

});

module.exports = mongoose.model('Resident', ResidentSchema);