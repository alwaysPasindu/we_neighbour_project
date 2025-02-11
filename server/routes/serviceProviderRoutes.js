const express = require('express');
const ServiceProvider = require('../models/ServiceProvider');
const router = express.Router();
const bcrypt = require('bcrypt');

router.post('/register', async(req,res) => {    
    try{
        const{name,email,serviceType,phone,password} = req.body;
        
        if(!name||!email||!password){
            return res.status(400).json({message:"Please provide all required fields."})
        }

        const hashedPassword = await bcrypt.hash(password,10);
        const newServiceProvider = new ServiceProvider({name,email,serviceType,phone,password:hashedPassword});
        await newServiceProvider.save();

        return res.status(201).json({message: "Service Provider registerd successfully..!"});
    
    }catch (error) {
        console.error(error);
        return res.status(500).json({message: "Server error"});

    }

});

module.exports = router;
