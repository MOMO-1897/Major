const path = require('path');
console.log('CWD:', process.cwd());
console.log('.env path:', path.resolve(__dirname, '.env'));

require('dotenv').config({ path: path.resolve(__dirname, '.env') });

console.log('JWT_SECRET:', process.env.JWT_SECRET);

const http = require("http");
const app = require("./app");
const SocketService = require("./services/socketServices");

const express = require('express');
const connectDB = require('./db.js');

(async () => {
  try {
    await connectDB();

    const server = http.createServer(app);
    const io = require("socket.io")(server, { cors: { origin: "*" } });

    const socketService = new SocketService(io);
    socketService.setup();

    server.listen(4000, () => {
      console.log("Server listening on port 4000");
    });
  } catch (err) {
    console.error("Failed to connect to DB:", err);
    process.exit(1);
  }
})();

