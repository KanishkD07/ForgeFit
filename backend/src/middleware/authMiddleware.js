const jwt = require("jsonwebtoken");

function authMiddleware(req, res, next) {
  try {
    const authHeader =
      req.headers.authorization;

    if (
      !authHeader ||
      !authHeader.startsWith("Bearer ")
    ) {
      return res.status(401).json({
        message:
          "Authentication required",
      });
    }

    const token =
      authHeader.substring(7);

    if (!token) {
      return res.status(401).json({
        message:
          "Authentication required",
      });
    }

    if (!process.env.JWT_SECRET) {
      throw new Error(
        "JWT_SECRET is missing from the .env file"
      );
    }

    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET
    );

    req.userId = decoded.userId;

    next();
  } catch (error) {
    if (
      error.name ===
        "JsonWebTokenError" ||
      error.name ===
        "TokenExpiredError"
    ) {
      return res.status(401).json({
        message:
          "Invalid or expired token",
      });
    }

    console.error(
      "Authentication failed:",
      error
    );

    res.status(500).json({
      message:
        "Authentication failed",
    });
  }
}

module.exports = authMiddleware;