const Resource = require('../models/Resource');
const Resident = require('../models/Resident');

// Create resource request
exports.createResourceRequest = async (req, res) => {
  try {
    const { resourceName, description, quantity } = req.body;
    if (!resourceName || !description || !quantity) {
      return res.status(400).json({ message: 'Resource name, description, and quantity are required' });
    }

    const residentId = req.user.id;
    const resident = await Resident.findById(residentId);
    if (!resident) {
      return res.status(404).json({ message: 'Resident not found' });
    }

    if (!resident.apartmentCode) {
      return res.status(400).json({ message: 'Resident apartment code is required' });
    }

    const resource = new Resource({
      resourceName,
      description,
      quantity,
      resident: residentId,
      residentName: resident.name,
      apartmentCode: resident.apartmentCode,
    });

    await resource.save();
    res.status(201).json(resource); // Return the full resource object
  } catch (error) {
    console.error('Error creating resource request:', error);
    res.status(500).json({ message: 'Server Error' });
  }
};

// Get resource requests
exports.getResourceRequest = async (req, res) => {
  try {
    const requests = await Resource.find({ status: 'Active' })
      .sort({ createdAt: -1 })
      .populate('resident', 'name apartmentCode');

    res.json(requests);
  } catch (error) {
    console.error('Error fetching resource requests:', error);
    res.status(500).json({ message: 'Server Error' });
  }
};

// Delete resource request (only by creator)
exports.deleteResourceRequest = async (req, res) => {
  try {
    const { id } = req.params;
    if (!id) {
      return res.status(400).json({ message: 'Resource request ID is required' });
    }

    const userId = req.user.id;
    const request = await Resource.findById(id);
    if (!request) {
      return res.status(404).json({ message: 'Resource request not found' });
    }

    // Verify the user is the creator of the request
    if (request.resident.toString() !== userId) {
      return res.status(403).json({ message: 'You are not authorized to delete this resource request' });
    }

    request.status = 'Deleted';
    await request.save();

    res.json({ message: 'Resource request deleted successfully' });
  } catch (error) {
    console.error('Error deleting resource request:', error);
    res.status(500).json({ message: 'Server Error' });
  }
};