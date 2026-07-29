const express = require("express");
const mongoose = require("mongoose");

const Routine = require(
  "../models/Routine"
);

const authMiddleware = require(
  "../middleware/authMiddleware"
);

const router = express.Router();

// Every routine route requires
// authentication.
router.use(authMiddleware);

function validateRoutineBody(body) {
  const {
    name,
    exercises,
  } = body;

  if (
    typeof name !== "string" ||
    name.trim().length === 0 ||
    !Array.isArray(exercises) ||
    exercises.length === 0
  ) {
    return (
      "Routine name and at least " +
      "one exercise are required"
    );
  }

  for (finalExercise of exercises) {
    if (
      !finalExercise ||
      typeof finalExercise.name !==
        "string" ||
      finalExercise.name.trim()
          .length === 0 ||
      !Number.isInteger(
        finalExercise.defaultSets
      ) ||
      finalExercise.defaultSets < 1 ||
      finalExercise.defaultSets > 20
    ) {
      return (
        "Every exercise needs a name " +
        "and 1-20 default sets"
      );
    }
  }

  return null;
}

// =========================
// GET ALL ROUTINES
// =========================

// GET /api/routines
router.get("/", async (req, res) => {
  try {
    const routines =
      await Routine.find({
        user: req.userId,
      }).sort({
        updatedAt: -1,
      });

    res.status(200).json(
      routines
    );
  } catch (error) {
    console.error(
      "Failed to fetch routines:",
      error
    );

    res.status(500).json({
      message:
        "Failed to fetch routines",
    });
  }
});

// =========================
// CREATE ROUTINE
// =========================

// POST /api/routines
router.post("/", async (req, res) => {
  try {
    const validationError =
      validateRoutineBody(
        req.body
      );

    if (validationError) {
      return res.status(400).json({
        message: validationError,
      });
    }

    const routine =
      await Routine.create({
        user: req.userId,

        name:
          req.body.name.trim(),

        exercises:
          req.body.exercises.map(
            (exercise) => ({
              name:
                exercise.name.trim(),

              defaultSets:
                exercise.defaultSets,
            })
          ),
      });

    res.status(201).json(
      routine
    );
  } catch (error) {
    console.error(
      "Failed to create routine:",
      error
    );

    if (
      error.name ===
      "ValidationError"
    ) {
      return res.status(400).json({
        message:
          "Invalid routine data",
        error: error.message,
      });
    }

    res.status(500).json({
      message:
        "Failed to create routine",
    });
  }
});

// =========================
// UPDATE ROUTINE
// =========================

// PATCH /api/routines/:id
router.patch(
  "/:id",
  async (req, res) => {
    try {
      const {
        id,
      } = req.params;

      if (
        !mongoose.Types.ObjectId
          .isValid(id)
      ) {
        return res.status(400).json({
          message:
            "Invalid routine ID",
        });
      }

      const validationError =
        validateRoutineBody(
          req.body
        );

      if (validationError) {
        return res.status(400).json({
          message: validationError,
        });
      }

      const updatedRoutine =
        await Routine
          .findOneAndUpdate(
            {
              _id: id,
              user: req.userId,
            },
            {
              name:
                req.body.name.trim(),

              exercises:
                req.body.exercises.map(
                  (exercise) => ({
                    name:
                      exercise.name
                        .trim(),

                    defaultSets:
                      exercise
                        .defaultSets,
                  })
                ),
            },
            {
              new: true,
              runValidators: true,
            }
          );

      if (!updatedRoutine) {
        return res.status(404).json({
          message:
            "Routine not found",
        });
      }

      res.status(200).json(
        updatedRoutine
      );
    } catch (error) {
      console.error(
        "Failed to update routine:",
        error
      );

      if (
        error.name ===
        "ValidationError"
      ) {
        return res.status(400).json({
          message:
            "Invalid routine data",
          error: error.message,
        });
      }

      res.status(500).json({
        message:
          "Failed to update routine",
      });
    }
  }
);

// =========================
// DELETE ROUTINE
// =========================

// DELETE /api/routines/:id
router.delete(
  "/:id",
  async (req, res) => {
    try {
      const {
        id,
      } = req.params;

      if (
        !mongoose.Types.ObjectId
          .isValid(id)
      ) {
        return res.status(400).json({
          message:
            "Invalid routine ID",
        });
      }

      const routine =
        await Routine
          .findOneAndDelete({
            _id: id,
            user: req.userId,
          });

      if (!routine) {
        return res.status(404).json({
          message:
            "Routine not found",
        });
      }

      res.status(200).json({
        message:
          "Routine deleted successfully",

        id: routine._id,
      });
    } catch (error) {
      console.error(
        "Failed to delete routine:",
        error
      );

      res.status(500).json({
        message:
          "Failed to delete routine",
      });
    }
  }
);

module.exports = router;