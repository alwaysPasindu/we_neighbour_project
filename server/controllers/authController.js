const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const Resident = require('../models/Resident');
const Manager = require('../models/Manager');
const ServiceProvider = require('../models/ServiceProvider');

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Check if the user exists in any of the collections
    let user;
    user = await Resident.findOne({ email });
    if (!user) {
      user = await Manager.findOne({ email });
      if (!user) {
        user = await ServiceProvider.findOne({ email });
      }
    }

    if (!user) {
      return res.status(400).json({ message: "Your Email or Password is incorrect" });
    }

    // Compare passwords
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: "Your Email or Password is incorrect" });
    }

    // Generate JWT token
    const payload = { id: user._id, role: user.role };
    const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '1h' });

    // Return token and user details
    res.json({
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
      },
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: "Server Error" });
  }
};