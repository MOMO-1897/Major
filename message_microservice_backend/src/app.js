const express = require("express");
const cors = require("cors");
const conversationRoutes = require("./routes/conversationRoutes");

const app = express();
app.use(cors());
app.use(express.json());

app.use('/conversation', conversationRoutes);

module.exports = app;

