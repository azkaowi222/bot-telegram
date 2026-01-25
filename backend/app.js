import express from "express";
import apiRoutes from "./routes/route.js";
import webhookRoutes from "./routes/webhook.js";
import dbConnect from "./config/database.js";
import dotenv from "dotenv";
import fileupload from "express-fileupload";
import "./jobs/cancelExpiredOrders.js";
import path from "path";
import cors from "cors";

dotenv.config({
  quiet: true,
});
dbConnect();

const PORT = process.env.PORT || 3000;

// await account
//   .updateMany(
//     {
//       status: "sold",
//     },
//     {
//       status: "available",
//     }
//   )
//   .catch(console.log);

// console.log("sukses update");

const app = express();
app.use(express.json());
app.use(fileupload());
app.use(
  cors({
    origin: "*",
  }),
);
app.use(express.static(path.join(import.meta.dirname, "public")));

app.use("/api", apiRoutes);
app.use("/api", webhookRoutes);

//listen on port 3000
app.listen(PORT, () => {
  console.log("api running on port 3000");
});
