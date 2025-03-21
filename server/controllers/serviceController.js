const Service = require('../models/Service');
const ServiceProvider = require('../models/ServiceProvider');
const Resident = require('../models/Resident');
const Manager = require('../models/Manager');

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
    const { id } = req.params; // Add parameter for specific service ID

    if (id) {
      // Fetch a specific service by ID with all its reviews, regardless of user role
      const service = await Service.findById(id).populate('reviews.userId');
      if (!service) {
        return res.status(404).json({ message: 'Service not found' });
      }
      return res.json(service);
    }

    // Fetch services near a location (existing logic)
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
    const userId = req.user.id;
    const userRole = req.user.role.toLowerCase(); // Ensure lowercase for consistency

    // Verify the role matches the provided role (for security)
    if (userRole !== role.toLowerCase()) {
      return res.status(401).json({ message: 'Unauthorized user type' });
    }

    const service = await Service.findById(id);
    if (!service) {
      return res.status(404).json({ message: 'Service not found' });
    }

    let user;
    let userModel;
    if (['serviceprovider', 'resident', 'manager'].includes(userRole)) {
      // Handle different user types dynamically
      if (userRole === 'serviceprovider') {
        user = await ServiceProvider.findById(userId);
        userModel = 'ServiceProvider';
        if (!user) {
          return res.status(404).json({ message: 'Service provider not found' });
        }
      } else if (userRole === 'resident') {
        user = await Resident.findById(userId);
        userModel = 'Resident';
        if (!user) {
          return res.status(404).json({ message: 'Resident not found' });
        }
      } else if (userRole === 'manager') {
        user = await Manager.findById(userId);
        userModel = 'Manager';
        if (!user) {
          return res.status(404).json({ message: 'Manager not found' });
        }
      }
    } else {
      return res.status(401).json({ message: 'Unauthorized user type' });
    }

    service.reviews.push({
      userId,
      userModel, // Ensure userModel is included
      name: user.name,
      rating,
      comment,
    });
    await service.save();

    // Emit an event or update in real-time (optional, but not implemented here for simplicity)
    res.status(201).json({ message: 'Review added successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};