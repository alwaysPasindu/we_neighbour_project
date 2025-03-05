const Maintenance = require('../models/Maintenance');
const Resident = require('../models/Resident');

// Create a maintenance request
exports.createMaintenanceRequest = async (req, res) => {
  try {
    const { title, description } = req.body;
    if (!title || !description) {
      return res.status(400).json({ message: 'Title and description are required' });
    }

    const residentId = req.user.id;
    const resident = await Resident.findById(residentId);
    if (!resident) {
      return res.status(404).json({ message: 'Resident not found' });
    }

    if (!resident.apartmentCode) {
      return res.status(400).json({ message: 'Resident apartment code is required' });
    }

    const request = new Maintenance({
      title,
      description,
      resident: residentId,
      residentName: resident.name,
      apartmentCode: resident.apartmentCode,
    });

    await request.save();
    res.status(201).json({ message: 'Maintenance request sent' });
  } catch (error) {
    console.error('Error creating maintenance request:', error);
    res.status(500).json({ message: 'Server Error' });
  }
};

// Get pending maintenance requests (for managers)
exports.getPendingrequests = async (req, res) => {
  try {
    const requests = await Maintenance.find({ status: 'Pending' })
      .sort({ createdAt: -1 })
      .populate('resident', 'name apartmentCode');

    res.json(requests);
  } catch (error) {
    console.error('Error fetching pending maintenance requests:', error);
    res.status(500).json({ message: 'Server Error' });
  }
};

// Mark a maintenance request as done (by manager)
exports.markRequests = async (req, res) => {
  try {
    const { id } = req.params;
    if (!id) {
      return res.status(400).json({ message: 'Maintenance request ID is required' });
    }

    const request = await Maintenance.findById(id);
    if (!request) {
      return res.status(404).json({ message: 'Maintenance request not found' });
    }

    request.status = 'Done';
    await request.save();

    res.json({ message: 'Maintenance request marked as done' });
  } catch (error) {
    console.error('Error marking maintenance request:', error);
    res.status(500).json({ message: 'Server Error' });
  }
};

// Display completed maintenance requests (for residents)
exports.getCompletedRequests = async (req, res) => {
  try {
    const requests = await Maintenance.find({ status: 'Done' })
      .sort({ createdAt: -1 })
      .populate('ratings.resident', 'name');

    const requestsWithAverageRatings = requests.map((request) => {
      const totalStars = request.ratings.reduce((sum, rating) => sum + rating.stars, 0);
      const numberOfRatings = request.ratings.length;
      const averageRating = numberOfRatings > 0 ? totalStars / numberOfRatings : 0;

      return {
        ...request.toObject(),
        averageRating: parseFloat(averageRating.toFixed(2)),
        ratings: request.ratings, // Ensure ratings are included
      };
    });

    res.json(requestsWithAverageRatings);
  } catch (error) {
    console.error('Error fetching completed maintenance requests:', error);
    res.status(500).json({ message: 'Server Error' });
  }
};

// Rate a maintenance request (by resident) - one rating per user
exports.rateMaintenanceRequest = async (req, res) => {
  try {
    const { id } = req.params;
    const { stars } = req.body;
    if (!id) {
      return res.status(400).json({ message: 'Maintenance request ID is required' });
    }
    if (!stars || stars < 1 || stars > 5) {
      return res.status(400).json({ message: 'Rating must be between 1 and 5' });
    }

    const residentId = req.user.id;
    console.log('Attempting to rate maintenance with residentId:', residentId, 'for request:', id); // Enhanced debug log

    const request = await Maintenance.findById(id);
    if (!request) {
      return res.status(404).json({ message: 'Maintenance request not found' });
    }

    // Check if the user has already rated this request
    const existingRating = request.ratings.find(
      (rating) => rating.resident.toString() === residentId
    );

    if (existingRating) {
      console.log('User has already rated this request, returning 400');
      return res.status(400).json({ message: 'You have already rated this request' });
    }

    // Add the new rating
    request.ratings.push({ resident: residentId, stars });

    // Recalculate average rating
    const totalStars = request.ratings.reduce((sum, rating) => sum + rating.stars, 0);
    const numberOfRatings = request.ratings.length;
    request.averageRating = numberOfRatings > 0 ? totalStars / numberOfRatings : 0;

    // Preserve existing apartmentCode and other fields during update
    const updatedRequest = await Maintenance.findByIdAndUpdate(
      id,
      { ratings: request.ratings, averageRating: request.averageRating },
      { new: true, runValidators: false } // Disable validators for this update
    )
      .select('-residentName -apartmentCode') // Exclude sensitive fields if needed
      .populate('ratings.resident', 'name');

    console.log('Updated maintenance request ratings:', updatedRequest.ratings); // Debug log
    res.status(200).json(updatedRequest);
  } catch (error) {
    console.error('Error rating maintenance request:', error);
    res.status(500).json({ message: 'Server Error' });
  }
};