const Resident = require('../models/Resident');
const bcrypt = require('bcrypt');

exports.registerResident = async (req, res) => {
  try {
            const { name,nic,email,password,phone,apartmentComplexName,apartmentCode } = req.body;
            if (!name || !email || !password) {
            return res.status(400).json({ message: "Please provide all required fields." });
            }

            const hashedPassword = await bcrypt.hash(password, 10);
            const newResident = new Resident({name,nic,email,password:hashedPassword,phone,apartmentComplexName,apartmentCode});
            await newResident.save();

            res.status(201).json({ message: "Resident registered successfully!" });
        } catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server Error" });
        }
};