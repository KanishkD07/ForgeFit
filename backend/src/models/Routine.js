const mongoose = require("mongoose");

const routineExerciseSchema =
  new mongoose.Schema(
    {
      name: {
        type: String,
        required: true,
        trim: true,
      },

      defaultSets: {
        type: Number,
        required: true,
        min: 1,
        max: 20,
        default: 3,
      },
    },
    {
      _id: false,
    }
  );

const routineSchema =
  new mongoose.Schema(
    {
      user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true,
        index: true,
      },

      name: {
        type: String,
        required: true,
        trim: true,
        maxlength: 80,
      },

      exercises: {
        type: [routineExerciseSchema],
        required: true,

        validate: {
          validator: (value) =>
            Array.isArray(value) &&
            value.length > 0,

          message:
            "At least one exercise is required",
        },
      },
    },
    {
      timestamps: true,
    }
  );

routineSchema.index({
  user: 1,
  updatedAt: -1,
});

const Routine = mongoose.model(
  "Routine",
  routineSchema
);

module.exports = Routine;