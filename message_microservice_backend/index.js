const express = require("express");
const http = require("http");
const cors = require("cors");

const app = express();
const port = process.env.PORT || 4000;

const server = http.createServer(app);
const io = require("socket.io")(server, {
  cors: {
    origin: "*",
  },
});

app.use(express.json());
app.use(cors());

io.on("connection", (socket) => {
  console.log("Client connected: ", socket.id);

  socket.on("send_message", (data) => {
    console.log("Received message from client:", data);

    // Send message back to frontend
    data.senderId = "server";
    socket.emit("receive_message", data);
    console.log("sending:", data);
  });

  socket.on("disconnect", () => {
    console.log("Client disconnected", socket.id);
  });
});

server.listen(port, () => {
  console.log("server started");
});

