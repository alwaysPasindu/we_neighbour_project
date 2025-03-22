const { connectDB } = require('../config/database');
const VisitorSchema = require('../models/Visitor');
const ResidentSchema = require('../models/Resident');


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
        
        const visitor = new Visitor({
            resident: residentId,
            residentName: resident.name,
            apartmentCode: resident.apartmentCode,
            apartmentComplexName: resident.apartmentComplexName,
            numOfVisitors,
            visitorNames: visitorNames || [], // Use visitorNames from req.body, default to empty array if not provided
            phone: resident.phone,
            status: 'Pending',
        });

        await visitor.save();

        const baseUrl = process.env.BASE_URL || 'http://localhost:3000';
        const qrUrl = `${baseUrl}/api/visitor/verify/${visitor._id}?apartment=${encodeURIComponent(apartmentComplexName)}`;

        res.json({
            success: true,
            qrUrl,
            visitorId: visitor._id.toString(),
        });
    } catch (error) {
        console.error('Error in generateQRCodeData:', error);
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

exports.verifyVisitor = async (req, res) => {
    try {
        const { visitorId } = req.params;
        const apartmentComplexName = req.headers['x-apartment-name'] || req.query.apartment;

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

        // Serve updated verification page with more details
        res.send(`
            <!DOCTYPE html>
            <html>
            <head>
                <title>Visitor Verification</title>
                <style>
                    body { font-family: Arial, sans-serif; text-align: center; padding: 20px; }
                    .container { max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #ccc; border-radius: 10px; }
                    button { padding: 10px 20px; margin: 10px; border: none; border-radius: 5px; cursor: pointer; color: white; }
                    #approve { background-color: #007bff; }
                    #decline { background-color: #dc3545; }
                    .details { text-align: left; margin-bottom: 20px; }
                    .details p { margin: 5px 0; }
                </style>
            </head>
            <body>
                <div class="container">
                    <h1>Visitor Verification</h1>
                    <div class="details">
                        <p><strong>Resident Name:</strong> ${visitor.residentName}</p>
                        <p><strong>Apartment Code:</strong> ${visitor.apartmentCode}</p>
                        <p><strong>Number of Visitors:</strong> ${visitor.numOfVisitors}</p>
                        <p><strong>Visitor Names:</strong> ${visitor.visitorNames.length > 0 ? visitor.visitorNames.join(', ') : 'Not provided'}</p>
                        <p><strong>Phone:</strong> ${visitor.phone}</p>
                        <p><strong>Created At:</strong> ${new Date(visitor.createdAt).toLocaleString()}</p>
                    </div>
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
        console.log(`Updating visitor ${visitorId} status to: ${visitor.status}`);
        await visitor.save();
        console.log(`Visitor ${visitorId} saved successfully with status: ${visitor.status}`);

        res.json({
            success: true,
            message: `Visitor ${action === 'approve' ? 'accepted' : 'rejected'}`,
        });
    } catch (error) {
        console.error('Error updating visitor status:', error.stack); // Log full error stack
        res.status(500).json({ message: 'Server Error' });
    }
};