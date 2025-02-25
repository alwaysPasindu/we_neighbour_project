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
            numOfVisitors,
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