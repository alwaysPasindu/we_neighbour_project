const { connectDB } = require('../config/database');
const VisitorSchema = require('../models/Visitor');
const ResidentSchema = require('../models/Resident');


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

        if (!residentId) {
            console.error('No resident ID found in req.user:', req.user);
            return res.status(401).json({ message: 'Authentication failed: No resident ID found' });

        }

        console.log('Resident found:', resident);
        
        const visitor = new Visitor( {
            resident: residentId, // Add this line with residentId (ObjectId)
            residentName: resident.name,
            apartmentCode: resident.apartmentCode,
            numOfVisitors,
            visitorNames:[],
            phone: resident.phone,
            status:'Pending',
        });

        
        await visitor.save();

        const baseUrl = process.env.BASE_URL || 'http://localhost:3000';
        const qrUrl = `${baseUrl}/visitor/verify/${visitor._id}`;

    

        res.json({
            success: true,
            qrUrl, // URL for QR generation in frontend
            visitorId: visitor._id.toString(),
        });
    } catch (error) {
        console.error('Error in generateQRCodeData:', error);
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};
/*
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
};*/

exports.verifyVisitor = async (req, res) => {
    try {
        const { visitorId } = req.params;

        // Since apartmentComplexName is in token, we need a way to get it without query param
        // For simplicity, assume this runs in a context where apartment is derivable (e.g., via a header or separate auth)
        // Here, we'll require an 'x-apartment-name' header for security to provide it (or adjust based on your auth setup)
        const apartmentComplexName = req.headers['x-apartment-name'];
        if (!apartmentComplexName) {
            return res.status(400).send('<h1>Missing apartment name</h1>');
        }

        const db = await connectDB(apartmentComplexName);
        const Visitor = db.model('Visitor', VisitorSchema);

        const visitor = await Visitor.findById(visitorId);
        if (!visitor) {
            return res.status(404).send('<h1>Invalid QR Code</h1>');
        }

        if (visitor.status !== 'Pending') {
            return res.status(400).send(`<h1>QR Code Already Processed: ${visitor.status}</h1>`);
        }

        // Serve simple verification page
        res.send(`
            <!DOCTYPE html>
            <html>
            <head>
                <title>Visitor Verification</title>
                <style>
                    body { font-family: Arial, sans-serif; text-align: center; padding: 20px; }
                    .container { max-width: 400px; margin: 0 auto; padding: 20px; border: 1px solid #ccc; border-radius: 10px; }
                    button { padding: 10px 20px; margin: 10px; border: none; border-radius: 5px; cursor: pointer; color: white; }
                    #approve { background-color: #007bff; }
                    #decline { background-color: #dc3545; }
                </style>
            </head>
            <body>
                <div class="container">
                    <h1>Visitor Verification</h1>
                    <p>Number of Visitors: ${visitor.numOfVisitors}</p>
                    <button id="approve" onclick="updateStatus('approve')">Approve</button>
                    <button id="decline" onclick="updateStatus('reject')">Decline</button>
                </div>
                <script>
                    async function updateStatus(action) {
                        const response = await fetch('/api/visitor/update-status', {
                            method: 'POST',
                            headers: { 
                                'Content-Type': 'application/json',
                                'x-apartment-name': '${apartmentComplexName}'
                            },
                            body: JSON.stringify({ visitorId: '${visitorId}', action })
                        });
                        const result = await response.json();
                        if (response.ok) {
                            document.body.innerHTML = '<h1>Visitor ' + (action === 'approve' ? 'accepted' : 'rejected') + '</h1>';
                        } else {
                            alert('Error: ' + result.message);
                        }
                    }
                </script>
            </body>
            </html>
        `);
    } catch (error) {
        console.error('Error verifying visitor:', error);
        res.status(500).send('<h1>Server Error</h1>');
    }
};

exports.updateVisitorStatus = async (req, res) => {
    try {
        const { visitorId, action } = req.body;
        const apartmentComplexName = req.headers['x-apartment-name'];

        if (!visitorId || !apartmentComplexName || !['approve', 'reject'].includes(action)) {
            return res.status(400).json({ message: 'Visitor ID, apartment name, and valid action are required' });
        }

        const db = await connectDB(apartmentComplexName);
        const Visitor = db.model('Visitor', VisitorSchema);

        const visitor = await Visitor.findById(visitorId);
        if (!visitor) {
            return res.status(404).json({ message: 'Invalid QR code' });
        }

        if (visitor.status !== 'Pending') {
            return res.status(400).json({ message: 'QR code already processed' });
        }

        visitor.status = action === 'approve' ? 'Approved' : 'Rejected';
        await visitor.save();

        res.json({
            success: true,
            message: `Visitor ${action === 'approve' ? 'accepted' : 'rejected'}`,
        });
    } catch (error) {
        console.error('Error updating visitor status:', error);
        res.status(500).json({ message: 'Server Error' });
    }
};