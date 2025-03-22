const mongoose = require('mongoose');
const { centralDB } = require('../config/database');
const Service = require('../models/Service');
const ServiceProviderSchema = require('../models/ServiceProvider'); 


const ServiceProvider = centralDB.model('ServiceProvider', ServiceProviderSchema);

exports.createService = async (req, res) => {
  try {
    const { title, description, images, location, availableHours } = req.body;
    const serviceProviderId = req.user.id;

    const serviceProvider = await ServiceProvider.findById(serviceProviderId);
    if (!serviceProvider) {
      return res.status(404).json({ message: 'Service provider not found' });
    }

    const service = new Service({
      title,
      description,
      images,
      location: {
        type: 'Point',
        coordinates: location.coordinates,
        address: location.address || 'Unknown Location',
      },
      availableHours,
      serviceProvider: serviceProviderId,
      serviceProviderName: serviceProvider.name,
    });
    await service.save();

    res.status(201).json({ message: 'Service created successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

exports.getService = async (req, res) => {
  try {
    const { latitude, longitude } = req.query;
    const { id } = req.params;

    if (id) {
      const service = await Service.findById(id).populate('reviews.userId');
      if (!service) {
        return res.status(404).json({ message: 'Service not found' });
      }
      return res.json(service);
    }

    if (!latitude || !longitude) {
      return res.status(400).json({ message: 'Latitude and longitude are required' });
    }

    const userLocation = {
      type: 'Point',
      coordinates: [parseFloat(longitude), parseFloat(latitude)],
    };

    const services = await Service.find({
      location: {
        $near: {
          $geometry: userLocation,
          $maxDistance: 10000,
        },
      },
    }).populate('reviews.userId');

    res.json(services);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

exports.editService = async (req, res) => {
  try {
    const { id } = req.params;
    const { title, description, images, location, availableHours } = req.body;
    const serviceProviderId = req.user.id;

    const service = await Service.findById(id);
    if (!service) {
      return res.status(404).json({ message: 'Service not found' });
    }

    if (service.serviceProvider.toString() !== serviceProviderId) {
      return res.status(403).json({ message: 'You are not authorized' });
    }

    service.title = title || service.title;
    service.description = description || service.description;
    service.images = images || service.images;
    service.location = location || service.location;
    service.availableHours = availableHours || service.availableHours;

    await service.save();
    res.json({ message: 'Service updated successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

exports.deleteService = async (req, res) => {
  try {
    const { id } = req.params;
    const serviceProviderId = req.user.id;

    const service = await Service.findById(id);
    if (!service) {
      return res.status(404).json({ message: 'Service not found' });
    }

    if (service.serviceProvider.toString() !== serviceProviderId) {
      return res.status(403).json({ message: 'You are not authorized' });
    }

    await service.deleteOne();
    res.json({ message: 'Service deleted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

exports.addReview = async (req, res) => {
  try {
    const { id } = req.params;
    const { rating, comment, role } = req.body;
    console.log('Adding review for service ID:', id);
    console.log('Request body:', req.body);
    console.log('Authenticated user:', req.user);

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ message: 'Invalid service ID' });
    }

    const service = await Service.findById(id);
    if (!service) {
      console.log('Service not found for ID:', id);
      return res.status(404).json({ message: 'Service not found' });
    }

    // Normalize role to match enum (capitalize first letter)
    const reviewRole = role 
      ? role.charAt(0).toUpperCase() + role.slice(1).toLowerCase() // "resident" -> "Resident"
      : req.user.role; // "Resident" from token
    const reviewName = req.user.name || 'Unknown';

    const review = {
      userId: req.user.id,
      userModel: reviewRole,
      name: reviewName,
      rating,
      comment,
      date: new Date(),
    };
    console.log('Pushing review:', review);

    service.reviews.push(review);
    await service.save();
    console.log('Review added successfully for service:', id);
    res.status(201).json({ message: 'Review added successfully' });
  } catch (error) {
    console.error('AddReview Error:', error.stack);
    res.status(500).json({ message: 'Server Error', error: error.message });
  }
};