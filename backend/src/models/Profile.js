const mongoose = require("mongoose");

const profileSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      unique: true,
      index: true,
    },

    name: {
      type: String,
      required: true,
      trim: true,
    },

    height: {
      type: Number,
      required: true,
      min: 1,
    },

    weight: {
      type: Number,
      required: true,
      min: 1,
    },

    goal: {
      type: String,
      required: true,
      trim: true,
    },

    memberSince: {
      type: Date,
      required: true,
      default: Date.now,
    },
  },
  {
    timestamps: true,
  }
);

const Profile = mongoose.model(
  "Profile",
  profileSchema
);

module.exports = Profile;