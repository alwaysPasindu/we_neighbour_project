const ManagementNotificationSchema = require('../models/ManagementNotifications');
const CommunityNotificationSchema = require('../models/CommunityNotification');
const { connectDB } = require('../config/database');
const ResidentSchema = require('../models/Resident');
const ManagerSchema = require('../models/Manager');

// Create Management Notification
exports.createManagementNotification = async (req, res) => {
  try {
    const { title, message } = req.body;
    const apartmentComplexName = req.user.apartmentComplexName;

    if (!title || !message) {
      return res.status(400).json({ message: 'Title and message are required' });
    }

    const db = await connectDB(apartmentComplexName);
    const ManagementNotification = db.model('ManagementNotification', ManagementNotificationSchema);

    const notification = new ManagementNotification({
      title,
      message,
      createdBy: req.user.id,
    });
    await notification.save();
    res.status(201).json({ message: 'Management Notification created successfully!' });
  } catch (error) {
    console.error('Error creating management notification:', error);
    res.status(500).json({ message: 'Server Error', error: error.message });
  }
};

// Display All Management Notifications
exports.getManagementNotification = async (req, res) => {
  try {
    const apartmentComplexName = req.user.apartmentComplexName;

    const db = await connectDB(apartmentComplexName);
    const ManagementNotification = db.model('ManagementNotification', ManagementNotificationSchema);

    const notifications = await ManagementNotification.find()
      .sort({ createdAt: -1 })
      .populate('createdBy', 'name');
    res.json(notifications);
  } catch (error) {
    console.error('Error fetching management notifications:', error);
    res.status(500).json({ message: 'Server Error', error: error.message });
  }
};

// Remove Management Notification
exports.removeManagementNotification = async (req, res) => {
  try {
    const { id } = req.params;
    const apartmentComplexName = req.user.apartmentComplexName;

    const db = await connectDB(apartmentComplexName);
    const ManagementNotification = db.model('ManagementNotification', ManagementNotificationSchema);

    const notification = await ManagementNotification.findById(id);
    if (!notification) {
      return res.status(404).json({ message: 'Notification not found' });
    }

    await ManagementNotification.findByIdAndDelete(id);
    res.json({ message: 'Management notification removed successfully!' });
  } catch (error) {
    console.error('Error removing management notification:', error);
    res.status(500).json({ message: 'Server Error', error: error.message });
  }
};

// Create Community Notification
exports.createCommunityNotification = async (req, res) => {
  try {
    const { title, message } = req.body;
    const apartmentComplexName = req.user.apartmentComplexName;

    if (!title || !message) {
      return res.status(400).json({ message: 'Title and message are required' });
    }

    const db = await connectDB(apartmentComplexName);
    const CommunityNotification = db.model('CommunityNotification', CommunityNotificationSchema);

    const notification = new CommunityNotification({
      title,
      message,
      createdBy: req.user.id,
    });
    await notification.save();
    res.status(201).json({ message: 'Community Notification created successfully!' }); // Fixed typo: "messsage" -> "message"
  } catch (error) {
    console.error('Error creating community notification:', error);
    res.status(500).json({ message: 'Server Error', error: error.message });
  }
};

// Display All Community Notifications
exports.getAllCommunityNotifications = async (req, res) => {
  try {
    const userId = req.user.id;
    const apartmentComplexName = req.user.apartmentComplexName;

    const db = await connectDB(apartmentComplexName);
    const CommunityNotification = db.model('CommunityNotification', CommunityNotificationSchema);

    const notifications = await CommunityNotification.find({
      removedFor: { $nin: [userId] },
    })
      .sort({ createdAt: -1 })
      .populate('createdBy', 'name');

    res.json(notifications); // Single response, fixed duplicate res.json()
  } catch (error) {
    console.error('Error fetching community notifications:', error);
    res.status(500).json({ message: 'Server Error', error: error.message });
  }
};

// Remove Community Notification by Manager
exports.removeCommunityNotificationByManager = async (req, res) => {
  try {
    const { id } = req.params;
    const apartmentComplexName = req.user.apartmentComplexName;

    const db = await connectDB(apartmentComplexName);
    const CommunityNotification = db.model('CommunityNotification', CommunityNotificationSchema);

    const notification = await CommunityNotification.findById(id);
    if (!notification) {
      return res.status(404).json({ message: 'Notification not found' });
    }

    await CommunityNotification.findByIdAndDelete(id);
    res.json({ message: 'Community Notification removed successfully!' });
  } catch (error) {
    console.error('Error removing community notification by manager:', error);
    res.status(500).json({ message: 'Server Error', error: error.message });
  }
};

// Delete Community Notification by Creator
exports.deleteCommunityNotification = async (req, res) => {
  try {
    const { id } = req.params;
    const apartmentComplexName = req.user.apartmentComplexName;
    const userId = req.user.id;

    const db = await connectDB(apartmentComplexName);
    const CommunityNotification = db.model('CommunityNotification', CommunityNotificationSchema);

    const notification = await CommunityNotification.findById(id);
    if (!notification) {
      return res.status(404).json({ message: 'Notification not found' });
    }

    if (notification.createdBy.toString() !== userId) {
      return res.status(403).json({ message: 'You are not authorized to delete this notification' });
    }

    await CommunityNotification.findByIdAndDelete(id);
    res.json({ message: 'Notification deleted successfully!' });
  } catch (error) {
    console.error('Error deleting community notification:', error);
    res.status(500).json({ message: 'Server Error', error: error.message });
  }
};

// Remove Community Notification for Current User (Swipe Action)
exports.removeCommunityNotificationsFromUser = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;
    const apartmentComplexName = req.user.apartmentComplexName;

    const db = await connectDB(apartmentComplexName);
    const CommunityNotification = db.model('CommunityNotification', CommunityNotificationSchema);

    const notification = await CommunityNotification.findById(id);
    if (!notification) {
      return res.status(404).json({ message: 'Notification not found' });
    }

    if (!notification.removedFor.includes(userId)) {
      notification.removedFor.push(userId);
      await notification.save();
    }

    res.json({ message: 'Notification removed for current user' });
  } catch (error) {
    console.error('Error removing community notification for user:', error);
    res.status(500).json({ message: 'Server Error', error: error.message });
  }
};

// Edit Community Notification
exports.editCommunityNotification = async (req, res) => {
  try {
    const { id } = req.params;
    const { title, message } = req.body;
    const userId = req.user.id;
    const apartmentComplexName = req.user.apartmentComplexName;

    if (!title && !message) {
      return res.status(400).json({ message: 'At least one field (title or message) must be provided' });
    }

    const db = await connectDB(apartmentComplexName);
    const CommunityNotification = db.model('CommunityNotification', CommunityNotificationSchema);

    const notification = await CommunityNotification.findById(id);
    if (!notification) {
      return res.status(404).json({ message: 'Notification not found' });
    }

    if (notification.createdBy.toString() !== userId) {
      return res.status(403).json({ message: 'You are not authorized to edit this notification' });
    }

    notification.title = title || notification.title;
    notification.message = message || notification.message;
    await notification.save();

    res.json({ message: 'Notification updated successfully!', notification });
  } catch (error) {
    console.error('Error editing community notification:', error);
    res.status(500).json({ message: 'Server Error', error: error.message });
  }
};