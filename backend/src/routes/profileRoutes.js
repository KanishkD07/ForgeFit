const express = require("express");

const Profile = require("../models/Profile");
const authMiddleware = require(
  "../middleware/authMiddleware"
);

const router = express.Router();

router.use(authMiddleware);

// =========================
// GET /api/profile
// =========================

router.get("/", async (req, res) => {
  try {
    const profile =
      await Profile.findOne({
        user: req.userId,
      });

    if (!profile) {
      return res.status(404).json({
        message: "Profile not found",
      });
    }

    res.status(200).json(profile);
  } catch (error) {
    console.error(
      "Failed to fetch profile:",
      error
    );

    res.status(500).json({
      message: "Failed to fetch profile",
    });
  }
});

// =========================
// PATCH /api/profile
// =========================

router.patch("/", async (req, res) => {
  try {
    const {
      name,
      height,
      weight,
      goal,
      weeklyWorkoutGoal,
    } = req.body;

    if (
      typeof name !== "string" ||
      name.trim().length === 0 ||
      typeof height !== "number" ||
      height <= 0 ||
      typeof weight !== "number" ||
      weight <= 0 ||
      typeof goal !== "string" ||
      goal.trim().length === 0
    ) {
      return res.status(400).json({
        message: "Invalid profile data",
      });
    }

    if (
      weeklyWorkoutGoal !== undefined &&
      (
        !Number.isInteger(
          weeklyWorkoutGoal
        ) ||
        weeklyWorkoutGoal < 1 ||
        weeklyWorkoutGoal > 7
      )
    ) {
      return res.status(400).json({
        message:
          "Weekly workout goal must be between 1 and 7",
      });
    }

    const profile =
      await Profile.findOne({
        user: req.userId,
      });

    if (!profile) {
      return res.status(404).json({
        message: "Profile not found",
      });
    }

    profile.name = name.trim();
    profile.height = height;
    profile.weight = weight;
    profile.goal = goal.trim();

    if (
      weeklyWorkoutGoal !== undefined
    ) {
      profile.weeklyWorkoutGoal =
        weeklyWorkoutGoal;
    }

    const updatedProfile =
      await profile.save();

    res.status(200).json(
      updatedProfile
    );
  } catch (error) {
    console.error(
      "Failed to update profile:",
      error
    );

    if (
      error.name === "ValidationError"
    ) {
      return res.status(400).json({
        message: "Invalid profile data",
        error: error.message,
      });
    }

    res.status(500).json({
      message:
        "Failed to update profile",
    });
  }
});

module.exports = router;