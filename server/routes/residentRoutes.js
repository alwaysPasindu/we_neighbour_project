const express = require('express');
const Resident = require('../models/Resident');
const router = express.Router();
const bcrypt = require('bcrypt');



router.post('/register',async(req,res) =>{
    try{
        const{name,email,password,phone} = req.body;

        if(!name||!email||!password){
            return res.status(400).json({message:"Please provide all required fields."})
        }
        const hashedPassword = await bcrypt.hash(password,10);
        const newResident = new Resident({name,email,password:hashedPassword,phone});
        await newResident.save();

        return res.status(201).json({message:"Resident registered successfully..!"});

    }catch(error){
        console.error(error);
        return res.status(500).json({message:"server Error"});
    
    }
});

module.exports = router;