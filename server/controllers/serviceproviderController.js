const bcrypt = require('bcrypt');
const { centralDB } = require('../config/database');
const ServiceSchema = require('../models/ServiceProvider');

// Create a model for the central database
const ServiceProvider = centralDB.model('ServiceProvider', ServiceSchema);

exports.registerServiceProvider = async (req,res) => {
     try{
            const{name,email,serviceType,phone,password} = req.body;
            
            if(!name||!email||!password){
                return res.status(400).json({message:"Please provide all required fields."})
            }

             // Check if the service provider already exists
            const existingServiceProvider = await ServiceProvider.findOne({ email });
            
            if (existingServiceProvider) {
                return res.status(400).json({ message: 'Service provider already exists' });
            }
    
            const hashedPassword = await bcrypt.hash(password,10);
            const newServiceProvider = new ServiceProvider({name,email,serviceType,phone,password:hashedPassword});
            await newServiceProvider.save();
    
            return res.status(201).json({message: "Service Provider registerd successfully. (Central db)"});
        
        }catch (error) {
            console.error(error);
            return res.status(500).json({message: "Server error"});
    
        }

};