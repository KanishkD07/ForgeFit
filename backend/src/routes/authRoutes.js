const express = require("express");
const jwt = require("jsonwebtoken");

const User = require("../models/User");
const Profile = require("../models/Profile");

const router = express.Router();

function createToken(userId) {
  if (!process.env.JWT_SECRET) {
    throw new Error(
      "JWT_SECRET is missing from the .env file"
    );
  }

  return jwt.sign(
    {
      userId: userId.toString(),
    },
    process.env.JWT_SECRET,
    {
      expiresIn: "7d",
    }
  );
}

// POST /api/auth/register
router.post("/register", async (req, res) => {
  try {
    const {
      name,
      email,
      password,
      height,
      weight,
      goal,
    } = req.body;

    if (
      typeof name !== "string" ||
      name.trim().length === 0 ||
      typeof email !== "string" ||
      email.trim().length === 0 ||
      typeof password !== "string" ||
      password.length < 8 ||
      typeof height !== "number" ||
      height <= 0 ||
      typeof weight !== "number" ||
      weight <= 0 ||
      typeof goal !== "string" ||
      goal.trim().length === 0
    ) {
      return res.status(400).json({
        message:
          "Name, email, password, height, weight and goal are required",
      });
    }

    const normalizedEmail =
      email.trim().toLowerCase();

    const existingUser =
      await User.findOne({
        email: normalizedEmail,
      });

    if (existingUser) {
      return res.status(409).json({
        message:
          "An account with this email already exists",
      });
    }

    // User.js hashes the password
    // before saving.
    const user = await User.create({
      name: name.trim(),
      email: normalizedEmail,
      password,
    });

    try {
      await Profile.create({
        user: user._id,
        name: user.name,
        height,
        weight,
        goal: goal.trim(),
        memberSince: new Date(),
      });
    } catch (profileError) {
      // Avoid leaving an account behind
      // if profile creation fails.
      await User.findByIdAndDelete(
        user._id
      );

      throw profileError;
    }

    const token =
      createToken(user._id);

    res.status(201).json({
      message:
        "Account created successfully",
      token,
      user: {
        id: user._id.toString(),
        name: user.name,
        email: user.email,
      },
    });
  } catch (error) {
    console.error(
      "Registration failed:",
      error
    );

    if (error.code === 11000) {
      return res.status(409).json({
        message:
          "An account with this email already exists",
      });
    }

    if (
      error.name === "ValidationError"
    ) {
      return res.status(400).json({
        message: "Invalid user data",
        error: error.message,
      });
    }

    res.status(500).json({
      message:
        "Failed to create account",
    });
  }
});

// POST /api/auth/login
router.post("/login", async (req, res) => {
  try {
    const {
      email,
      password,
    } = req.body;

    if (
      typeof email !== "string" ||
      email.trim().length === 0 ||
      typeof password !== "string" ||
      password.length === 0
    ) {
      return res.status(400).json({
        message:
          "Email and password are required",
      });
    }

    const normalizedEmail =
      email.trim().toLowerCase();

    const user =
      await User.findOne({
        email: normalizedEmail,
      });

    if (!user) {
      return res.status(401).json({
        message:
          "Invalid email or password",
      });
    }

    const passwordMatches =
      await user.comparePassword(
        password
      );

    if (!passwordMatches) {
      return res.status(401).json({
        message:
          "Invalid email or password",
      });
    }

    const token =
      createToken(user._id);

    res.status(200).json({
      message: "Login successful",
      token,
      user: {
        id: user._id.toString(),
        name: user.name,
        email: user.email,
      },
    });
  } catch (error) {
    console.error(
      "Login failed:",
      error
    );

    res.status(500).json({
      message: "Failed to login",
    });
  }
});

module.exports = router;