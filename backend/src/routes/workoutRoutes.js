const express = require("express");
const mongoose = require("mongoose");

const Workout = require("../models/Workout");
const authMiddleware = require(
  "../middleware/authMiddleware"
);

const router = express.Router();

// Every workout route below requires authentication.
router.use(authMiddleware);

// GET /api/workouts
// Return only workouts belonging to the logged-in user.
router.get("/", async (req, res) => {
  try {
    const workouts = await Workout.find({
      user: req.userId,
    }).sort({
      date: -1,
    });

    res.status(200).json(workouts);
  } catch (error) {
    console.error(
      "Failed to fetch workouts:",
      error
    );

    res.status(500).json({
      message: "Failed to fetch workouts",
    });
  }
});

// POST /api/workouts
// Create a workout for the logged-in user.
router.post("/", async (req, res) => {
  try {
    const {
      date,
      durationSeconds,
      exercises,
    } = req.body;

    if (
      durationSeconds === undefined ||
      !Array.isArray(exercises) ||
      exercises.length === 0
    ) {
      return res.status(400).json({
        message:
          "durationSeconds and at least one exercise are required",
      });
    }

    const workout = new Workout({
      user: req.userId,
      date: date || new Date(),
      durationSeconds,
      exercises,
    });

    const savedWorkout =
      await workout.save();

    res.status(201).json(
      savedWorkout
    );
  } catch (error) {
    console.error(
      "Failed to save workout:",
      error
    );

    if (
      error.name === "ValidationError"
    ) {
      return res.status(400).json({
        message: "Invalid workout data",
        error: error.message,
      });
    }

    res.status(500).json({
      message: "Failed to save workout",
    });
  }
});

// PATCH /api/workouts/:id
// Update a workout only if it belongs to
// the logged-in user.
router.patch("/:id", async (req, res) => {
  try {
    const { id } = req.params;

    if (
      !mongoose.Types.ObjectId.isValid(id)
    ) {
      return res.status(400).json({
        message: "Invalid workout ID",
      });
    }

    const {
      date,
      durationSeconds,
      exercises,
    } = req.body;

    if (
      durationSeconds === undefined ||
      !Array.isArray(exercises) ||
      exercises.length === 0
    ) {
      return res.status(400).json({
        message:
          "durationSeconds and at least one exercise are required",
      });
    }

    const updatedWorkout =
      await Workout.findOneAndUpdate(
        {
          _id: id,
          user: req.userId,
        },
        {
          date,
          durationSeconds,
          exercises,
        },
        {
          new: true,
          runValidators: true,
        }
      );

    if (!updatedWorkout) {
      return res.status(404).json({
        message: "Workout not found",
      });
    }

    res.status(200).json(
      updatedWorkout
    );
  } catch (error) {
    console.error(
      "Failed to update workout:",
      error
    );

    if (
      error.name === "ValidationError"
    ) {
      return res.status(400).json({
        message: "Invalid workout data",
        error: error.message,
      });
    }

    res.status(500).json({
      message:
        "Failed to update workout",
    });
  }
});

// DELETE /api/workouts/:id
// Delete a workout only if it belongs to
// the logged-in user.
router.delete("/:id", async (req, res) => {
  try {
    const { id } = req.params;

    if (
      !mongoose.Types.ObjectId.isValid(id)
    ) {
      return res.status(400).json({
        message: "Invalid workout ID",
      });
    }

    const workout =
      await Workout.findOneAndDelete({
        _id: id,
        user: req.userId,
      });

    if (!workout) {
      return res.status(404).json({
        message: "Workout not found",
      });
    }

    res.status(200).json({
      message:
        "Workout deleted successfully",
      id: workout._id,
    });
  } catch (error) {
    console.error(
      "Failed to delete workout:",
      error
    );

    res.status(500).json({
      message:
        "Failed to delete workout",
    });
  }
});

module.exports = router;