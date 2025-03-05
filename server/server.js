const express = require('express');
const cors = require('cors');
const connectDB = require('./config/database');
const app = express();
const PORT = process.env.PORT || 3000;

connectDB();

app.use(cors({
  origin: 'http://172.20.10.3:8080', // Update as needed
  credentials: true,
}));
app.use(express.json());

// Log all incoming requests for debugging
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  console.log('Headers:', req.headers);
  next();
});

app.get('/', (req, res) => {
  res.send('Backend is running');
});

// Routes
const authRoutes = require('./routes/authRoutes');
app.use('/api/auth', authRoutes);

const residentRoutes = require('./routes/residentRoutes');
app.use('/api/residents', residentRoutes);

const managerRoutes = require('./routes/managerRoutes');
app.use('/api/managers', managerRoutes);

const serviceProviderRoutes = require('./routes/serviceProviderRoutes');
app.use('/api/service-providers', serviceProviderRoutes);

const notificationRoutes = require('./routes/notificationRoutes');
app.use('/api/notifications', notificationRoutes);

const safetyAlertsRoutes = require('./routes/safetyRoutes');
app.use('/api/safety-alerts', safetyAlertsRoutes);

const complaintsRoutes = require('./routes/complaintRoutes');
app.use('/api/complaints', complaintsRoutes);

const visitorRoutes = require('./routes/visitorRoutes');
app.use('/api/visitor', visitorRoutes);

const maintenanceRoutes = require('./routes/maintenanceRoutes');
app.use('/api/maintenance', maintenanceRoutes);

const serviceRoutes = require('./routes/service');
app.use('/api/services', serviceRoutes);

const resourceRoutes = require('./routes/resourceRoutes');
app.use('/api/resources', resourceRoutes);

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

app.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));