const jwt = require("jsonwebtoken");
const { saveMessage } = require('../services/messageServices');

const userIdSocketMap = new Map(); // userId -> socket.id

class SocketService {
  constructor(io) {
    this.io = io;
  }

  setup() {
    this.io.use((socket, next) => {
      const token = socket.handshake.auth?.token;
      const secret = process.env.JWT_SECRET;

      if (!token) {
        return next(new Error("No token"));
      }

      try {
        const decoded = jwt.verify(token, secret);
        socket.user = decoded;
        socket.user.id = decoded.sub;
        next();
      } catch (err) {
        return next(new Error("Invalid token"));
      }
    });

    this.io.on("connection", (socket) => {
      const userId = socket.user.id;
      console.log(`User ${userId} connected with socket ${socket.id}`);
      userIdSocketMap.set(userId, socket.id);

      socket.on("send_message", async (data) => {
        console.log("Received message from client:", data);

        try {
          const savedMessage = await saveMessage(data);

          const receiverSocketId = userIdSocketMap.get(data.receiverId);
          if (receiverSocketId) {
            socket.to(receiverSocketId).emit("receive_message", savedMessage);
          } else {
            console.log("client not online");
          }

          //console.log("Emitting message back to sender:", savedMessage);
          //socket.emit("receive_message", savedMessage);

          if (typeof ackCallback === 'function') {
            ackCallback({ status: "success", message: savedMessage });
          }

          console.log("Message sent:", savedMessage);
        } catch (err) {
          console.error("Error saving message:", err);
          socket.emit("error", { message: "Failed to save message" });
        }
      });

      socket.on("disconnect", () => {
        console.log(`User ${userId} disconnected`);
        userIdSocketMap.delete(userId);
      });
    });
  }
}

module.exports = SocketService;
