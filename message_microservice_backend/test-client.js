const { io } = require("socket.io-client");

// Connect to your server
const socket = io("http://localhost:3000");

// When connected
socket.on("connect", () => {
  console.log("Connected to server as:", socket.id);

  // Send a message to the server
  socket.emit("hello", { user: "Umanga", msg: "Testing from client!" });
});

// Listen for a response from the server
socket.on("response", (data) => {
  console.log("Server says:", data.message);
});

// Optional: Listen for disconnect
socket.on("disconnect", () => {
  console.log("Disconnected from server");
});
