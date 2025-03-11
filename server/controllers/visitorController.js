const { connectDB } = require('../config/database');
const VisitorSchema = require('../models/Visitor');
const ResidentSchema = require('../models/Resident');
const qr = require('qr-image');
const path = require('path');
const fs = require('fs');

// Generate QR Code Data
exports.generateQRCodeData = async (req, res) => {
    try {
        const { numOfVisitors, visitorNames } = req.body;
        const residentId = req.user.id;
        const apartmentComplexName = req.user.apartmentComplexName;

        // Connect to the apartment-specific database
        const db = await connectDB(apartmentComplexName);
        const Visitor = db.model('Visitor', VisitorSchema);
        const Resident = db.model('Resident', ResidentSchema);

        // Fetch the resident
        const resident = await Resident.findById(residentId);
        if (!resident) {
            return res.status(404).json({ message: 'Resident not found' });
        }

        // Prepare QR data
        const qrData = {
            residentName: resident.name,
            apartmentCode: resident.apartmentCode,
            numOfVisitors,
            visitorNames,
            phone: resident.phone,
        };

        // Save the visitor info
        const visitor = new Visitor({
            resident: residentId,
            residentName: resident.name,
            apartmentCode: resident.apartmentCode,
            numOfVisitors,
            visitorNames,
            phone: resident.phone,
        });
        await visitor.save();

        // Convert QR data to a string
        const qrString = JSON.stringify(qrData);
        const qrImage = qr.imageSync(qrString, { type: 'png' });
        const qrBase64 = qrImage.toString('base64');

        // Generate QR image and save it
        const qrSvg = qr.imageSync(qrString, { type: 'svg' });
        const filePath = path.join(__dirname, '../public', `${visitor._id}.svg`);
        fs.writeFileSync(filePath, qrSvg);

        // Return QR data and image
        res.json({
            qrData,
            qrImage: `data:image/png;base64,${qrBase64}`, // Base64 image for frontend
        });
    } catch (error) {
        console.error('Error in generateQRCodeData:', error);
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

exports.checkVisitor = async (req,res) => {
    try{
        const{id} = req.params;
        const{action} = req.body;

        const visitor = await Visitor.findById(id);

        if(!visitor){
            return res.status(404).json({message:"Visitor not found"});
        }

        if(action === 'confirm'){
            visitor.status = 'Confirmed';
        }else if (action === 'reject'){
            visitor.status = 'Rejected';
        }else{
            return res.status(400).json({message:"Invalid action."})
        }
        await visitor.save();

        res.json({ message: `Visitor ${action}ed successfully!` });

    }catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server Error" });
  }
};