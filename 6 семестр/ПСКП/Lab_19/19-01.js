const express = require("express");
const userRouter = require("../Lab_19/routes/userRouter");
const app = express();

app.use("/user", userRouter);

app.use(function(_, res){
    res.sendStatus(404);
});

app.listen(3000, () => console.log("http://localhost:3000/"));