const express = require('express');
const mongoose = require('mongoose');
const cors = require ('cors');
const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

mongoose.connect('mongodb://localhost:27017/we-neighbour',{
    useNewUrlParser:true,
    useUnifiedTopology:true
})  .then(() => console.log('MongoDB Connected'))
    .catch(err => console.error(err));


app.get('/',(req,res) => {
    res.send('Backend is running');
});

const residentRoutes = require('./routes/residentRoutes');
app.use('/api/residents', residentRoutes);


app.listen(PORT, () => console.log('Server running on http://localhost:${PORT}'));