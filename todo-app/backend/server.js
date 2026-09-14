require('dotenv').config();
const express = require('express');
const cors = require('cors');

const authRoutes = require('./routes/auth');
const taskRoutes = require('./routes/tasks');

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors({ origin: process.env.CLIENT_ORIGIN || '*' }));
app.use(express.json());

// Simple health check — this is also a good target for an ALB /
// API Gateway health check once this is deployed on AWS.
app.get('/health', (req, res) => res.json({status : 'ok'}));

app.use('/api', authRoutes);
app.use('/api/tasks', taskRoutes);

app.listen(PORT, () => {
    console.log(`Server listening on port ${PORT}`);
  });

module.exports = app;