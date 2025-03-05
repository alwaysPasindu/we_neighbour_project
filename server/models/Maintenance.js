const mongoose = require('mongoose');

const maintenanceSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: { type: String, required: true },
  status: { type: String, enum: ['Pending', 'Done'], default: 'Pending' },
  resident: { type: mongoose.Schema.Types.ObjectId, ref: 'Resident', required: true },
  residentName: { type: String, required: true },
  apartmentCode: { type: String, required: true }, // Required on creation
  ratings: [{
    resident: { type: mongoose.Schema.Types.ObjectId, ref: 'Resident' },
    stars: { type: Number, min: 1, max: 5, required: true }
  }],
  averageRating: { type: Number, default: 0 },
  createdAt: { type: Date, default: Date.now }
}, {
  // Disable automatic validation on updates for non-required fields like apartmentCode
  runValidators: { update: false }
});

module.exports = mongoose.model('Maintenance', maintenanceSchema);