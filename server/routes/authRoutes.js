const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const Resident = require ('../models/Resident');
const Manager = require ('../models/Manager');
const ServiceProvider = require ('../models/ServiceProvider');
const router = express.Router();

router.post('/login', async(req,res) => {
    try{
        const {email,password} = req.body;

        let user;
        user = await Resident.findOne({email});
        if(!user){
            user = await Manager.findOne({email});
            if(!user){
                user = await ServiceProvider.findOne({email});
            }
        }

        if(!user){
            return res.status(400).json({message:"Your Email or Password is incorrect"})
        }

        const isMatch = await bcrypt.compare(password, user.password);
        if(!isMatch){
            return res.status(400).json({message: "Your Email or Password is incorrect"});
        }

        const payload = {id:user._id, role:user.role};
        const token = jwt.sign(payload, process.env.JWT_SECRET, {expiresIn:'1h'});

        res.json({
            token,
            user:{
                id: user._id,
                name: user.name,
                email: user.email,
                role: user.role,
            },
        });
        
    }catch(error){
        console.error(error);
        return res.status(500).json({message: "Server Error"});
    }
})

module.exports = router;
