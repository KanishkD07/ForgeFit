const express = require("express");
const mongoose = require("mongoose");
const dotenv = require("dotenv");
const cors = require("cors");

const workoutRoutes = require(
  "./routes/workoutRoutes"
);

const profileRoutes = require(
  "./routes/profileRoutes"
);

dotenv.config();

const app = express();

const PORT = process.env.PORT || 3000;
const MONGODB_URI = process.env.MONGODB_URI;

// Middleware

// Allow ForgeFit Flutter Web to access the API
app.use(cors());

app.use(express.json());

// Root route
app.get("/", (req, res) => {
  res.json({
    message: "ForgeFit API is running",
  });
});

// Health check
app.get("/api/health", (req, res) => {
  res.json({
    status: "OK",
    service: "ForgeFit API",
    database:
      mongoose.connection.readyState === 1
        ? "connected"
        : "disconnected",
    timestamp: new Date().toISOString(),
  });
});

// Workout routes
app.use(
  "/api/workouts",
  workoutRoutes
);

// Profile routes
app.use(
  "/api/profile",
  profileRoutes
);

async function startServer() {
  try {
    if (!MONGODB_URI) {
      throw new Error(
        "MONGODB_URI is missing from the .env file"
      );
    }

    await mongoose.connect(
      MONGODB_URI
    );

    console.log(
      "MongoDB connected successfully"
    );

    app.listen(PORT, () => {
      console.log(
        `ForgeFit API running on port ${PORT}`
      );
    });
  } catch (error) {
    console.error(
      "MongoDB connection failed:"
    );

    console.error(
      error.message
    );

    process.exit(1);
  }
}

startServer();