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

const residentRoutes = require('./routes/residentRoutes');
app.use('/api/residents', residentRoutes);


app.listen(PORT, () => console.log('Server running on http://localhost:${PORT}'));