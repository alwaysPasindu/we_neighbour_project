const mongoose = require('mongoose');

const SafetySchema = new mongoose.Schema({
    title: { type: String, required: true },
    description: { type: String, required: true },
    createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'Manager', required: true },
    createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('SafetyAlerts', SafetySchema);