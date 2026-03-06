const express = require("express");

const userController = require("../controllers/userController");
const updateDataController = require("../controllers/updateDataController");

const userRouter = express.Router();

userRouter.get("/", userController.getUsers);
userRouter.post("/create", userController.addUser);
userRouter.put("/update", updateDataController.updateUser);
userRouter.delete("/delete/:id", updateDataController.deleteUser);

module.exports = userRouter;