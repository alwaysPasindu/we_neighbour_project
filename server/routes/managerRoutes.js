const express = require('express');
const Manager = require('../models/Manager');
const router = express.Router();
const bcrypt = require('bcrypt'); 

router.post('/register',async(req,res) =>{
    try{
        const{name,nic,email,password,phone,address,apartmentName} = req.body;

        if(!name||!email||!password){
            return res.status(400).json({message:"Please provide all required fields."})
        }
        const hashedPassword = await bcrypt.hash(password,10);
        const newManager = new Manager({name,nic,email,password:hashedPassword,phone,address,apartmentName});
        await newManager.save();

        return res.status(201).json({message:"Manager registered successfully..!"});

    }catch(error){
        console.error(error);
        return res.status(500).json({message:"server Error"});
    
    }
});

module.exports = router;