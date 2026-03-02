const express = require("express");
const userController = require("../controllers/userController");

const userRouter = express.Router();

userRouter.get("/", userController.getUsers);
userRouter.post("/create", userController.addUser);
userRouter.put("/update", userController.updateUser);
userRouter.delete("/delete/:id", userController.deleteUser);

module.exports = userRouter;