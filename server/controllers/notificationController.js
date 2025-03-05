const ManagementNotification = require('../models/ManagementNotifications');
const CommunityNotification = require('../models/CommunityNotification');

// Create a management notification (Manager only)
exports.createManagementNotification = async (req, res) => {
  try {
    const { title, message } = req.body;
    if (!title || !message) {
      return res.status(400).json({ message: 'Title and message are required' });
    }

    const notification = new ManagementNotification({
      title,
      message,
      createdBy: req.user.id,
    });

    await notification.save();
    res.status(201).json({ message: 'Management Notification created successfully!' });
  } catch (error) {
    console.error('Error creating management notification:', error);
    res.status(500).json({ message: 'Server Error' });
  }
};

// Display all management notifications (Accessible to all authenticated users, but created by managers)
exports.getManagementNotification = async (req, res) => {
  try {
    const notifications = await ManagementNotification.find()
      .sort({ createdAt: -1 })
      .populate('createdBy', 'name');

    res.json(notifications);
  } catch (error) {
    console.error('Error fetching management notifications:', error);
    res.status(500).json({ message: 'Server Error' });
  }
};

// Remove a management notification (Manager only)
exports.removeManagementNotification = async (req, res) => {
  try {
    const { id } = req.params;
    if (!id) {
      return res.status(400).json({ message: 'Notification ID is required' });
    }

    const notification = await ManagementNotification.findById(id);
    if (!notification) {
      return res.status(404).json({ message: 'Notification not found' });
    }

    // Verify the user is a manager and authorized to delete
    if (req.user.role !== 'manager') {
      return res.status(403).json({ message: 'Only managers can delete management notifications' });
    }

    await ManagementNotification.findByIdAndDelete(id);
    res.json({ message: 'Management notification removed successfully!' });
  } catch (error) {
    console.error('Error removing management notification:', error);
    res.status(500).json({ message: 'Server Error' });
  }
};

// Create a community notification (Resident only)
exports.createCommunityNotification = async (req, res) => {
  try {
    const { title, message } = req.body;
    if (!title || !message) {
      return res.status(400).json({ message: 'Title and message are required' });
    }

    const notification = new CommunityNotification({
      title,
      message,
      createdBy: req.user.id,
    });

    await notification.save();
    res.status(201).json({ message: 'Community Notification created successfully!' }); // Fixed typo: "messsage" -> "message"
  } catch (error) {
    console.error('Error creating community notification:', error);
    res.status(500).json({ message: 'Server Error' });
  }
};

// Display all community notifications for the current user (Resident or Manager)
exports.getAllCommunityNotifications = async (req, res) => {
  try {
    const userId = req.user.id;

    const notifications = await CommunityNotification.find({
      removedFor: { $nin: [userId] },
    })
      .sort({ createdAt: -1 })
      .populate('createdBy', 'name');

    res.json(notifications);
  } catch (error) {
    console.error('Error fetching community notifications:', error);
    res.status(500).json({ message: 'Server Error' });
  }
};

// Remove a community notification by manager
exports.removeCommunityNotificationByManager = async (req, res) => {
  try {
    const { id } = req.params;
    if (!id) {
      return res.status(400).json({ message: 'Notification ID is required' });
    }

    const notification = await CommunityNotification.findById(id);
    if (!notification) {
      return res.status(404).json({ message: 'Notification not found' });
    }

    // Verify the user is a manager
    if (req.user.role !== 'manager') {
      return res.status(403).json({ message: 'Only managers can remove community notifications' });
    }

    await CommunityNotification.findByIdAndDelete(id);
    res.json({ message: 'Community Notification removed successfully!' });
  } catch (error) {
    console.error('Error removing community notification by manager:', error);
    res.status(500).json({ message: 'Server Error' });
  }
};

// Delete a community notification by the resident who created it
exports.deleteCommunityNotification = async (req, res) => {
  try {
    const { id } = req.params;
    if (!id) {
      return res.status(400).json({ message: 'Notification ID is required' });
    }

    const userId = req.user.id;
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
    res.status(500).json({ message: 'Server Error' });
  }
};

// Remove a community notification for the current user (e.g., swipe to remove)
exports.removeCommunityNotificationsFromUser = async (req, res) => {
  try {
    const { id } = req.params;
    if (!id) {
      return res.status(400).json({ message: 'Notification ID is required' });
    }

    const userId = req.user.id;
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
    res.status(500).json({ message: 'Server Error' });
  }
};

// Edit a community notification (Resident only)
exports.editCommunityNotification = async (req, res) => {
  try {
    const { id } = req.params;
    const { title, message } = req.body;
    if (!id) {
      return res.status(400).json({ message: 'Notification ID is required' });
    }
    if (!title && !message) {
      return res.status(400).json({ message: 'At least one field (title or message) is required for update' });
    }

    const userId = req.user.id;
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
    res.status(500).json({ message: 'Server Error' });
  }
};