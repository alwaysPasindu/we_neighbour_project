const SafetySchema = require('../models/SafetyAlerts'); // Ensure this file exists
const { connectDB } = require('../config/database');

// Get All Safety Alerts
exports.getSafetyAlerts = async (req, res) => {
  try {
    const apartmentComplexName = req.user.apartmentComplexName;

    const db = await connectDB(apartmentComplexName);
    const SafetyAlert = db.model('SafetyAlert', SafetySchema);

    const alerts = await SafetyAlert.find()
      .sort({ createdAt: -1 })
      .populate('createdBy', 'name');

    res.json(alerts);
  } catch (error) {
    console.error('Error fetching safety alerts:', error);
    res.status(500).json({ message: 'Server Error', error: error.message });
  }
};

// Create Safety Alert
exports.createSafetyAlert = async (req, res) => {
  try {
    const { title, description } = req.body;
    const apartmentComplexName = req.user.apartmentComplexName;

    if (!title || !description) {
      return res.status(400).json({ message: 'Title and description are required' });
    }

    const db = await connectDB(apartmentComplexName);
    const SafetyAlert = db.model('SafetyAlert', SafetySchema);

    const alert = new SafetyAlert({
      title,
      description,
      createdBy: req.user.id,
    });
    await alert.save();
    res.status(201).json({ message: 'Safety Alert created successfully!' });
  } catch (error) {
    console.error('Error creating safety alert:', error);
    res.status(500).json({ message: 'Server Error', error: error.message });
  }
};

// Delete Safety Alert
exports.deleteSafetyAlert = async (req, res) => {
  try {
    const { id } = req.params;
    const apartmentComplexName = req.user.apartmentComplexName;

    const db = await connectDB(apartmentComplexName);
    const SafetyAlert = db.model('SafetyAlert', SafetySchema);

    const alert = await SafetyAlert.findById(id);
    if (!alert) {
      return res.status(404).json({ message: 'Alert not found' });
    }

    await SafetyAlert.findByIdAndDelete(id);
    res.json({ message: 'Safety Alert deleted successfully!' });
  } catch (error) {
    console.error('Error deleting safety alert:', error);
    res.status(500).json({ message: 'Server Error', error: error.message });
  }
};