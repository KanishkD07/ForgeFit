const mongoose = require("mongoose");

const setSchema = new mongoose.Schema(
  {
    weight: {
      type: Number,
      required: true,
      min: 0,
    },

    reps: {
      type: Number,
      required: true,
      min: 1,
    },
  },
  {
    _id: false,
  }
);

const exerciseSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },

    sets: {
      type: [setSchema],
      required: true,
    },
  },
  {
    _id: false,
  }
);

const workoutSchema = new mongoose.Schema(
  {
    date: {
      type: Date,
      required: true,
      default: Date.now,
    },

    durationSeconds: {
      type: Number,
      required: true,
      min: 0,
    },

    exercises: {
      type: [exerciseSchema],
      required: true,
    },
  },
  {
    timestamps: true,
  }
);

const Workout = mongoose.model(
  "Workout",
  workoutSchema
);

module.exports = Workout;