const mongoose = require('mongoose');

const ServiceSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: { type: String, required: true },
  images: [{ type: String }],
  location: {
    type: {
      type: String,
      enum: ['Point'],
      required: true,
    },
    coordinates: {
      type: [Number],
      required: true,
    },
    address: { type: String, default: 'Unknown Location' },
  },
  availableHours: { type: String, required: true },
  serviceProvider: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'ServiceProvider',
    required: true,
  },
  serviceProviderName: { type: String, required: true },
  createdAt: { type: Date, default: Date.now },
  reviews: [{
    userId: { type: mongoose.Schema.Types.ObjectId, refPath: 'reviews.userModel', required: true },
    userModel: { type: String, enum: ['ServiceProvider', 'Resident', 'Manager'], required: true },
    name: { type: String, required: true },
    rating: { type: Number, required: true, min: 1, max: 5 },
    comment: { type: String, required: true },
    date: { type: Date, default: Date.now },
  }],
});

ServiceSchema.index({ location: '2dsphere' });

module.exports = mongoose.model('Service', ServiceSchema);