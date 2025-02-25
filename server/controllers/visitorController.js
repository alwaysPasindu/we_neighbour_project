const Resident = require('../models/Resident');
const Visitor = require('../models/Visitor');
const qr = require('qr-image');
const path = require('path');
const fs = require('fs');


exports.generateQRCodeData = async(req,res) => {
    try{
        //retrieve resident data
        const { numOfVisitors, visitorNames} = req.body;
        const residentId = req.user.id;
        const resident= await Resident.findById(residentId);

        //prepare qr
        const qrData = {
            residentName: resident.name,
            apartmentCode: resident.apartmentCode,
            numberOfVisitors,
            visitorNames,
            phone: resident.phone,
        };

        //save the visitor info under "pending"
        const visitor= new Visitor({
            resident:residentId,
            residentName: resident.name,
            apartmentCode:resident.apartmentCode,
            numOfVisitors,
            visitorNames,
        });
        await visitor.save();
        
        //qr data to string
        const qrString = JSON.stringify(qrData);

        //genaraete qr img
        const qrSvg = qr.imageSync(qrString, {type:'svg'});
        const filePath = path.join(__dirname,'../public', `${visitor._id}.svg`);
        fs.writerFileSync(filePath, qrSvg);

        res.json({
            qrData,
            qrFilePath:`/qrcodes/${visitor._id}.svg`,
        });

    }catch(error){
        console.error(error);
        res.status(500).json({message:"Server Error"});
    }
};