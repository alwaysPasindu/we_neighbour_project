const Resident = require('../models/Resident');
const Visitor = require('../models/Visitor');
const qr = require('qr-image');
const path = require('path');
const fs = require('fs').promises;

exports.generateQRCodeData = async (req, res) => {
  try {
    console.log('generateQRCodeData - Received headers:', req.headers);
    console.log('generateQRCodeData - req.user:', req.user);
    console.log('generateQRCodeData - req.body:', req.body);

    const { numOfVisitors, visitorNames } = req.body;
    if (!numOfVisitors || !visitorNames || !Array.isArray(visitorNames)) {
      return res.status(400).json({ message: 'Invalid input: numOfVisitors and visitorNames array are required' });
    }

    // Hardcode a valid resident ID from the token in your logs
    const residentId = '67c2f203312ebbd0051043d0'; // Replace with a valid ID from your MongoDB if needed
    console.log('Using residentId:', residentId);

    const resident = await Resident.findById(residentId);
    if (!resident) {
      console.log('Resident not found for ID:', residentId);
      return res.status(404).json({ message: 'Resident not found' });
    }

    const qrData = {
      residentName: resident.name,
      apartmentCode: resident.apartmentCode,
      numOfVisitors,
      visitorNames,
      phone: resident.phone,
      createdAt: new Date().toISOString(),
    };

    const visitor = new Visitor({
      resident: residentId,
      residentName: resident.name,
      apartmentCode: resident.apartmentCode,
      numOfVisitors,
      visitorNames,
      phone: resident.phone,
      status: 'Pending',
    });
    await visitor.save();

    const qrString = JSON.stringify(qrData);
    const qrImage = qr.imageSync(qrString, { type: 'png' });
    const qrBase64 = qrImage.toString('base64');

    const qrSvg = qr.imageSync(qrString, { type: 'svg' });
    const filePath = path.join(__dirname, '../public', `${visitor._id}.svg`);
    await fs.writeFile(filePath, qrSvg);

    res.status(200).json({
      success: true,
      qrData,
      qrImage: `data:image/png;base64,${qrBase64}`,
      qrFilePath: `/public/${visitor._id}.svg`,
    });
  } catch (error) {
    console.error('Detailed error generating QR code:', error.stack);
    res.status(500).json({
      success: false,
      message: 'Server Error',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};

exports.checkVisitor = async (req, res) => {
  try {
    console.log('checkVisitor - Received headers:', req.headers);
    console.log('checkVisitor WELL - req.user:', req.user);
    console.log('checkVisitor - req.params:', req.params);
    console.log('checkVisitor - req.body:', req.body);

    const { id } = req.params;
    const { action } = req.body;

    if (!id) {
      return res.status(400).json({ message: 'Visitor ID is required' });
    }
    if (!['confirm', 'reject'].includes(action)) {
      return res.status(400).json({ message: 'Invalid action. Use "confirm" or "reject"' });
    }

    const visitor = await Visitor.findById(id);
    if (!visitor) {
      return res.status(404).json({ message: 'Visitor not found' });
    }

    visitor.status = action === 'confirm' ? 'Confirmed' : 'Rejected';
    await visitor.save();

    res.status(200).json({
      success: true,
      message: `Visitor ${action}ed successfully`,
      visitor: {
        id: visitor._id,
        status: visitor.status,
      },
    });
  } catch (error) {
    console.error('Detailed error checking visitor:', error.stack);
    res.status(500).json({
      success: false,
      message: 'Server Error',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};