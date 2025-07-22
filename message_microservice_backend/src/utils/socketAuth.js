const jwt = require('jsonwebtoken');

function socketAuthMiddleware(socket, next) {
  const token = socket.handshake.auth?.token;
  if (!token) {
    return next(new Error('Authentication error: token missing'));
  }

  try {
    // Verify token with your secret (make sure process.env.JWT_SECRET is set)
    const user = jwt.verify(token, process.env.JWT_SECRET);
    // Attach user info to socket object for later use
    socket.user = user;
    next();
  } catch (err) {
    return next(new Error('Authentication error: invalid token'));
  }
}

module.exports = socketAuthMiddleware;

