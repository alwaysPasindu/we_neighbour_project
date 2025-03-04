const mongoose = require('mongoose');

const ApartmentSchema = new mongoose.Schema({
    apartmentName:{type:'String',required:true, unique:true},
    createdAt:{type:Date, default:Date.now},
});

module.exports =  mongoose.model('Apartment',ApartmentSchema);