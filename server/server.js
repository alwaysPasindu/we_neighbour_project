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


app.listen(PORT, () => console.log('Server running on http://localhost:${PORT}'));