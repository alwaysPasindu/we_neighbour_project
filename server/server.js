const express = require('express');
const cors = require ('cors');
const connectDB = require('./config/database');
const app = express();
const PORT = process.env.PORT || 3000;


connectDB();

app.use(cors());
app.use(express.json());


app.get('/',(req,res) => {
    res.send('Backend is running');
});

const authRoutes = require('./routes/authRoutes');
app.use('/api/auth',authRoutes);

const residentRoutes = require('./routes/residentRoutes');
app.use('/api/residents', residentRoutes);


const managerRoutes = require('./routes/managerRoutes');
app.use('/api/managers',managerRoutes);

const serviceProviderRoutes = require('./routes/serviceProviderRoutes');
app.use('/api/service-providers', serviceProviderRoutes);

const notificarionRoutes = require('./routes/notificationRoutes');
app.use('/api/notifications',notificarionRoutes);

const safetyAlertsRoutes = require('./routes/safetyRoutes');
app.use('/api/safety-alerts',safetyAlertsRoutes);

const complaintsRoutes = require('./routes/complaintRoutes');
app.use('/api/complaints',complaintsRoutes);

const visitorRoutes = require('./routes/visitorRoutes');
app.use('/api/visitor', visitorRoutes);

const maintenanceRoutes = require('./routes/maintenanceRoutes');
app.use('/api/maintenance',maintenanceRoutes);

const serviceRoutes = require('./routes/serviceRoutes');
app.use('/api/service',serviceRoutes);

const resourceRoutes = require('./routes/resourceRoutes');
app.use('/api/resource',resourceRoutes);

app.listen(PORT, () => console.log('Server running on http://localhost:${PORT}'));