const express = require("express");

const Profile = require("../models/Profile");

const router = express.Router();

// GET /api/profile
// Return the user's profile.
//
// ForgeFit currently has one local user,
// so there should only be one profile document.
router.get("/", async (req, res) => {
  try {
    let profile = await Profile.findOne();

    // First launch: create the initial profile.
    if (!profile) {
      profile = await Profile.create({
        name: "Kanishk",
        height: 175,
        weight: 78,
        goal:
          "Build strength and an athletic physique",
        memberSince: new Date(2026, 6, 1),
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

// PATCH /api/profile
// Update the user's existing profile.
router.patch("/", async (req, res) => {
  try {
    const {
      name,
      height,
      weight,
      goal,
    } = req.body;

    if (
      typeof name !== "string" ||
      name.trim().length==0||
      typeof height !== "number" ||
      height <= 0 ||
      typeof weight !== "number" ||
      weight <= 0 ||
      typeof goal !== "string" ||
      goal.trim().length==0
    ) {
      return res.status(400).json({
        message: "Invalid profile data",
      });
    }

    let profile = await Profile.findOne();

    if (!profile) {
      profile = new Profile({
        name: name.trim(),
        height,
        weight,
        goal: goal.trim(),
        memberSince: new Date(),
      });
    } else {
      profile.name = name.trim();
      profile.height = height;
      profile.weight = weight;
      profile.goal = goal.trim();
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
      message: "Failed to update profile",
    });
  }
});

module.exports = router;