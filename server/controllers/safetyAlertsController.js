const SafetyAlerts = require('../models/SafetyAlerts');

// Create Safety alerts
exports.createSafetyAlert = async (req, res) => {
    try {
        const { title, description } = req.body;
        if (!title || !description) {
            return res.status(400).json({ message: 'Title and description are required' });
        }

        const safetyAlert = new SafetyAlerts({
            title,
            description,
            createdBy: req.user.id,
        });
        await safetyAlert.save();
        res.status(201).json({ message: "Safety Alert Created successfully!" });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Server Error" });
    }
};

// Display safety alerts
exports.getSafetyAlerts = async (req, res) => {
    try {
        const safetyAlerts = await SafetyAlerts.find()
            .sort({ createdAt: -1 })
            .populate('createdBy', 'name');
        res.json(safetyAlerts);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Server Error" });
    }
};

// Delete safety alert
exports.deleteSafetyAlert = async (req, res) => {
    try {
        const { id } = req.params;
        if (!id) {
            return res.status(400).json({ message: 'Safety alert ID is required' });
        }

        const safetyAlert = await SafetyAlerts.findByIdAndDelete(id);
        if (!safetyAlert) {
            return res.status(404).json({ message: 'Safety alert not found' });
        }

        res.json({ message: "Safety Alert deleted successfully!" });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Server Error" });
    }
};